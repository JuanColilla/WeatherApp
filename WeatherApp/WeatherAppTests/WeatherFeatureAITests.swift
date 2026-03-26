import ComposableArchitecture
import Foundation
import Testing
@testable import WeatherApp

// MARK: - Suite

@MainActor
@Suite("WeatherFeature AI Quote Tests")
struct WeatherFeatureAITests {

    // MARK: - Test 1: Weather load triggers AI quote generation

    @Test("Weather load success triggers AI quote generation flow")
    func weatherLoadTriggersAIQuoteGeneration() async {
        let expectedQuote = "Madrid sun: bring shades, not sunscreen — you'll be fine."

        let store = TestStore(
            initialState: WeatherFeature.State(
                id: UUID(),
                coordinate: fixtureCoordMadrid
            )
        ) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { _ in fixtureWeatherMadrid }
            $0.cacheClient.get = { _ in nil }
            $0.cacheClient.set = { _, _ in }
            $0.intelligenceClient.checkAvailability = { .idle }
            $0.intelligenceClient.generateQuote = { _ in expectedQuote }
        }

        await store.send(.fetchWeather) {
            $0.loadingState = .loading
        }

        await store.receive(\.weatherResponse.success) {
            $0.weather = fixtureWeatherMadrid
            $0.loadingState = .loaded
        }

        await store.receive(\.generateAIQuote) {
            $0.aiQuoteState = .generating
        }

