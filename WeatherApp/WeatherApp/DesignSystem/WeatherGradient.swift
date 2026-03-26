import SwiftUI

struct WeatherGradient: Equatable {
    let colors: [Color]


    static func forCondition(_ condition: WeatherCondition, isNight: Bool) -> WeatherGradient {
        if isNight {
            return WeatherGradient(
                colors: [
                    Color(hex: "#1A1040"),
                    Color(hex: "#2D1B69"),
                    Color(hex: "#0F1627"),
                    Color(hex: "#1A1B4E")
                ]
            )
        }

        switch condition {
        case .clear:
            return WeatherGradient(
                colors: [
                    Color(hex: "#F59E0B"),
                    Color(hex: "#D97706"),
                    Color(hex: "#92400E"),
                    Color(hex: "#1A1B2E")
                ]
            )
        case .clouds, .atmosphere:
            return WeatherGradient(
                colors: [
                    Color(hex: "#3B1F7B"),
                    Color(hex: "#5B3FA0"),
                    Color(hex: "#1E1845"),
                    Color(hex: "#2A2060")
                ]
            )
        case .rain, .drizzle, .thunderstorm:
            return WeatherGradient(
                colors: [
                    Color(hex: "#1E3A5F"),
                    Color(hex: "#2D4A7A"),
                    Color(hex: "#1B2838"),
                    Color(hex: "#1A1B4E")
                ]
            )
        case .snow:
            return WeatherGradient(
                colors: [
                    Color(hex: "#CBD5E1"),
                    Color(hex: "#94A3B8"),
                    Color(hex: "#64748B"),
                    Color(hex: "#334155")
                ]
            )
        }
    }
}
