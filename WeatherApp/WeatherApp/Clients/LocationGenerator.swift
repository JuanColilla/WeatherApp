import ComposableArchitecture
import Foundation

@DependencyClient
struct LocationGenerator: Sendable {
    var generate: @Sendable () -> Coordinate = {
        Coordinate(latitude: 0, longitude: 0)
    }
}

extension LocationGenerator: DependencyKey {
    static let liveValue = LocationGenerator(
        generate: {
            let latitude = Double.random(in: -90...90)
            let longitude = Double.random(in: -180...180)
            return Coordinate(latitude: latitude, longitude: longitude)
        }
    )

    static let previewValue = LocationGenerator(
        generate: {
            Coordinate(latitude: 40.4168, longitude: -3.7038)
        }
    )
}

extension DependencyValues {
    var locationGenerator: LocationGenerator {
        get { self[LocationGenerator.self] }
        set { self[LocationGenerator.self] = newValue }
    }
}