        await store.receive(\.aiQuoteGenerated.success) {
            $0.aiQuoteState = .generated(expectedQuote)
            $0.lastQuoteCacheKey = $0.weatherCacheKey
        }
    }

    // MARK: - Test 2: AI unavailable sets unavailable state

    @Test("AI unavailable sets unavailable state with reason")
    func aiUnavailableSetsUnavailableState() async {
        let unavailableReason = "Apple Intelligence is not available"

        let store = TestStore(
            initialState: WeatherFeature.State(
                id: UUID(),
                coordinate: fixtureCoordMadrid,
                weather: fixtureWeatherMadrid,
                loadingState: .loaded
            )
        ) {
            WeatherFeature()
        } withDependencies: {
            $0.intelligenceClient.checkAvailability = { .unavailable(unavailableReason) }
            $0.intelligenceClient.generateQuote = { _ in
                Issue.record("generateQuote should not be called when AI is unavailable")
                return ""
            }
        }

        await store.send(.generateAIQuote) {
            $0.aiQuoteState = .generating
        }

        await store.receive(\.aiQuoteGenerated.failure) {
            $0.aiQuoteState = .unavailable(unavailableReason)
        }
    }

    // MARK: - Test 3: Cache hit skips AI generation

    @Test("Cache hit skips AI generation — no effects emitted")
    func cacheHitSkipsAIGeneration() async {
        let cachedQuote = "Already generated — still great advice."

        // Build a state that already has a generated quote matching the current weather cache key.
        var initialState = WeatherFeature.State(
            id: UUID(),
            coordinate: fixtureCoordMadrid,
            weather: fixtureWeatherMadrid,
            loadingState: .loaded,
            aiQuoteState: .generated(cachedQuote)
        )
        // Pre-populate lastQuoteCacheKey to match the computed weatherCacheKey.
        initialState.lastQuoteCacheKey = initialState.weatherCacheKey

        let store = TestStore(initialState: initialState) {
            WeatherFeature()
        }

        // Sending generateAIQuote should produce no state changes and no effects
        // because the cache key matches the generated state.
        await store.send(.generateAIQuote)
    }

    // MARK: - Test 4: Refresh clears cache and regenerates

    @Test("Refresh clears cache key and triggers regeneration")
    func refreshClearsAndRegenerates() async {
        let oldQuote = "Old stale wisdom."
        let newQuote = "Fresh hot take from the AI."

        var initialState = WeatherFeature.State(
            id: UUID(),
            coordinate: fixtureCoordMadrid,
            weather: fixtureWeatherMadrid,
            loadingState: .loaded,
            aiQuoteState: .generated(oldQuote)
        )
        initialState.lastQuoteCacheKey = initialState.weatherCacheKey

        let store = TestStore(initialState: initialState) {
            WeatherFeature()
        } withDependencies: {
            $0.intelligenceClient.checkAvailability = { .idle }
            $0.intelligenceClient.generateQuote = { _ in newQuote }
        }

        await store.send(.refreshAIQuote) {
            $0.lastQuoteCacheKey = nil
        }

        await store.receive(\.generateAIQuote) {
            $0.aiQuoteState = .generating
        }

        await store.receive(\.aiQuoteGenerated.success) {
            $0.aiQuoteState = .generated(newQuote)
            $0.lastQuoteCacheKey = $0.weatherCacheKey
        }
    }

    // MARK: - Test 5: Weather data change invalidates cache and regenerates

    @Test("Weather data change invalidates cache and triggers regeneration")
    func weatherDataChangeInvalidatesCacheAndRegenerates() async {
        let staleQuote = "Quote about old weather."
        let freshQuote = "Quote about rainy Madrid."

        let newWeather = WeatherData(
            cityName: "Madrid",
            temperature: 14.0,      // Different temperature
            feelsLike: 12.0,
            tempMin: 10.0,
            tempMax: 16.0,
            humidity: 85,           // Different humidity
            windSpeed: 6.0,
            pressure: 1008,
            visibility: 5000,
            description: "Heavy rain",
            conditionCode: 501,     // Different condition code
            iconCode: "10d",
            coordinate: fixtureCoordMadrid,
            sunrise: Date(timeIntervalSince1970: 1_700_000_000),
            sunset: Date(timeIntervalSince1970: 1_700_050_000),
            countryCode: "ES"
        )

        // State has a generated quote from old weather (fixtureWeatherMadrid)
        var staleState = WeatherFeature.State(
            id: UUID(),
            coordinate: fixtureCoordMadrid,
            weather: fixtureWeatherMadrid,
            loadingState: .loaded,
            aiQuoteState: .generated(staleQuote)
        )
        staleState.lastQuoteCacheKey = staleState.weatherCacheKey  // key matches old weather

        let store = TestStore(initialState: staleState) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { _ in newWeather }
            $0.cacheClient.get = { _ in nil }
            $0.cacheClient.set = { _, _ in }
            $0.intelligenceClient.checkAvailability = { .idle }
            $0.intelligenceClient.generateQuote = { _ in freshQuote }
        }

        // Simulate a weather refresh that delivers new weather data
        await store.send(.fetchWeather) {
            $0.loadingState = .loading
        }

        await store.receive(\.weatherResponse.success) {
            $0.weather = newWeather
            $0.loadingState = .loaded
        }

        // generateAIQuote is triggered automatically after weatherResponse
        // lastQuoteCacheKey (old) != weatherCacheKey (new) → cache is invalid → regenerate
        await store.receive(\.generateAIQuote) {
            $0.aiQuoteState = .generating
        }

        await store.receive(\.aiQuoteGenerated.success) {
            $0.aiQuoteState = .generated(freshQuote)
            $0.lastQuoteCacheKey = $0.weatherCacheKey
        }
    }

    // MARK: - Test 6: Generation error sets unavailable state

    @Test("AI generation error sets unavailable state with error message")
    func generationErrorSetsUnavailableState() async {
        let store = TestStore(
            initialState: WeatherFeature.State(
                id: UUID(),
                coordinate: fixtureCoordMadrid,
                weather: fixtureWeatherMadrid,
                loadingState: .loaded
            )
        ) {
            WeatherFeature()
        } withDependencies: {
            $0.intelligenceClient.checkAvailability = { .idle }
            $0.intelligenceClient.generateQuote = { _ in
                throw IntelligenceError.generationFailed("Model busy")
            }
        }

        await store.send(.generateAIQuote) {
            $0.aiQuoteState = .generating
        }

        await store.receive(\.aiQuoteGenerated.failure) {
            $0.aiQuoteState = .unavailable("Model busy")
        }
    }
}
