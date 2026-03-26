import ComposableArchitecture
import Foundation
import Testing
@testable import WeatherApp

// MARK: - Fixtures

private let primaryItem = ManageLocationsFeature.LocationItem(
    id: fixtureUUID_A,
    cityName: "Madrid",
    temperature: "22°C",
    conditionDescription: "Clear sky",
    condition: .clear,
    isNight: false,
    isPrimary: true
)

private let secondaryItem = ManageLocationsFeature.LocationItem(
    id: fixtureUUID_B,
    cityName: "Paris",
    temperature: "18°C",
    conditionDescription: "Clouds",
    condition: .clouds,
    isNight: false,
    isPrimary: false
)

// MARK: - Suite

@MainActor
@Suite("ManageLocationsFeature Tests")
struct ManageLocationsFeatureTests {

    // MARK: - Test 1: Delete non-primary location → removes it from locations array

    @Test("deleteLocation with non-primary removes it from the locations array")
    func deleteLocation_nonPrimary_removesFromArray() async {
        let initialState = ManageLocationsFeature.State(
            locations: [primaryItem, secondaryItem]
        )

        let store = TestStore(initialState: initialState) {
            ManageLocationsFeature()
        }

        await store.send(.deleteLocation(id: fixtureUUID_B)) {
            $0.locations = [primaryItem]
        }
    }

    // MARK: - Test 2: Delete primary location → no-op (guard prevents deletion)

    @Test("deleteLocation with primary location is a no-op")
    func deleteLocation_primaryLocation_isNoOp() async {
        let initialState = ManageLocationsFeature.State(
            locations: [primaryItem, secondaryItem]
        )

        let store = TestStore(initialState: initialState) {
            ManageLocationsFeature()
        }

        await store.send(.deleteLocation(id: fixtureUUID_A))
    }

    // MARK: - Test 3: doneTapped → triggers dismiss effect

    @Test("doneTapped triggers the dismiss effect")
    func doneTapped_triggersDismiss() async {
        let store = TestStore(initialState: ManageLocationsFeature.State()) {
            ManageLocationsFeature()
        } withDependencies: {
            $0.dismiss = DismissEffect { }
        }

        await store.send(.doneTapped)
        await store.finish()
    }

    // MARK: - Test 4: addRandomLocation → returns .none (delegated to parent)

    @Test("addRandomLocation returns .none and produces no state changes")
    func addRandomLocation_isPassthrough_noStateChanges() async {
        let initialState = ManageLocationsFeature.State(
            locations: [primaryItem, secondaryItem]
        )

        let store = TestStore(initialState: initialState) {
            ManageLocationsFeature()
        }

        await store.send(.addRandomLocation)
    }
}
