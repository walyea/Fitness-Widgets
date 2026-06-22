import HealthKit
import SwiftUI
import WidgetKit

// Representation of the Widget
struct stepsWidgetEntry: TimelineEntry {
    let date: Date
    let steps: Double
    let distance: Double
}

// Shows how the widget should change over time
struct stepsWidgetProvider: TimelineProvider {
    let healthManager = HKManager()

    // the view in the selection menu
    func placeholder(in context: Context) -> stepsWidgetEntry {
        stepsWidgetEntry(date: Date(), steps: 0, distance: 0)
    }

    // the view at some pointt
    func getSnapshot(
        in context: Context,
        completion: @escaping (stepsWidgetEntry) -> Void
    ) {
        let entry = stepsWidgetEntry(date: Date(), steps: 0, distance: 0)
        completion(entry)
    }

    // the views over a period of time
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<stepsWidgetEntry>) -> Void
    ) {
        // keeps track of how many async tasks are running
        let group = DispatchGroup()
        var steps: Double = 0
        var distance: Double = 0
        // allows for the two queries to run in parrallel
        // a tasks to the list so the process continues running
        group.enter()
        healthManager.getSumData(
            for: HKQuantityType(.stepCount),
            with: HKUnit.count()
        ) { sample in
            steps = sample
            group.leave()
        }
        // allows for the two queries to run in parrallel
        // a tasks to the list so the process continues running
        group.enter()
        healthManager.getSumData(
            for: HKQuantityType(.distanceWalkingRunning),
            with: HKUnit.mile()
        ) { sample in
            distance = sample
            group.leave()
        }
        // tells the computer to run this on the main thread to update the gui
        // runs when amount of async tasks in group is 0
        group.notify(queue: .main) {
            let entry = stepsWidgetEntry(
                date: Date(),
                steps: steps,
                distance: distance
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
struct stepsWidgetEntryView: View {
    var entry: stepsWidgetProvider.Entry

    var body: some View {
        let steps = entry.steps
        let distance = entry.distance
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Image(systemName: "figure.walk")
                    .foregroundStyle(.green)

                Text("Steps")
                    .font(.headline)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(Int(steps))")
                    .font(.system(size: 30, weight: .bold))

                Text("Steps Today")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading) {
                Text("\(distance, specifier: "%.1f") mi")
                    .font(.title3)
                    .fontWeight(.bold)

                Text("Distance")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        Spacer()
    }

}

// its configuration
struct stepsWidget: Widget {

    let kind: String = "StepDistance"

    var body: some WidgetConfiguration {

        StaticConfiguration(kind: kind, provider: stepsWidgetProvider()) {
            entry in
            let base = stepsWidgetEntryView(entry: entry)

            if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
                base.containerBackground(for: .widget) {
                    Color.clear
                }
            } else {
                base.background(Color.clear)
            }
        }
        .configurationDisplayName("Fitness Widgets")
        .description("Steps and Distance Walked and Ran")

        #if os(iOS)
            .supportedFamilies([.systemSmall, .systemMedium])
        #elseif os(macOS)
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        #endif

    }
}
