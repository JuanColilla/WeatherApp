import ComposableArchitecture
import Foundation
import Testing
@testable import WeatherApp

// MARK: - Suite

@MainActor
@Suite("WeatherListFeature Tests")
struct WeatherListFeatureTests {

    // MARK: - Test 1: onAppear with no persisted locations → triggers addRandomLocation

    @Test("onAppear with no persisted locations triggers addRandomLocation")
    func onAppear_noPersistedLocations_triggersAddRandomLocation() async {
        let generatedCoord = fixtureCoordMadrid

        let store = TestStore(initialState: WeatherListFeature.State()) {
            WeatherListFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.locationGenerator.generate = { generatedCoord }
            $0.persistenceClient.loadLocations = { [] }
            $0.persistenceClient.saveLocation = { _, _, _ in }
            $0.weatherClient.fetchWeather = { _ in fixtureWeatherMadrid }
            $0.cacheClient.get = { _ in nil }
            $0.cacheClient.set = { _, _ in }
            $0.intelligenceClient.checkAvailability = { .idle }
            $0.intelligenceClient.generateQuote = { _ in "" }
        }

        // Child WeatherFeature effects (fetch, AI generation) are not the focus here
        store.exhaustivity = .off

        await store.send(.onAppear)

        // loadLocations returns [] → reducer sends .addRandomLocation
        await store.receive(\.addRandomLocation) {
            let expectedID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
            $0.locations = [WeatherFeature.State(id: expectedID, coordinate: generatedCoord)]
            $0.selectedIndex = 0
        }
    }

    // MARK: - Test 2: onAppear with persisted locations → restores them and triggers fetchWeather

    @Test("onAppear with persisted locations restores each location and fetches weather")
    func onAppear_withPersistedLocations_restoresAndFetchesWeather() async {
        let idA = fixtureUUID_A
        let idB = fixtureUUID_B

        let persisted = [
            PersistedLocationDTO(id: idA, coordinate: fixtureCoordMadrid, order: 0),
            PersistedLocationDTO(id: idB, coordinate: fixtureCoordParis, order: 1),
        ]

        let store = TestStore(initialState: WeatherListFeature.State()) {
            WeatherListFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.persistenceClient.loadLocations = { persisted }
            $0.weatherClient.fetchWeather = { _ in fixtureWeatherMadrid }
            $0.cacheClient.get = { _ in nil }
            $0.cacheClient.set = { _, _ in }
            $0.intelligenceClient.checkAvailability = { .idle }
            $0.intelligenceClient.generateQuote = { _ in "" }
        }

        // Skip child WeatherFeature downstream effects
        store.exhaustivity = .off

        await store.send(.onAppear)

        // First persisted location is restored
        await store.receive(\.restoreLocation) {
            $0.locations = [WeatherFeature.State(id: idA, coordinate: fixtureCoordMadrid)]
        }

        // Second persisted location is restored
        // By now, child fetchWeather for A has been processed between receives,
        // setting locA.loadingState = .loading
        await store.receive(\.restoreLocation) {
            $0.locations[id: idA]?.loadingState = .loading
            $0.locations.append(WeatherFeature.State(id: idB, coordinate: fixtureCoordParis))
        }
    }

    // MARK: - Test 3: addRandomLocation → appends, selects last, triggers fetchWeather + save

    @Test("addRandomLocation appends location, selects it, and triggers fetchWeather + persistence save")
    func addRandomLocation_appendsAndSelectsLastWithSideEffects() async {
        let generatedCoord = fixtureCoordParis
        let savedID = LockIsolated<UUID?>(nil)
        let savedCoord = LockIsolated<Coordinate?>(nil)
        let savedOrder = LockIsolated<Int?>(nil)

        let store = TestStore(initialState: WeatherListFeature.State()) {
            WeatherListFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.locationGenerator.generate = { generatedCoord }
            $0.persistenceClient.saveLocation = { id, coord, order in
                savedID.setValue(id)
                savedCoord.setValue(coord)
                savedOrder.setValue(order)
            }
            $0.weatherClient.fetchWeather = { _ in fixtureWeatherMadrid }
            $0.cacheClient.get = { _ in nil }
            $0.cacheClient.set = { _, _ in }
            $0.intelligenceClient.checkAvailability = { .idle }
            $0.intelligenceClient.generateQuote = { _ in "" }
        }

        // Skip child WeatherFeature downstream effects triggered by .fetchWeather
        store.exhaustivity = .off

        let expectedID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

        await store.send(.addRandomLocation) {
            $0.locations = [WeatherFeature.State(id: expectedID, coordinate: generatedCoord)]
            $0.selectedIndex = 0
        }

        // Allow async persistence effect to complete
        await store.finish()

        #expect(savedID.value == expectedID)
        #expect(savedCoord.value == generatedCoord)
        #expect(savedOrder.value == 0)
    }

