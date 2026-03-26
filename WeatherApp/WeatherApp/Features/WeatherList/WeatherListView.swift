import ComposableArchitecture
import IdentifiedCollections
import SwiftUI

struct WeatherListView: View {
    @Bindable var store: StoreOf<WeatherListFeature>

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $store.selectedIndex.sending(\.selectPage)) {
                    ForEach(
                        Array(store.scope(state: \.locations, action: \.locations).enumerated()),
                        id: \.element.id
                    ) { index, childStore in
                        WeatherView(store: childStore)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                bottomBar
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(item: $store.scope(state: \.manageLocations, action: \.manageLocations)) { manageStore in
            ManageLocationsView(store: manageStore)
        }
    }

    private var isCurrentLocationGenerating: Bool {
        guard let currentLocation = store.locations[safe: store.selectedIndex] else { return false }
        return currentLocation.aiQuoteState == .generating
    }

    @ViewBuilder
    private var backgroundGradient: some View {
        AnimatedGradientView(
            colors: currentWeatherGradient.colors,
            speed: 0.02,
            isAccelerated: isCurrentLocationGenerating
        )
        .animation(.easeInOut(duration: 1.0), value: currentConditionKey)
    }

    private var currentWeatherGradient: WeatherGradient {
        guard let currentLocation = store.locations[safe: store.selectedIndex],
              let weather = currentLocation.weather else {
            return WeatherGradient.forCondition(.clear, isNight: false)
        }
        return WeatherGradient.forCondition(weather.condition, isNight: weather.isNight)
    }

    private var currentConditionKey: String {
        guard let currentLocation = store.locations[safe: store.selectedIndex],
              let weather = currentLocation.weather else {
            return "default"
        }
        return "\(weather.conditionCode)-\(weather.isNight)"
    }

    @ViewBuilder
    private var bottomBar: some View {
        HStack {
            Button {
                store.send(.manageLocationsTapped)
            } label: {
                Image(systemName: "list.bullet")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DSColor.textPrimary)
                    .frame(width: 36, height: 36)
                    .glassEffect(.regular, in: Circle())
            }

            HStack(spacing: DSSpacing.sm) {
                ForEach(0..<store.locations.count, id: \.self) { index in
                    Circle()
                        .fill(index == store.selectedIndex
                              ? DSColor.textPrimary
                              : DSColor.textTertiary)
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: store.selectedIndex)
                }
            }

            Spacer()

            Button {
                store.send(.addRandomLocation)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                    Text("New Location")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(DSColor.textPrimary)
                .padding(.vertical, 10)
                .padding(.horizontal, DSSpacing.md)
                .glassEffect(.regular, in: Capsule())
            }
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.bottom, DSSpacing.sm)
    }
}

extension IdentifiedArray {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self.elements[index]
    }
}
