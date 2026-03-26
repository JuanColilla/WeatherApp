import SwiftUI

struct LocationListItemView: View {
    let cityName: String
    let temperature: String
    let conditionDescription: String
    let condition: WeatherCondition
    let isNight: Bool
    let isPrimary: Bool
    var onTap: (() -> Void)? = nil
    let onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Button {
                onTap?()
            } label: {
                HStack(spacing: DSSpacing.sm) {
                    Image(systemName: condition.sfSymbol(isNight: isNight))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(condition.color)
                        .frame(width: 40, height: 40)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DSRadius.sm))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(cityName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(DSColor.textPrimary)
                        Text("\(temperature) · \(conditionDescription)")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(DSColor.textSecondary)
                    }

                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if !isPrimary, let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(DSColor.accentRed)
                        .frame(width: 32, height: 32)
                        .background(DSColor.accentRed.opacity(0.2))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, DSSpacing.md)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DSRadius.lg))
    }
}