    // MARK: - Test 4: removeLocation → removes, adjusts selectedIndex, cancels effects, triggers delete

    @Test("removeLocation removes location, adjusts selectedIndex, and triggers persistence delete")
    func removeLocation_removesAndAdjustsIndex() async {
        let idA = fixtureUUID_A
        let idB = fixtureUUID_B

        let deletedID = LockIsolated<UUID?>(nil)

        // Pre-populate state with two locations, selecting the second one
        let initialState = WeatherListFeature.State(
            locations: [
                WeatherFeature.State(id: idA, coordinate: fixtureCoordMadrid),
                WeatherFeature.State(id: idB, coordinate: fixtureCoordParis),
            ],
            selectedIndex: 1
        )

        let store = TestStore(initialState: initialState) {
            WeatherListFeature()
        } withDependencies: {
            $0.persistenceClient.deleteLocation = { id in
                deletedID.setValue(id)
            }
        }

        store.exhaustivity = .off

        await store.send(.removeLocation(id: idB)) {
            // idB is removed; only idA remains
            $0.locations = [WeatherFeature.State(id: idA, coordinate: fixtureCoordMadrid)]
            // selectedIndex was 1, count is now 1 → clamped to 0
            $0.selectedIndex = 0
        }

        await store.finish()

        #expect(deletedID.value == idB)
    }

    // MARK: - Test 5: selectPage → updates selectedIndex

    @Test("selectPage updates selectedIndex")
    func selectPage_updatesSelectedIndex() async {
        let idA = fixtureUUID_A
        let idB = fixtureUUID_B

        let initialState = WeatherListFeature.State(
            locations: [
                WeatherFeature.State(id: idA, coordinate: fixtureCoordMadrid),
                WeatherFeature.State(id: idB, coordinate: fixtureCoordParis),
            ],
            selectedIndex: 0
        )

        let store = TestStore(initialState: initialState) {
            WeatherListFeature()
        }

        await store.send(.selectPage(1)) {
            $0.selectedIndex = 1
        }
    }

    // MARK: - Test 6: pullToRefresh interception → generates new coordinate, sends refreshLocation, updates persistence

    @Test("Pull-to-refresh generates new coordinate, sends refreshLocation to child, and updates persistence")
    func pullToRefresh_generatesNewCoordAndUpdates() async {
        let idA = fixtureUUID_A
        let savedCoord = LockIsolated<Coordinate?>(nil)
        let savedOrder = LockIsolated<Int?>(nil)

        // Start with a loaded location
        var locA = WeatherFeature.State(id: idA, coordinate: fixtureCoordMadrid)
        locA.weather = fixtureWeatherMadrid
        locA.loadingState = .loaded

        let initialState = WeatherListFeature.State(
            locations: [locA],
            selectedIndex: 0
        )

        let store = TestStore(initialState: initialState) {
            WeatherListFeature()
        } withDependencies: {
            $0.locationGenerator.generate = { fixtureCoordParis }
            $0.persistenceClient.saveLocation = { _, coord, order in
                savedCoord.setValue(coord)
                savedOrder.setValue(order)
            }
            $0.weatherClient.fetchWeather = { _ in fixtureWeatherParis }
            $0.cacheClient.remove = { _ in }
            $0.cacheClient.set = { _, _ in }
            $0.intelligenceClient.checkAvailability = { .idle }
            $0.intelligenceClient.generateQuote = { _ in "" }
        }

        store.exhaustivity = .off

        // Parent sends pullToRefresh — child returns .none, parent intercepts
        await store.send(.locations(.element(id: idA, action: .pullToRefresh)))

        // Parent generates Paris coordinate and sends refreshLocation to child
        await store.receive(\.locations) {
            $0.locations[id: idA]?.coordinate = fixtureCoordParis
            $0.locations[id: idA]?.weather = nil
            $0.locations[id: idA]?.loadingState = .loading
            $0.locations[id: idA]?.aiQuoteState = .idle
            $0.locations[id: idA]?.lastQuoteCacheKey = nil
        }

        await store.finish()

        #expect(savedCoord.value == fixtureCoordParis)
        #expect(savedOrder.value == 0)
    }

