import XCTest
import SnapshotTesting
import SwiftUI
@testable import WeatherApp

@MainActor
final class ComponentSnapshotTests: XCTestCase {

    override func invokeTest() {
        withSnapshotTesting(record: .missing) {
            super.invokeTest()
        }
    }

    // MARK: - WeatherMetricCardView

    func test_weatherMetricCard_light() {
        let view = WeatherMetricCardView(
            icon: "humidity.fill",
            iconColor: Color(hex: "#5B9CF6"),
            label: "Humidity",
            value: "55%"
        )
        .frame(width: 200)
        .padding(24)
        .background(Color(hex: "#1A1B2E"))
        .preferredColorScheme(.light)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    func test_weatherMetricCard_dark() {
        let view = WeatherMetricCardView(
            icon: "humidity.fill",
            iconColor: Color(hex: "#5B9CF6"),
            label: "Humidity",
            value: "55%"
        )
        .frame(width: 200)
        .padding(24)
        .background(Color(hex: "#1A1B2E"))
        .preferredColorScheme(.dark)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    // MARK: - LocationBadgeView

    func test_locationBadge_light() {
        let view = LocationBadgeView(
            cityName: "Madrid",
            coordinate: Coordinate(latitude: 40.4168, longitude: -3.7038)
        )
        .padding(24)
        .background(Color(hex: "#1A1B2E"))
        .preferredColorScheme(.light)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    func test_locationBadge_dark() {
        let view = LocationBadgeView(
            cityName: "Madrid",
            coordinate: Coordinate(latitude: 40.4168, longitude: -3.7038)
        )
        .padding(24)
        .background(Color(hex: "#1A1B2E"))
        .preferredColorScheme(.dark)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    // MARK: - TemperatureDisplayView

    func test_temperatureDisplay_light() {
        let view = TemperatureDisplayView(temperature: 22.0)
            .padding(24)
            .background(Color(hex: "#1A1B2E"))
            .preferredColorScheme(.light)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    func test_temperatureDisplay_dark() {
        let view = TemperatureDisplayView(temperature: 22.0)
            .padding(24)
            .background(Color(hex: "#1A1B2E"))
            .preferredColorScheme(.dark)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    // MARK: - WeatherConditionBadgeView

    func test_weatherConditionBadge_light() {
        let view = WeatherConditionBadgeView(
            condition: .clear,
            description: "Clear sky",
            isNight: false
        )
        .padding(24)
        .background(Color(hex: "#1A1B2E"))
        .preferredColorScheme(.light)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    func test_weatherConditionBadge_dark() {
        let view = WeatherConditionBadgeView(
            condition: .clear,
            description: "Clear sky",
            isNight: false
        )
        .padding(24)
        .background(Color(hex: "#1A1B2E"))
        .preferredColorScheme(.dark)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    // MARK: - LocationListItemView (Primary)

    func test_locationListItem_primary_light() {
        let view = LocationListItemView(
            cityName: "Madrid",
            temperature: "22°",
            conditionDescription: "Clear sky",
            condition: .clear,
            isNight: false,
            isPrimary: true,
            onDelete: nil
        )
        .frame(width: 360)
        .padding(24)
        .background(Color(hex: "#1A1B2E"))
        .preferredColorScheme(.light)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    func test_locationListItem_primary_dark() {
        let view = LocationListItemView(
            cityName: "Madrid",
            temperature: "22°",
            conditionDescription: "Clear sky",
            condition: .clear,
            isNight: false,
            isPrimary: true,
            onDelete: nil
        )
        .frame(width: 360)
        .padding(24)
        .background(Color(hex: "#1A1B2E"))
        .preferredColorScheme(.dark)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    // MARK: - LocationListItemView (Secondary)

    func test_locationListItem_secondary_light() {
        let view = LocationListItemView(
            cityName: "Barcelona",
            temperature: "19°",
            conditionDescription: "Partly cloudy",
            condition: .clouds,
            isNight: false,
            isPrimary: false,
            onDelete: {}
        )
        .frame(width: 360)
        .padding(24)
        .background(Color(hex: "#1A1B2E"))
        .preferredColorScheme(.light)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    func test_locationListItem_secondary_dark() {
        let view = LocationListItemView(
            cityName: "Barcelona",
            temperature: "19°",
            conditionDescription: "Partly cloudy",
            condition: .clouds,
            isNight: false,
            isPrimary: false,
            onDelete: {}
        )
        .frame(width: 360)
        .padding(24)
        .background(Color(hex: "#1A1B2E"))
        .preferredColorScheme(.dark)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }
}
