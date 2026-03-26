import Foundation
import SwiftData

@Model
final class PersistedLocation {
    @Attribute(.unique) var id: UUID
    var latitude: Double
    var longitude: Double
    var order: Int
    var createdAt: Date

    init(id: UUID, coordinate: Coordinate, order: Int) {
        self.id = id
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.order = order
        self.createdAt = .now
    }

    var coordinate: Coordinate {
        Coordinate(latitude: latitude, longitude: longitude)
    }
}
