import XCTest
import SnapshotTesting
import SwiftUI
import ComposableArchitecture
@testable import WeatherApp

@MainActor
final class ScreenSnapshotTests: XCTestCase {

    override func invokeTest() {
        withSnapshotTesting(record: .missing) {
            super.invokeTest()
        }
    }

    // MARK: - WeatherView: Loading State

    func test_weatherView_loading_light() {
        let store = Store(
            initialState: WeatherFeature.State(
                id: UUID(),
                coordinate: Coordinate(latitude: 40.4168, longitude: -3.7038)
            )
        ) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient = .previewValue
            $0.cacheClient = .previewValue
            $0.intelligenceClient = .previewValue
        }

        let view = WeatherView(store: store)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#1A1B2E"))
            .preferredColorScheme(.light)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    func test_weatherView_loading_dark() {
        let store = Store(
            initialState: WeatherFeature.State(
                id: UUID(),
                coordinate: Coordinate(latitude: 40.4168, longitude: -3.7038)
            )
        ) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient = .previewValue
            $0.cacheClient = .previewValue
            $0.intelligenceClient = .previewValue
        }

        let view = WeatherView(store: store)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#1A1B2E"))
            .preferredColorScheme(.dark)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    // MARK: - WeatherView: Loaded State

    func test_weatherView_loaded_light() {
        let store = Store(
            initialState: WeatherFeature.State(
                id: UUID(),
                coordinate: Coordinate(latitude: 40.4168, longitude: -3.7038),
                weather: WeatherData(
                    cityName: "Madrid",
                    temperature: 22.0,
                    feelsLike: 21.0,
                    tempMin: 18.0,
                    tempMax: 25.0,
                    humidity: 55,
                    windSpeed: 3.5,
                    pressure: 1013,
                    visibility: 10000,
                    description: "Clear sky",
                    conditionCode: 800,
                    iconCode: "01d",
                    coordinate: Coordinate(latitude: 40.4168, longitude: -3.7038),
                    sunrise: Date(timeIntervalSince1970: 1_700_000_000),
                    sunset: Date(timeIntervalSince1970: 1_700_050_000),
                    countryCode: "ES"
                ),
                loadingState: .loaded,
                aiQuoteState: .generated("Madrid at 22°C — the only place where 'partly cloudy' is considered a weather event.")
            )
        ) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient = .previewValue
            $0.cacheClient = .previewValue
            $0.intelligenceClient = .previewValue
        }

        let view = WeatherView(store: store)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#1A1B2E"))
            .preferredColorScheme(.light)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    func test_weatherView_loaded_dark() {
        let store = Store(
            initialState: WeatherFeature.State(
                id: UUID(),
                coordinate: Coordinate(latitude: 40.4168, longitude: -3.7038),
                weather: WeatherData(
                    cityName: "Madrid",
                    temperature: 22.0,
                    feelsLike: 21.0,
                    tempMin: 18.0,
                    tempMax: 25.0,
                    humidity: 55,
                    windSpeed: 3.5,
                    pressure: 1013,
                    visibility: 10000,
                    description: "Clear sky",
                    conditionCode: 800,
                    iconCode: "01d",
                    coordinate: Coordinate(latitude: 40.4168, longitude: -3.7038),
                    sunrise: Date(timeIntervalSince1970: 1_700_000_000),
                    sunset: Date(timeIntervalSince1970: 1_700_050_000),
                    countryCode: "ES"
                ),
                loadingState: .loaded,
                aiQuoteState: .generated("Madrid at 22°C — the only place where 'partly cloudy' is considered a weather event.")
            )
        ) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient = .previewValue
            $0.cacheClient = .previewValue
            $0.intelligenceClient = .previewValue
        }

        let view = WeatherView(store: store)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#1A1B2E"))
            .preferredColorScheme(.dark)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    // MARK: - WeatherView: Error State

    func test_weatherView_error_light() {
        let store = Store(
            initialState: WeatherFeature.State(
                id: UUID(),
                coordinate: Coordinate(latitude: 40.4168, longitude: -3.7038),
                loadingState: .error("The server returned an invalid response.")
            )
        ) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient = .previewValue
            $0.cacheClient = .previewValue
            $0.intelligenceClient = .previewValue
        }

        let view = WeatherView(store: store)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#1A1B2E"))
            .preferredColorScheme(.light)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    func test_weatherView_error_dark() {
        let store = Store(
            initialState: WeatherFeature.State(
                id: UUID(),
                coordinate: Coordinate(latitude: 40.4168, longitude: -3.7038),
                loadingState: .error("The server returned an invalid response.")
            )
        ) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient = .previewValue
            $0.cacheClient = .previewValue
            $0.intelligenceClient = .previewValue
        }

        let view = WeatherView(store: store)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#1A1B2E"))
            .preferredColorScheme(.dark)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    // MARK: - ManageLocationsView

    func test_manageLocationsView_light() {
        let store = Store(
            initialState: ManageLocationsFeature.State(
                locations: [
                    ManageLocationsFeature.LocationItem(
                        id: UUID(),
                        cityName: "Madrid",
                        temperature: "22°C",
                        conditionDescription: "Clear sky",
                        condition: .clear,
                        isNight: false,
                        isPrimary: true
                    ),
                    ManageLocationsFeature.LocationItem(
                        id: UUID(),
                        cityName: "Paris",
                        temperature: "18°C",
                        conditionDescription: "Clouds",
                        condition: .clouds,
                        isNight: false,
                        isPrimary: false
                    ),
                    ManageLocationsFeature.LocationItem(
                        id: UUID(),
                        cityName: "Tokyo",
                        temperature: "28°C",
                        conditionDescription: "Heavy rain",
                        condition: .rain,
                        isNight: true,
                        isPrimary: false
                    ),
                ]
            )
        ) {
            ManageLocationsFeature()
        } withDependencies: {
            $0.dismiss = DismissEffect { }
        }

        let view = ManageLocationsView(store: store)
            .environment(\.animationsEnabled, false)
            .preferredColorScheme(.light)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    func test_manageLocationsView_dark() {
        let store = Store(
            initialState: ManageLocationsFeature.State(
                locations: [
                    ManageLocationsFeature.LocationItem(
                        id: UUID(),
                        cityName: "Madrid",
                        temperature: "22°C",
                        conditionDescription: "Clear sky",
                        condition: .clear,
                        isNight: false,
                        isPrimary: true
                    ),
                    ManageLocationsFeature.LocationItem(
                        id: UUID(),
                        cityName: "Paris",
                        temperature: "18°C",
                        conditionDescription: "Clouds",
                        condition: .clouds,
                        isNight: false,
                        isPrimary: false
                    ),
                    ManageLocationsFeature.LocationItem(
                        id: UUID(),
                        cityName: "Tokyo",
                        temperature: "28°C",
                        conditionDescription: "Heavy rain",
                        condition: .rain,
                        isNight: true,
                        isPrimary: false
                    ),
                ]
            )
        ) {
            ManageLocationsFeature()
        } withDependencies: {
            $0.dismiss = DismissEffect { }
        }

        let view = ManageLocationsView(store: store)
            .environment(\.animationsEnabled, false)
            .preferredColorScheme(.dark)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }
}
