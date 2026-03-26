import ComposableArchitecture
import Foundation
import SwiftData

/// Sendable DTO to cross isolation boundaries (SwiftData @Model is not Sendable)
struct PersistedLocationDTO: Sendable {
    let id: UUID
    let coordinate: Coordinate
    let order: Int
}

@DependencyClient
struct PersistenceClient: Sendable {
    var loadLocations: @Sendable () async throws -> [PersistedLocationDTO] = { [] }
    var saveLocation: @Sendable (UUID, Coordinate, Int) async throws -> Void = { _, _, _ in }
    var deleteLocation: @Sendable (UUID) async throws -> Void = { _ in }
}

extension PersistenceClient: DependencyKey {
    static let liveValue: PersistenceClient = {
        let container = try! ModelContainer(for: PersistedLocation.self)

        return PersistenceClient(
            loadLocations: {
                await MainActor.run {
                    let context = container.mainContext
                    let descriptor = FetchDescriptor<PersistedLocation>(
                        sortBy: [SortDescriptor(\.order)]
                    )
                    let results = (try? context.fetch(descriptor)) ?? []
                    return results.map {
                        PersistedLocationDTO(id: $0.id, coordinate: $0.coordinate, order: $0.order)
                    }
                }
            },
            saveLocation: { id, coordinate, order in
                await MainActor.run {
                    let context = container.mainContext
                    let location = PersistedLocation(id: id, coordinate: coordinate, order: order)
                    context.insert(location)
                    try? context.save()
                }
            },
            deleteLocation: { id in
                await MainActor.run {
                    let context = container.mainContext
                    // Avoid #Predicate — Xcode 26 reflection metadata bugs
                    let descriptor = FetchDescriptor<PersistedLocation>()
                    if let location = (try? context.fetch(descriptor))?.first(where: { $0.id == id }) {
                        context.delete(location)
                        try? context.save()
                    }
                }
            }
        )
    }()

    static let previewValue = PersistenceClient()
}

extension DependencyValues {
    var persistenceClient: PersistenceClient {
        get { self[PersistenceClient.self] }
        set { self[PersistenceClient.self] = newValue }
    }
}
