import ComposableArchitecture
import Foundation

@Reducer
struct WeatherFeature {
    @ObservableState
    struct State: Equatable, Identifiable, Sendable {
        /// Increment when AI prompt logic changes to invalidate cached quotes.
        static let promptVersion = 2
        let id: UUID
        var coordinate: Coordinate
        var weather: WeatherData?
        var loadingState: LoadingState = .idle
        var aiQuoteState: AIQuoteState = .idle
        var lastQuoteCacheKey: String?

        var weatherCacheKey: String? {
            guard let w = weather else { return nil }
            return "v\(Self.promptVersion)-\(w.displayCityName)-\(Int(w.temperature.rounded()))-\(w.conditionCode)-\(w.humidity)-\(Int(w.feelsLike.rounded()))-\(Int(w.windSpeed * 10))-\(w.pressure)"
        }
    }

    enum Action: Equatable, Sendable {
        case fetchWeather
        case weatherResponse(Result<WeatherData, WeatherError>)
        case retryFetch
        case pullToRefresh
        case refreshLocation(Coordinate)
        // AI
        case generateAIQuote
        case aiQuoteGenerated(Result<String, WeatherError>)
        case refreshAIQuote
    }

    struct WeatherError: Error, Equatable, Sendable {
        let message: String

        init(_ error: any Error) {
            self.message = error.localizedDescription
        }

        init(message: String) {
            self.message = message
        }
    }

    @Dependency(\.weatherClient) var weatherClient
    @Dependency(\.cacheClient) var cacheClient
    @Dependency(\.intelligenceClient) var intelligenceClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchWeather:
                state.loadingState = .loading
                let coordinate = state.coordinate
                let id = state.id

                return .run { send in
                    if let cached = await cacheClient.get(coordinate.cacheKey) {
                        await send(.weatherResponse(.success(cached)))
                        return
                    }

                    do {
                        let weather = try await weatherClient.fetchWeather(coordinate)
                        await cacheClient.set(coordinate.cacheKey, weather)
                        await send(.weatherResponse(.success(weather)))
                    } catch {
                        await send(.weatherResponse(.failure(WeatherError(error))))
                    }
                }
                .cancellable(id: id, cancelInFlight: true)

            case let .weatherResponse(.success(weather)):
                state.weather = weather
                state.loadingState = .loaded
                return .send(.generateAIQuote)

            case let .weatherResponse(.failure(error)):
                state.loadingState = .error(error.message)
                return .none

            case .retryFetch:
                return .send(.fetchWeather)

            case .pullToRefresh:
                // Handled by parent (WeatherListFeature) which generates a new coordinate
                // and sends .refreshLocation(newCoordinate) back
                return .none

            case let .refreshLocation(newCoordinate):
                let oldCacheKey = state.coordinate.cacheKey
                state.coordinate = newCoordinate
                state.weather = nil
                state.loadingState = .loading
                state.aiQuoteState = .idle
                state.lastQuoteCacheKey = nil
                let coordinate = state.coordinate
                let id = state.id

                return .run { [cacheClient, weatherClient] send in
                    await cacheClient.remove(oldCacheKey)
                    do {
                        let weather = try await weatherClient.fetchWeather(coordinate)
                        await cacheClient.set(coordinate.cacheKey, weather)
                        await send(.weatherResponse(.success(weather)))
                    } catch {
                        await send(.weatherResponse(.failure(WeatherError(error))))
                    }
                }
                .cancellable(id: id, cancelInFlight: true)

            case .generateAIQuote:
                guard let weather = state.weather else { return .none }
                let cacheKey = state.weatherCacheKey
                if case .generated = state.aiQuoteState, state.lastQuoteCacheKey == cacheKey {
                    return .none
                }
                state.aiQuoteState = .generating
                return .run { send in
                    let availability = await intelligenceClient.checkAvailability()
                    if case let .unavailable(reason) = availability {
                        await send(.aiQuoteGenerated(.failure(WeatherError(message: reason))))
                        return
                    }
                    do {
                        let quote = try await intelligenceClient.generateQuote(weather)
                        await send(.aiQuoteGenerated(.success(quote)))
                    } catch {
                        await send(.aiQuoteGenerated(.failure(WeatherError(error))))
                    }
                }

            case let .aiQuoteGenerated(.success(quote)):
                state.aiQuoteState = .generated(quote)
                state.lastQuoteCacheKey = state.weatherCacheKey
                return .none

            case let .aiQuoteGenerated(.failure(error)):
                state.aiQuoteState = .unavailable(error.message)
                return .none

            case .refreshAIQuote:
                state.lastQuoteCacheKey = nil
                return .send(.generateAIQuote)
            }
        }
    }
}
