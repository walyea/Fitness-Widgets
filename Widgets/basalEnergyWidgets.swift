import HealthKit
import SwiftUI
import WidgetKit

// Representation of the Widget
struct fitnessWidgetEntry: TimelineEntry {
    let date: Date
    let Data: Double
}
// Shows how the widget should change over time
struct fitnessWidgetProvider: TimelineProvider {
    let healthManager = HKManager()
    // the view in the selection menu
    func placeholder(in context: Context) -> fitnessWidgetEntry {
        fitnessWidgetEntry(date: Date(), Data: 0)
    }
    // the view at some pointt
    func getSnapshot(
        in context: Context,
        completion: @escaping (fitnessWidgetEntry) -> Void
    ) {
        let entry = fitnessWidgetEntry(date: Date(), Data: 0)
        completion(entry)
    }

    // the views over a period of time
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<fitnessWidgetEntry>) -> Void
    ) {

        healthManager.getSumData(
            for: HKQuantityType(.basalEnergyBurned),
            with: HKUnit.kilocalorie()
        ) { energy in
            let entry = fitnessWidgetEntry(
                date: Date(),
                Data: energy
            )

            let refreshDate = Date().addingTimeInterval(60)

            let timeline = Timeline(
                entries: [entry],
                policy: .after(refreshDate)
            )

            completion(timeline)
        }
    }

}
// what it looks like
struct fitnessWidgetEntryView: View {
    var entry: fitnessWidgetProvider.Entry

    @ViewBuilder
    var body: some View {

        let content = VStack {
            Text("\(Int(entry.Data))")

        }

        if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
            content.containerBackground(for: .widget) {
                Color.clear
            }
        } else {
            content.background(Color.clear)
        }

    }
}
// its configuration
struct fitnessWidget: Widget {

    let kind: String = "BasalEnergy"

    var body: some WidgetConfiguration {

        StaticConfiguration(kind: kind, provider: fitnessWidgetProvider()) {
            entry in
            let base = fitnessWidgetEntryView(entry: entry)

            if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
                base.containerBackground(for: .widget) {
                    Color.clear
                }
            } else {
                base.background(Color.clear)
            }
        }
        .configurationDisplayName("Fitness Information")
        .description("Basal Energy")

        #if os(iOS)
            .supportedFamilies([.systemSmall, .systemMedium])
        #elseif os(macOS)
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        #endif

    }
}
