import SwiftUI

struct RefreshButtonView: View {
    var title: String = "New Location"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(DSColor.textPrimary)
            .padding(.vertical, 14)
            .padding(.horizontal, DSSpacing.lg)
            .glassEffect(.regular, in: Capsule())
        }
    }
}
