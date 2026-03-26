import ComposableArchitecture
import Foundation

@DependencyClient
struct WeatherClient: Sendable {
    var fetchWeather: @Sendable (Coordinate) async throws -> WeatherData
}

extension WeatherClient: DependencyKey {
    static let liveValue = WeatherClient(
        fetchWeather: { coordinate in
            var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!
            components.queryItems = [
                URLQueryItem(name: "lat", value: "\(coordinate.latitude)"),
                URLQueryItem(name: "lon", value: "\(coordinate.longitude)"),
                URLQueryItem(name: "appid", value: Secrets.openWeatherMapAPIKey),
                URLQueryItem(name: "units", value: "metric"),
            ]

            let (data, response) = try await URLSession.shared.data(from: components.url!)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw WeatherClientError.invalidResponse
            }

            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(OpenWeatherResponse.self, from: data)
            return apiResponse.toWeatherData()
        }
    )

    static let previewValue = WeatherClient(
        fetchWeather: { _ in
            WeatherData(
                cityName: "Madrid",
                temperature: 24.5,
                feelsLike: 23.0,
                tempMin: 20.0,
                tempMax: 28.0,
                humidity: 45,
                windSpeed: 5.2,
                pressure: 1013,
                visibility: 10000,
                description: "Clear Sky",
                conditionCode: 800,
                iconCode: "01d",
                coordinate: Coordinate(latitude: 40.4168, longitude: -3.7038),
                sunrise: Date(),
                sunset: Date().addingTimeInterval(43200),
                countryCode: "ES"
            )
        }
    )
}

enum WeatherClientError: Error, LocalizedError, Sendable {
    case invalidResponse
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "The server returned an invalid response."
        case .decodingError: "Unable to read weather data."
        }
    }
}

extension DependencyValues {
    var weatherClient: WeatherClient {
        get { self[WeatherClient.self] }
        set { self[WeatherClient.self] = newValue }
    }
}
