import ComposableArchitecture
import Foundation

@Reducer
struct ManageLocationsFeature {
    @ObservableState
    struct State: Equatable, Sendable {
        var locations: IdentifiedArrayOf<LocationItem> = []
    }

    struct LocationItem: Equatable, Identifiable, Sendable {
        let id: UUID
        let cityName: String
        let temperature: String
        let conditionDescription: String
        let condition: WeatherCondition
        let isNight: Bool
        let isPrimary: Bool
    }

    enum Action: Equatable, Sendable {
        case doneTapped
        case deleteLocation(id: UUID)
        case selectLocation(id: UUID)
        case addRandomLocation
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .doneTapped:
                return .run { _ in await dismiss() }

            case let .deleteLocation(id):
                guard state.locations[id: id]?.isPrimary == false else {
                    return .none
                }
                state.locations.remove(id: id)
                return .none

            case .selectLocation:
                return .run { _ in await dismiss() }

            case .addRandomLocation:
                return .none
            }
        }
    }
}
