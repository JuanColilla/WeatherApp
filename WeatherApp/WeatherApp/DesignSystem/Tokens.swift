import SwiftUI

// MARK: - Colors

enum DSColor {
    // Backgrounds
    static let bgPrimary = Color(hex: "#1A1B2E")
    static let bgSecondary = Color(hex: "#252842")

    // Glass
    static let glassSurface = Color.white.opacity(0.1)
    static let glassSurfaceStrong = Color.white.opacity(0.2)
    static let glassBorder = Color.white.opacity(0.15)

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.4)

    // Accents
    static let accentBlue = Color(hex: "#5B9CF6")
    static let accentTeal = Color(hex: "#14B8A6")
    static let accentOrange = Color(hex: "#F59E0B")
    static let accentPink = Color(hex: "#F472B6")
    static let accentRed = Color(hex: "#EF4445")

    // Weather
    static let weatherSunny = Color(hex: "#F59E0B")
    static let weatherCloudy = Color(hex: "#94A3B8")
    static let weatherRainy = Color(hex: "#5B9CF6")
    static let weatherSnowy = Color(hex: "#CBD5E1")
}

// MARK: - Spacing

enum DSSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Radius

enum DSRadius {
    static let sm: CGFloat = 12
    static let md: CGFloat = 8
    static let lg: CGFloat = 24
    static let pill: CGFloat = 100
}
