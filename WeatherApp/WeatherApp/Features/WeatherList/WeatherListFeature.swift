import ComposableArchitecture
import Foundation

@Reducer
struct WeatherListFeature {
    @ObservableState
    struct State: Equatable, Sendable {
        var locations: IdentifiedArrayOf<WeatherFeature.State> = []
        var selectedIndex: Int = 0
        @Presents var manageLocations: ManageLocationsFeature.State?
    }

    enum Action: Equatable, Sendable {
        case onAppear
        case addRandomLocation
        case removeLocation(id: UUID)
        case restoreLocation(id: UUID, coordinate: Coordinate)
        case selectPage(Int)
        case locations(IdentifiedActionOf<WeatherFeature>)
        case manageLocationsTapped
        case manageLocations(PresentationAction<ManageLocationsFeature.Action>)
    }

    @Dependency(\.locationGenerator) var locationGenerator
    @Dependency(\.persistenceClient) var persistenceClient
    @Dependency(\.uuid) var uuid

    var body: some ReducerOf<Self> {
        CombineReducers {
            Reduce { state, action in
                switch action {
                case .onAppear:
                    return .run { [persistenceClient] send in
                        do {
                            let persisted = try await persistenceClient.loadLocations()
                            if persisted.isEmpty {
                                await send(.addRandomLocation)
                            } else {
                                for location in persisted {
                                    await send(.restoreLocation(id: location.id, coordinate: location.coordinate))
                                }
                            }
                        } catch {
                            await send(.addRandomLocation)
                        }
                    }

                case .addRandomLocation:
                    let coordinate = locationGenerator.generate()
                    let id = uuid()
                    let newLocation = WeatherFeature.State(
                        id: id,
                        coordinate: coordinate
                    )
                    state.locations.append(newLocation)
                    state.selectedIndex = state.locations.count - 1
                    let order = state.locations.count - 1

                    return .merge(
                        .send(.locations(.element(id: id, action: .fetchWeather))),
                        .run { [persistenceClient] _ in
                            try await persistenceClient.saveLocation(id, coordinate, order)
                        }
                    )

                case let .removeLocation(id):
                    state.locations.remove(id: id)
                    if state.selectedIndex >= state.locations.count {
                        state.selectedIndex = max(0, state.locations.count - 1)
                    }
                    return .merge(
                        .cancel(id: id),
                        .run { [persistenceClient] _ in
                            try await persistenceClient.deleteLocation(id)
                        }
                    )

                case let .restoreLocation(id, coordinate):
                    let newLocation = WeatherFeature.State(
                        id: id,
                        coordinate: coordinate
                    )
                    state.locations.append(newLocation)
                    return .send(.locations(.element(id: id, action: .fetchWeather)))

                case let .selectPage(index):
                    state.selectedIndex = index
                    return .none

                case .manageLocationsTapped:
                    state.manageLocations = ManageLocationsFeature.State(
                        locations: state.locations.toManageLocationsItems()
                    )
                    return .none

                case let .manageLocations(.presented(.selectLocation(id))):
                    if let index = state.locations.index(id: id) {
                        state.selectedIndex = Int(index)
                    }
                    return .none

                case let .manageLocations(.presented(.deleteLocation(id))):
                    state.locations.remove(id: id)
                    if state.selectedIndex >= state.locations.count {
                        state.selectedIndex = max(0, state.locations.count - 1)
                    }
                    return .merge(
                        .cancel(id: id),
                        .run { [persistenceClient] _ in
                            try await persistenceClient.deleteLocation(id)
                        }
                    )

                case .manageLocations(.presented(.addRandomLocation)):
                    let coordinate = locationGenerator.generate()
                    let id = uuid()
                    let newLocation = WeatherFeature.State(
                        id: id,
                        coordinate: coordinate
                    )
                    state.locations.append(newLocation)
                    state.selectedIndex = state.locations.count - 1
                    let order = state.locations.count - 1

                    // Dismiss modal — the user sees the new location loading on the main screen
                    state.manageLocations = nil

                    return .merge(
                        .send(.locations(.element(id: id, action: .fetchWeather))),
                        .run { [persistenceClient] _ in
                            try await persistenceClient.saveLocation(id, coordinate, order)
                        }
                    )

                case .manageLocations:
                    return .none

                case let .locations(.element(id: id, action: .pullToRefresh)):
                    let newCoordinate = locationGenerator.generate()
                    let order = state.locations.index(id: id).map { Int($0) } ?? 0
                    return .merge(
                        .send(.locations(.element(id: id, action: .refreshLocation(newCoordinate)))),
                        .run { [persistenceClient] _ in
                            try? await persistenceClient.saveLocation(id, newCoordinate, order)
                        }
                    )

                case .locations:
                    return .none
                }
            }
        }
        .forEach(\.locations, action: \.locations) {
            WeatherFeature()
        }
        .ifLet(\.$manageLocations, action: \.manageLocations) {
            ManageLocationsFeature()
        }
    }
}

// MARK: - Mapping Helpers

extension IdentifiedArrayOf<WeatherFeature.State> {
    func toManageLocationsItems() -> IdentifiedArrayOf<ManageLocationsFeature.LocationItem> {
        IdentifiedArray<UUID, ManageLocationsFeature.LocationItem>(uniqueElements: self.enumerated().map { index, location in
            ManageLocationsFeature.LocationItem(
                id: location.id,
                cityName: location.weather?.displayCityName ?? "Loading...",
                temperature: location.weather.map { "\(Int($0.temperature.rounded()))°C" } ?? "--",
                conditionDescription: location.weather?.description ?? "",
                condition: location.weather?.condition ?? .clear,
                isNight: location.weather?.isNight ?? false,
                isPrimary: index == 0
            )
        })
    }
}
