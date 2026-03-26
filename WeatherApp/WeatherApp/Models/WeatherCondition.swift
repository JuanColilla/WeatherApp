import SwiftUI

enum WeatherCondition: Sendable {
    case thunderstorm
    case drizzle
    case rain
    case snow
    case atmosphere
    case clear
    case clouds

    init(conditionCode: Int) {
        switch conditionCode {
        case 200..<300: self = .thunderstorm
        case 300..<400: self = .drizzle
        case 500..<600: self = .rain
        case 600..<700: self = .snow
        case 700..<800: self = .atmosphere
        case 800:       self = .clear
        default:        self = .clouds
        }
    }

    var sfSymbolName: String {
        switch self {
        case .thunderstorm: "cloud.bolt.fill"
        case .drizzle:      "cloud.drizzle.fill"
        case .rain:         "cloud.rain.fill"
        case .snow:         "snowflake"
        case .atmosphere:   "cloud.fog.fill"
        case .clear:        "sun.max.fill"
        case .clouds:       "cloud.fill"
        }
    }

    var nightSfSymbolName: String {
        switch self {
        case .clear: "moon.fill"
        default:     sfSymbolName
        }
    }

    func sfSymbol(isNight: Bool) -> String {
        isNight ? nightSfSymbolName : sfSymbolName
    }

    var color: Color {
        switch self {
        case .clear:                        DSColor.weatherSunny
        case .clouds, .atmosphere:          DSColor.weatherCloudy
        case .rain, .drizzle, .thunderstorm: DSColor.weatherRainy
        case .snow:                         DSColor.weatherSnowy
        }
    }
}
