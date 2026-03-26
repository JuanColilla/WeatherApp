import SwiftUI

struct WeatherConditionBadgeView: View {
    let condition: WeatherCondition
    let description: String
    let isNight: Bool

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: condition.sfSymbol(isNight: isNight))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(condition.color)
                .contentTransition(.symbolEffect(.replace))
            Text(description)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DSColor.textPrimary)
        }
        .padding(.vertical, DSSpacing.sm)
        .padding(.horizontal, DSSpacing.md)
        .glassEffect(.regular, in: Capsule())
    }
}
