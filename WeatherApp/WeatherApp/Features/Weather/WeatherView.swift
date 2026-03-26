import ComposableArchitecture
import SwiftUI

struct WeatherView: View {
    let store: StoreOf<WeatherFeature>

    var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                switch store.loadingState {
                case .idle, .loading:
                    loadingContent
                case .loaded:
                    if let weather = store.weather {
                        loadedContent(weather)
                    }
                case let .error(message):
                    errorContent(message)
                }
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.bottom, DSSpacing.lg)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await store.send(.pullToRefresh).finish()
        }
    }

    @ViewBuilder
    private var loadingContent: some View {
        VStack(spacing: DSSpacing.lg) {
            RoundedRectangle(cornerRadius: DSRadius.pill)
                .fill(DSColor.glassSurface)
                .frame(width: 200, height: 40)

            RoundedRectangle(cornerRadius: DSRadius.sm)
                .fill(DSColor.glassSurface)
                .frame(width: 150, height: 96)

            RoundedRectangle(cornerRadius: DSRadius.pill)
                .fill(DSColor.glassSurface)
                .frame(width: 160, height: 36)

            metricsPlaceholder
        }
        .shimmering()
    }

    @ViewBuilder
    private func loadedContent(_ weather: WeatherData) -> some View {
        LocationBadgeView(
            cityName: weather.displayCityName,
            coordinate: weather.coordinate
        )

        TemperatureDisplayView(temperature: weather.temperature)

        WeatherConditionBadgeView(
            condition: weather.condition,
            description: weather.description,
            isNight: weather.isNight
        )

        metricsGrid(weather)

        if store.aiQuoteState != .idle {
            AIQuoteCardView(
                state: store.aiQuoteState,
                onRefresh: {
                    store.send(.refreshAIQuote)
                }
            )
        }
    }

    @ViewBuilder
    private func errorContent(_ message: String) -> some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(DSColor.accentOrange)
            Text("Something went wrong")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(DSColor.textPrimary)
            Text(message)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                store.send(.retryFetch)
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(DSColor.textPrimary)
            .padding(.vertical, 14)
            .padding(.horizontal, DSSpacing.lg)
            .glassEffect(.regular, in: Capsule())
        }
        .padding(.top, DSSpacing.xl)
    }

    @ViewBuilder
    private func metricsGrid(_ weather: WeatherData) -> some View {
        VStack(spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.sm) {
                WeatherMetricCardView(
                    icon: "humidity.fill",
                    iconColor: DSColor.accentBlue,
                    label: "Humidity",
                    value: "\(weather.humidity)%"
                )
                WeatherMetricCardView(
                    icon: "wind",
                    iconColor: DSColor.accentTeal,
                    label: "Wind",
                    value: String(format: "%.1f m/s", weather.windSpeed)
                )
            }
            HStack(spacing: DSSpacing.sm) {
                WeatherMetricCardView(
                    icon: "gauge.medium",
                    iconColor: DSColor.accentBlue,
                    label: "Pressure",
                    value: "\(weather.pressure) hPa"
                )
                WeatherMetricCardView(
                    icon: "thermometer.medium",
                    iconColor: DSColor.accentOrange,
                    label: "Feels Like",
                    value: "\(Int(weather.feelsLike.rounded()))°"
                )
            }
        }
    }

    @ViewBuilder
    private var metricsPlaceholder: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.sm) {
                placeholderCard
                placeholderCard
            }
            HStack(spacing: DSSpacing.sm) {
                placeholderCard
                placeholderCard
            }
        }
    }

    private var placeholderCard: some View {
        RoundedRectangle(cornerRadius: DSRadius.lg)
            .fill(DSColor.glassSurface)
            .frame(maxWidth: .infinity)
            .frame(height: 110)
    }
}
