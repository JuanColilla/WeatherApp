import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        Color.white.opacity(0.1),
                        .clear,
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .animation(
                    .linear(duration: 1.5).repeatForever(autoreverses: false),
                    value: phase
                )
            )
            .onAppear { phase = 400 }
            .clipped()
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}