    // MARK: - Test 7: modal addRandomLocation → adds location and dismisses modal

    @Test("Modal addRandomLocation adds location, selects it, and dismisses modal")
    func modalAddRandomLocation_addsAndDismisses() async {
        let idA = fixtureUUID_A
        var locA = WeatherFeature.State(id: idA, coordinate: fixtureCoordMadrid)
        locA.weather = fixtureWeatherMadrid
        locA.loadingState = .loaded

        let initialState = WeatherListFeature.State(
            locations: [locA],
            selectedIndex: 0,
            manageLocations: ManageLocationsFeature.State(
                locations: [
                    ManageLocationsFeature.LocationItem(
                        id: idA,
                        cityName: "Madrid",
                        temperature: "22°C",
                        conditionDescription: "Clear sky",
                        condition: .clear,
                        isNight: false,
                        isPrimary: true
                    )
                ]
            )
        )

        let store = TestStore(initialState: initialState) {
            WeatherListFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.locationGenerator.generate = { fixtureCoordParis }
            $0.persistenceClient.saveLocation = { _, _, _ in }
            $0.weatherClient.fetchWeather = { _ in fixtureWeatherParis }
            $0.cacheClient.get = { _ in nil }
            $0.cacheClient.set = { _, _ in }
            $0.intelligenceClient.checkAvailability = { .idle }
            $0.intelligenceClient.generateQuote = { _ in "" }
        }

        store.exhaustivity = .off

        let expectedID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

        await store.send(.manageLocations(.presented(.addRandomLocation))) {
            $0.locations.append(WeatherFeature.State(id: expectedID, coordinate: fixtureCoordParis))
            $0.selectedIndex = 1
            // Modal is dismissed so the user sees the new location on the main screen
            $0.manageLocations = nil
        }
    }

    // MARK: - Test 8: manageLocationsTapped → creates ManageLocationsFeature.State from current locations

    @Test("manageLocationsTapped creates ManageLocationsFeature.State mapped from current locations")
    func manageLocationsTapped_populatesManageLocationsState() async {
        let idA = fixtureUUID_A
        let idB = fixtureUUID_B

        var locA = WeatherFeature.State(id: idA, coordinate: fixtureCoordMadrid)
        locA.weather = fixtureWeatherMadrid
        locA.loadingState = .loaded

        // Second location has no weather loaded yet
        let locB = WeatherFeature.State(id: idB, coordinate: fixtureCoordParis)

        let initialState = WeatherListFeature.State(
            locations: [locA, locB],
            selectedIndex: 0
        )

        let store = TestStore(initialState: initialState) {
            WeatherListFeature()
        }

        await store.send(.manageLocationsTapped) {
            $0.manageLocations = ManageLocationsFeature.State(
                locations: [
                    ManageLocationsFeature.LocationItem(
                        id: idA,
                        cityName: "Madrid",
                        temperature: "\(Int(fixtureWeatherMadrid.temperature.rounded()))°C",
                        conditionDescription: fixtureWeatherMadrid.description,
                        condition: fixtureWeatherMadrid.condition,
                        isNight: fixtureWeatherMadrid.isNight,
                        isPrimary: true
                    ),
                    ManageLocationsFeature.LocationItem(
                        id: idB,
                        cityName: "Loading...",
                        temperature: "--",
                        conditionDescription: "",
                        condition: .clear,
                        isNight: false,
                        isPrimary: false
                    ),
                ]
            )
        }
    }
}
