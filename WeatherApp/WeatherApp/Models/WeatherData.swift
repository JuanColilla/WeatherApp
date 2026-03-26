import Foundation

struct WeatherData: Equatable, Codable, Sendable, Identifiable {
    var id: String { coordinate.cacheKey }
    let cityName: String
    let temperature: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
    let windSpeed: Double
    let pressure: Int
    let visibility: Int
    let description: String
    let conditionCode: Int
    let iconCode: String
    let coordinate: Coordinate
    let sunrise: Date
    let sunset: Date
    let countryCode: String

    var condition: WeatherCondition {
        WeatherCondition(conditionCode: conditionCode)
    }

    var isNight: Bool {
        iconCode.hasSuffix("n")
    }

    var displayCityName: String {
        cityName.isEmpty ? "Unknown Location" : cityName
    }
}

// MARK: - API Response DTO

struct OpenWeatherResponse: Decodable, Sendable {
    let coord: CoordDTO
    let weather: [WeatherDTO]
    let main: MainDTO
    let visibility: Int?
    let wind: WindDTO
    let sys: SysDTO
    let name: String

    struct CoordDTO: Decodable, Sendable {
        let lon: Double
        let lat: Double
    }

    struct WeatherDTO: Decodable, Sendable {
        let id: Int
        let description: String
        let icon: String
    }

    struct MainDTO: Decodable, Sendable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let pressure: Int
        let humidity: Int

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure
            case humidity
        }
    }

    struct WindDTO: Decodable, Sendable {
        let speed: Double
    }

    struct SysDTO: Decodable, Sendable {
        let country: String?
        let sunrise: TimeInterval
        let sunset: TimeInterval
    }

    func toWeatherData() -> WeatherData {
        WeatherData(
            cityName: name,
            temperature: main.temp,
            feelsLike: main.feelsLike,
            tempMin: main.tempMin,
            tempMax: main.tempMax,
            humidity: main.humidity,
            windSpeed: wind.speed,
            pressure: main.pressure,
            visibility: visibility ?? 0,
            description: weather.first?.description.capitalized ?? "",
            conditionCode: weather.first?.id ?? 800,
            iconCode: weather.first?.icon ?? "01d",
            coordinate: Coordinate(latitude: coord.lat, longitude: coord.lon),
            sunrise: Date(timeIntervalSince1970: sys.sunrise),
            sunset: Date(timeIntervalSince1970: sys.sunset),
            countryCode: sys.country ?? ""
        )
    }
}

enum LoadingState: Equatable, Sendable {
    case idle
    case loading
    case loaded
    case error(String)
}
