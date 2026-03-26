import ComposableArchitecture
import Foundation

struct CachedEntry<T: Sendable>: Sendable {
    let value: T
    let storedAt: Date
}

@DependencyClient
struct CacheClient: Sendable {
    var get: @Sendable (String) async -> WeatherData? = { _ in nil }
    var set: @Sendable (String, WeatherData) async -> Void = { _, _ in }
    var remove: @Sendable (String) async -> Void = { _ in }
}

extension CacheClient: DependencyKey {
    static let liveValue: CacheClient = {
        let cache = LockIsolated<[String: CachedEntry<WeatherData>]>([:])
        let ttl: TimeInterval = 600

        return CacheClient(
            get: { key in
                guard let entry = cache.value[key] else { return nil }
                guard Date().timeIntervalSince(entry.storedAt) < ttl else {
                    _ = cache.withValue { $0.removeValue(forKey: key) }
                    return nil
                }
                return entry.value
            },
            set: { key, data in
                cache.withValue {
                    $0[key] = CachedEntry(value: data, storedAt: Date())
                }
            },
            remove: { key in
                _ = cache.withValue {
                    $0.removeValue(forKey: key)
                }
            }
        )
    }()

    static let previewValue = CacheClient()
}

extension DependencyValues {
    var cacheClient: CacheClient {
        get { self[CacheClient.self] }
        set { self[CacheClient.self] = newValue }
    }
}
