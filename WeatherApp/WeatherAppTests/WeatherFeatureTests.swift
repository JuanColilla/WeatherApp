import ComposableArchitecture
import Foundation
import Testing
@testable import WeatherApp

// MARK: - Suite

@MainActor
@Suite("WeatherFeature Core Weather Fetch Tests")
struct WeatherFeatureTests {

    // MARK: - Test 1: Happy path — no cache, API call succeeds

    @Test("Happy path: no cache hit → API call → loaded state + generateAIQuote triggered")
    func happyPath_noCacheAPICallSucceeds() async {
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
            $0.intelligenceClient.generateQuote = { _ in "" }
        }

        // Skip downstream AI effects — we're only testing the weather fetch flow
        store.exhaustivity = .off

        await store.send(.fetchWeather) {
            $0.loadingState = .loading
        }

        await store.receive(\.weatherResponse.success) {
            $0.weather = fixtureWeatherMadrid
            $0.loadingState = .loaded
        }
    }

    // MARK: - Test 2: Cache hit — no API call made

    @Test("Cache hit: returns cached data without calling the API")
    func cacheHit_returnsDataWithoutAPICall() async {
        let store = TestStore(
            initialState: WeatherFeature.State(
                id: UUID(),
                coordinate: fixtureCoordMadrid
            )
        ) {
            WeatherFeature()
        } withDependencies: {
            $0.cacheClient.get = { _ in fixtureWeatherMadrid }
            $0.cacheClient.set = { _, _ in }
            $0.weatherClient.fetchWeather = { _ in
                Issue.record("fetchWeather should not be called on cache hit")
                throw WeatherClientError.invalidResponse
            }
            $0.intelligenceClient.checkAvailability = { .idle }
            $0.intelligenceClient.generateQuote = { _ in "" }
        }

        store.exhaustivity = .off

        await store.send(.fetchWeather) {
            $0.loadingState = .loading
        }

        await store.receive(\.weatherResponse.success) {
            $0.weather = fixtureWeatherMadrid
            $0.loadingState = .loaded
        }
    }

    // MARK: - Test 3: Fetch error — error state set

    @Test("Fetch error: API throws → error loading state")
    func fetchError_setsErrorState() async {
        let store = TestStore(
            initialState: WeatherFeature.State(
                id: UUID(),
                coordinate: fixtureCoordMadrid
            )
        ) {
            WeatherFeature()
        } withDependencies: {
            $0.cacheClient.get = { _ in nil }
            $0.weatherClient.fetchWeather = { _ in throw WeatherClientError.invalidResponse }
        }

        await store.send(.fetchWeather) {
            $0.loadingState = .loading
        }

        await store.receive(\.weatherResponse.failure) {
            $0.loadingState = .error(WeatherClientError.invalidResponse.localizedDescription)
        }
    }

    // MARK: - Test 4: refreshLocation — resets state, updates coordinate, fetches fresh

    @Test("refreshLocation resets state, invalidates cache, and fetches weather for new coordinate")
    func refreshLocation_resetsAndFetchesFresh() async {
        let removedCacheKey = LockIsolated<String?>(nil)

        // Start with a loaded state for Madrid
        var initialState = WeatherFeature.State(
            id: fixtureUUID_A,
            coordinate: fixtureCoordMadrid,
            weather: fixtureWeatherMadrid,
            loadingState: .loaded,
            aiQuoteState: .generated("Old quote")
        )
        initialState.lastQuoteCacheKey = initialState.weatherCacheKey

        let store = TestStore(initialState: initialState) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { _ in fixtureWeatherParis }
            $0.cacheClient.remove = { key in removedCacheKey.setValue(key) }
            $0.cacheClient.set = { _, _ in }
            $0.intelligenceClient.checkAvailability = { .idle }
            $0.intelligenceClient.generateQuote = { _ in "New quote" }
        }

        store.exhaustivity = .off

        let oldCacheKey = fixtureCoordMadrid.cacheKey

        await store.send(.refreshLocation(fixtureCoordParis)) {
            $0.coordinate = fixtureCoordParis
            $0.weather = nil
            $0.loadingState = .loading
            $0.aiQuoteState = .idle
            $0.lastQuoteCacheKey = nil
        }

        await store.receive(\.weatherResponse.success) {
            $0.weather = fixtureWeatherParis
            $0.loadingState = .loaded
        }

        // Verify old cache entry was invalidated
        #expect(removedCacheKey.value == oldCacheKey)
    }

    // MARK: - Test 5: pullToRefresh — returns .none (parent handles)

    @Test("pullToRefresh returns .none and produces no state changes")
    func pullToRefresh_returnsNone() async {
        let store = TestStore(
            initialState: WeatherFeature.State(
                id: fixtureUUID_A,
                coordinate: fixtureCoordMadrid
            )
        ) {
            WeatherFeature()
        }

        await store.send(.pullToRefresh)
    }

    // MARK: - Test 6: Retry — sends fetchWeather

    @Test("Retry: retryFetch sends fetchWeather action")
    func retry_sendsFetchWeather() async {
        let store = TestStore(
            initialState: WeatherFeature.State(
                id: UUID(),
                coordinate: fixtureCoordMadrid
            )
        ) {
            WeatherFeature()
        } withDependencies: {
            $0.cacheClient.get = { _ in nil }
            $0.cacheClient.set = { _, _ in }
            $0.weatherClient.fetchWeather = { _ in fixtureWeatherMadrid }
            $0.intelligenceClient.checkAvailability = { .idle }
            $0.intelligenceClient.generateQuote = { _ in "" }
        }

        store.exhaustivity = .off

        await store.send(.retryFetch)

        await store.receive(\.fetchWeather) {
            $0.loadingState = .loading
        }
    }
}
