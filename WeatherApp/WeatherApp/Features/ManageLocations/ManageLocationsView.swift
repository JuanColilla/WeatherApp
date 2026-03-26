import ComposableArchitecture
import SwiftUI

struct ManageLocationsView: View {
    @Bindable var store: StoreOf<ManageLocationsFeature>

    var body: some View {
        ZStack {
            AnimatedGradientView(
                colors: [
                    Color(hex: "#1A1B4E"),
                    Color(hex: "#2D1B6E"),
                    Color(hex: "#1B3A5E"),
                    Color(hex: "#0F2027")
                ],
                speed: 0.015
            )
            .ignoresSafeArea()

            VStack(spacing: DSSpacing.lg) {
                Spacer().frame(height: DSSpacing.sm)

                header

                List {
                    ForEach(store.locations) { location in
                        LocationListItemView(
                            cityName: location.cityName,
                            temperature: location.temperature,
                            conditionDescription: location.conditionDescription,
                            condition: location.condition,
                            isNight: location.isNight,
                            isPrimary: location.isPrimary,
                            onTap: {
                                store.send(.selectLocation(id: location.id))
                            },
                            onDelete: location.isPrimary ? nil : {
                                store.send(.deleteLocation(id: location.id))
                            }
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if !location.isPrimary {
                                Button(role: .destructive) {
                                    store.send(.deleteLocation(id: location.id))
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: DSSpacing.xs, leading: 0, bottom: DSSpacing.xs, trailing: 0))
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)

                hint

                Spacer()

                RefreshButtonView(title: "Add Random Location") {
                    store.send(.addRandomLocation)
                }
                .padding(.bottom, DSSpacing.md)
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.bottom, DSSpacing.lg)
        }
    }

    @ViewBuilder
    private var header: some View {
        HStack {
            Text("Locations")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(DSColor.textPrimary)
            Spacer()
            Button("Done") {
                store.send(.doneTapped)
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(DSColor.accentBlue)
        }
    }

    @ViewBuilder
    private var hint: some View {
        HStack(alignment: .firstTextBaseline, spacing: DSSpacing.sm) {
            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundStyle(DSColor.textTertiary)
            Text("Swipe left on a location to delete it, or tap the minus button")
                .font(.system(size: 12))
                .foregroundStyle(DSColor.textTertiary)
                .multilineTextAlignment(.center)
        }
    }
}
