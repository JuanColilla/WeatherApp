import SwiftUI

struct LocationBadgeView: View {
    let cityName: String
    let coordinate: Coordinate

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "mappin")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DSColor.accentPink)
            VStack(alignment: .leading, spacing: 2) {
                Text(cityName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DSColor.textPrimary)
                Text("\(coordinate.formattedLatitude), \(coordinate.formattedLongitude)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DSColor.textTertiary)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, DSSpacing.md)
        .glassEffect(.regular, in: Capsule())
    }
}
