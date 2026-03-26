import Foundation

struct Coordinate: Equatable, Codable, Sendable, Hashable {
    let latitude: Double
    let longitude: Double

    var cacheKey: String {
        let lat = (latitude * 10).rounded() / 10
        let lon = (longitude * 10).rounded() / 10
        return "\(lat),\(lon)"
    }

    var formattedLatitude: String {
        let direction = latitude >= 0 ? "N" : "S"
        return String(format: "%.4f° %@", abs(latitude), direction)
    }

    var formattedLongitude: String {
        let direction = longitude >= 0 ? "E" : "W"
        return String(format: "%.4f° %@", abs(longitude), direction)
    }
}
