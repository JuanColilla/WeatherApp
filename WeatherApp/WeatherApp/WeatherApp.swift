import ComposableArchitecture
import SwiftUI

@main
struct WeatherApp: App {
    private static let isRunningTests = ProcessInfo.processInfo.environment["XCTestBundlePath"] != nil

    let store = Store(initialState: WeatherListFeature.State()) {
        if !isRunningTests {
            WeatherListFeature()
        }
    }

    var body: some Scene {
        WindowGroup {
            if Self.isRunningTests {
                EmptyView()
            } else {
                WeatherListView(store: store)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
