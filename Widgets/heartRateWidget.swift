import HealthKit
import SwiftUI
import WidgetKit

// Representation of the Widget
struct heartRateWidgetEntry: TimelineEntry {
    let date: Date
    let heartRate: Double
    let resting: Double
}

// Shows how the widget should change over time
struct heartRateProvider: TimelineProvider {
    let healthManager = HKManager()

    // the view in the selection menu
    func placeholder(in context: Context) -> heartRateWidgetEntry {
        heartRateWidgetEntry(date: Date(), heartRate: 0, resting: 0)
    }

    // the view at some pointt
    func getSnapshot(
        in context: Context,
        completion: @escaping (heartRateWidgetEntry) -> Void
    ) {
        let entry = heartRateWidgetEntry(date: Date(), heartRate: 0, resting: 0)
        completion(entry)
    }

    // the views over a period of time
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<heartRateWidgetEntry>) -> Void
    ) {
        // keeps track of how many async tasks are running
        let group = DispatchGroup()
        var heartRateResting: Double = 0
        var heartRate: Double = 0
        // allows for the two queries to run in parrallel
        // a tasks to the list so the process continues running
        group.enter()
        healthManager.getSampleData(
            for: HKQuantityType(.walkingHeartRateAverage),
            with: HKUnit.count().unitDivided(by: HKUnit.minute())
        ) { sample in
            heartRate = sample
            group.leave()
        }
        // allows for the two queries to run in parrallel
        // a tasks to the list so
        group.enter()
        healthManager.getSampleData(
            for: HKQuantityType(.restingHeartRate),
            with: HKUnit.count().unitDivided(by: HKUnit.minute())
        ) { sample in
            heartRateResting = sample
            group.leave()
        }
        // tells the computer to run this on the main thread to update the gui
        // runs when amount of async tasks in group is 0
        group.notify(queue: .main) {
            let entry = heartRateWidgetEntry(
                date: Date(),
                heartRate: heartRate,
                resting: heartRateResting
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
struct heartRateWidgetEntryView: View {
    var entry: heartRateProvider.Entry

    @ViewBuilder
    var body: some View {

        let content = VStack {
            Text("\(Int(entry.heartRate))")
            Text("\(Int(entry.resting))")

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
struct heartRateWidget: Widget {

    let kind: String = "HeartRate"

    var body: some WidgetConfiguration {

        StaticConfiguration(kind: kind, provider: heartRateProvider()) {
            entry in
            let base = heartRateWidgetEntryView(entry: entry)

            if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
                base.containerBackground(for: .widget) {
                    Color.clear
                }
            } else {
                base.background(Color.clear)
            }
        }
        .configurationDisplayName("Fitness Information")
        .description("Resting and Current Heart Rate")

        #if os(iOS)
            .supportedFamilies([.systemSmall, .systemMedium])
        #elseif os(macOS)
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        #endif

    }
}
