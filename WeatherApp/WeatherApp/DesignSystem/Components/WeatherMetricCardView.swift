import SwiftUI

struct WeatherMetricCardView: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 20, height: 20)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DSColor.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(DSColor.textPrimary)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.lg)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DSRadius.lg))
    }
}
