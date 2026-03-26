import ComposableArchitecture
import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

@DependencyClient
struct IntelligenceClient: Sendable {
    var checkAvailability: @Sendable () async -> AIQuoteState = { .idle }
    var generateQuote: @Sendable (WeatherData) async throws -> String = { _ in "" }
}

extension IntelligenceClient: DependencyKey {
    static let liveValue: IntelligenceClient = {
        #if canImport(FoundationModels)
        return IntelligenceClient(
            checkAvailability: {
                let availability = SystemLanguageModel.default.availability
                switch availability {
                case .available:
                    return .idle
                case .unavailable(let reason):
                    let message: String
                    switch reason {
                    case .deviceNotEligible:
                        message = "This device doesn't support Apple Intelligence"
                    case .appleIntelligenceNotEnabled:
                        message = "Enable Apple Intelligence in Settings"
                    case .modelNotReady:
                        message = "Apple Intelligence is downloading..."
                    @unknown default:
                        message = "Apple Intelligence is not available"
                    }
                    return .unavailable(message)
                @unknown default:
                    return .unavailable("Apple Intelligence is not available")
                }
            },
            generateQuote: { weather in
                let instructions = """
                    You are a witty weather commentator. Generate a single short sarcastic \
                    but useful observation about the current weather conditions. Be clever and \
                    funny, never offensive or mean. Keep it to 1-2 sentences max. \
                    The quote should contain a genuinely useful nugget of advice wrapped in humor. \
                    IMPORTANT: The data provided is current weather, not a forecast. \
                    Humidity is atmospheric moisture level, NOT rain probability. \
                    Do not confuse humidity with chance of rain — they are different metrics.
                    """

                let prompt = """
                    Current weather in \(weather.displayCityName):
                    - Temperature: \(Int(weather.temperature.rounded()))°C (feels like \(Int(weather.feelsLike.rounded()))°C)
                    - Sky condition: \(weather.description)
                    - Relative humidity: \(weather.humidity)% (moisture in air, not rain chance)
                    - Wind speed: \(String(format: "%.1f", weather.windSpeed)) m/s
                    - Atmospheric pressure: \(weather.pressure) hPa
                    """

                let session = LanguageModelSession(instructions: instructions)
                let response = try await session.respond(to: prompt)
                return response.content
            }
        )
        #else
        return IntelligenceClient(
            checkAvailability: {
                .unavailable("Apple Intelligence requires iOS 26 or later")
            },
            generateQuote: { _ in
                throw IntelligenceError.notAvailable
            }
        )
        #endif
    }()

    static let previewValue = IntelligenceClient(
        checkAvailability: { .idle },
        generateQuote: { _ in
            "Ah yes, 24°C and partly cloudy — the weather equivalent of 'I woke up like this.'"
        }
    )

    static let testValue = IntelligenceClient()
}

enum IntelligenceError: Error, Equatable, Sendable, LocalizedError {
    case notAvailable
    case generationFailed(String)

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            "Apple Intelligence is not available"
        case .generationFailed(let reason):
            reason
        }
    }
}

extension DependencyValues {
    var intelligenceClient: IntelligenceClient {
        get { self[IntelligenceClient.self] }
        set { self[IntelligenceClient.self] = newValue }
    }
}
