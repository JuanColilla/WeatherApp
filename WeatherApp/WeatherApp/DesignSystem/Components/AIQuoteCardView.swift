import SwiftUI

struct AIQuoteCardView: View {
    let state: AIQuoteState
    var onRefresh: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            content
            if case .generated = state {
                footer
            }
        }
        .padding(20)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DSRadius.lg))
    }

    @ViewBuilder
    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "apple.intelligence")
                .font(.system(size: 16))
                .foregroundStyle(headerColor)
            Text(headerText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(headerColor)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .idle:
            EmptyView()

        case .generating:
            VStack(alignment: .leading, spacing: 10) {
                skeletonLine()
                skeletonLine()
                skeletonLine(maxWidth: 200)
            }
            .shimmering()

        case let .generated(quote):
            Text("\"\(quote)\"")
                .font(.system(size: 15))
                .italic()
                .foregroundStyle(DSColor.textPrimary)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)

        case let .unavailable(reason):
            Text(reason)
                .font(.system(size: 13))
                .foregroundStyle(DSColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var footer: some View {
        HStack {
            Spacer()
            Button {
                onRefresh?()
            } label: {
                Image(systemName: "arrow.trianglehead.2.counterclockwise")
                    .font(.system(size: 14))
                    .foregroundStyle(DSColor.textTertiary)
            }
        }
    }

    private func skeletonLine(maxWidth: CGFloat? = nil) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(DSColor.glassSurface)
            .frame(maxWidth: maxWidth ?? .infinity)
            .frame(height: 12)
    }

    private var headerColor: Color {
        switch state {
        case .unavailable: DSColor.textTertiary
        default: DSColor.accentPink
        }
    }

    private var headerText: String {
        switch state {
        case .generating: "Thinking..."
        default: "Apple Intelligence"
        }
    }
}
