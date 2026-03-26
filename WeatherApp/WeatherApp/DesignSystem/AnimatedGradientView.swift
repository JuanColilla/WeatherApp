import SwiftUI

// MARK: - Environment key to freeze animations for snapshot testing

private struct AnimationsEnabledKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    var animationsEnabled: Bool {
        get { self[AnimationsEnabledKey.self] }
        set { self[AnimationsEnabledKey.self] = newValue }
    }
}

struct AnimatedGradientView: View {
    let colors: [Color]
    var speed: CGFloat = 0.02
    var isAccelerated: Bool = false

    @Environment(\.animationsEnabled) private var animationsEnabled

    @State private var startDate = Date.now
    @State private var currentSpeed: CGFloat = 0.02

    /// Expands 4 input colors into a 3×3 grid (9 colors) by interpolating midpoints
    private var expandedColors: [Color] {
        guard colors.count >= 4 else {
            return Array(repeating: Color.black, count: 9)
        }
        let tl = colors[0] // top-left
        let tr = colors[1] // top-right
        let bl = colors[2] // bottom-left
        let br = colors[3] // bottom-right

        return [
            tl, blend(tl, tr), tr,
            blend(tl, bl), blend(tl, tr, bl, br), blend(tr, br),
            bl, blend(bl, br), br
        ]
    }

    private func blend(_ a: Color, _ b: Color) -> Color {
        // Use environment-resolved mixing
        a.mix(with: b, by: 0.5)
    }

    private func blend(_ a: Color, _ b: Color, _ c: Color, _ d: Color) -> Color {
        blend(blend(a, b), blend(c, d))
    }

    private func animatedPoints(for date: Date) -> [SIMD2<Float>] {
        let phase = date.timeIntervalSince(startDate) * currentSpeed
        let drift: Float = 0.15

        // Only the center point (index 4) moves — all border points are fixed
        let cx = 0.5 + Float(sin(phase * 1.3)) * drift
        let cy = 0.5 + Float(cos(phase * 0.9)) * drift

        return [
            SIMD2(0.0, 0.0), SIMD2(0.5, 0.0), SIMD2(1.0, 0.0),
            SIMD2(0.0, 0.5), SIMD2(cx, cy),    SIMD2(1.0, 0.5),
            SIMD2(0.0, 1.0), SIMD2(0.5, 1.0), SIMD2(1.0, 1.0)
        ]
    }

    private var staticPoints: [SIMD2<Float>] {
        [
            SIMD2(0.0, 0.0), SIMD2(0.5, 0.0), SIMD2(1.0, 0.0),
            SIMD2(0.0, 0.5), SIMD2(0.5, 0.5), SIMD2(1.0, 0.5),
            SIMD2(0.0, 1.0), SIMD2(0.5, 1.0), SIMD2(1.0, 1.0)
        ]
    }

    var body: some View {
        Group {
            if animationsEnabled {
                TimelineView(.animation) { timeline in
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: animatedPoints(for: timeline.date),
                        colors: expandedColors
                    )
                }
            } else {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: staticPoints,
                    colors: expandedColors
                )
            }
        }
        .onChange(of: isAccelerated) { _, accelerated in
            withAnimation(.easeInOut(duration: 0.8)) {
                currentSpeed = accelerated ? 0.12 : speed
            }
        }
        .onAppear {
            currentSpeed = speed
        }
    }
}
