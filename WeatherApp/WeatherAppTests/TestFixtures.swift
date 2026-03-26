import Foundation
@testable import WeatherApp

// MARK: - Shared Coordinates

let fixtureCoordMadrid = Coordinate(latitude: 40.4168, longitude: -3.7038)
let fixtureCoordParis = Coordinate(latitude: 48.8566, longitude: 2.3522)

// MARK: - Shared Weather Data

let fixtureWeatherMadrid = WeatherData(
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
    coordinate: fixtureCoordMadrid,
    sunrise: Date(timeIntervalSince1970: 1_700_000_000),
    sunset: Date(timeIntervalSince1970: 1_700_050_000),
    countryCode: "ES"
)

let fixtureWeatherParis = WeatherData(
    cityName: "Paris",
    temperature: 18.0,
    feelsLike: 16.0,
    tempMin: 14.0,
    tempMax: 20.0,
    humidity: 70,
    windSpeed: 4.2,
    pressure: 1010,
    visibility: 8000,
    description: "Clouds",
    conditionCode: 802,
    iconCode: "03d",
    coordinate: fixtureCoordParis,
    sunrise: Date(timeIntervalSince1970: 1_700_000_000),
    sunset: Date(timeIntervalSince1970: 1_700_050_000),
    countryCode: "FR"
)

// MARK: - Shared UUIDs

let fixtureUUID_A = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!
let fixtureUUID_B = UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!
