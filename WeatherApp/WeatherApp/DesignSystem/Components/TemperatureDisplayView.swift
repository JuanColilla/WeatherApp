import SwiftUI

struct TemperatureDisplayView: View {
    let temperature: Double

    private var roundedTemp: Int {
        Int(temperature.rounded())
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("\(roundedTemp)")
                .font(.system(size: 96, weight: .heavy))
                .foregroundStyle(DSColor.textPrimary)
                .contentTransition(.numericText(value: Double(roundedTemp)))
            Text("°")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(DSColor.textSecondary)
        }
        .animation(.easeInOut(duration: 0.6), value: roundedTemp)
    }
}
