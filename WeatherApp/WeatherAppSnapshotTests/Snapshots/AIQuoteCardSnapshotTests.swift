import XCTest
import SnapshotTesting
import SwiftUI
@testable import WeatherApp

@MainActor
final class AIQuoteCardSnapshotTests: XCTestCase {

    override func invokeTest() {
        withSnapshotTesting(record: .missing) {
            super.invokeTest()
        }
    }

    // MARK: - Generating

    func test_generating_light() {
        let view = AIQuoteCardView(state: .generating)
            .frame(width: 360)
            .padding(24)
            .background(Color(hex: "#1A1B2E"))
            .preferredColorScheme(.light)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    func test_generating_dark() {
        let view = AIQuoteCardView(state: .generating)
            .frame(width: 360)
            .padding(24)
            .background(Color(hex: "#1A1B2E"))
            .preferredColorScheme(.dark)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    // MARK: - Generated

    func test_generated_light() {
        let view = AIQuoteCardView(
            state: .generated("Ah yes, 24°C and partly cloudy — the weather equivalent of 'I woke up like this.'"),
            onRefresh: {}
        )
        .frame(width: 360)
        .padding(24)
        .background(Color(hex: "#1A1B2E"))
        .preferredColorScheme(.light)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    func test_generated_dark() {
        let view = AIQuoteCardView(
            state: .generated("Ah yes, 24°C and partly cloudy — the weather equivalent of 'I woke up like this.'"),
            onRefresh: {}
        )
        .frame(width: 360)
        .padding(24)
        .background(Color(hex: "#1A1B2E"))
        .preferredColorScheme(.dark)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    // MARK: - Unavailable

    func test_unavailable_light() {
        let view = AIQuoteCardView(state: .unavailable("This device doesn't support Apple Intelligence"))
            .frame(width: 360)
            .padding(24)
            .background(Color(hex: "#1A1B2E"))
            .preferredColorScheme(.light)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }

    func test_unavailable_dark() {
        let view = AIQuoteCardView(state: .unavailable("This device doesn't support Apple Intelligence"))
            .frame(width: 360)
            .padding(24)
            .background(Color(hex: "#1A1B2E"))
            .preferredColorScheme(.dark)

        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }
}
