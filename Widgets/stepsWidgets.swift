import SwiftUI
import WidgetKit
import HealthKit

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
        stepsWidgetEntry(date: Date(), steps: 0, distance: 0 )
    }
    
    // the view at some pointt
    func getSnapshot(in context: Context, completion: @escaping (stepsWidgetEntry) -> Void) {
        let entry = stepsWidgetEntry(date: Date(), steps: 0, distance: 0 )
        completion(entry)
    }
    
    // the views over a period of time
    func getTimeline(in context: Context, completion: @escaping (Timeline<stepsWidgetEntry>) -> Void) {
        let group = DispatchGroup()
        var steps: Double = 0
        var distance: Double = 0
        group.enter()
        healthManager.getSumData(for: HKQuantityType(.stepCount), with: HKUnit.count()) { sample in
            steps = sample
            group.leave()
        }
        group.enter()
        healthManager.getSumData(for: HKQuantityType(.distanceWalkingRunning), with: HKUnit.mile()) { sample in
            distance = sample
            group.leave()
        }
        group.notify(queue: .main){
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
    
    @ViewBuilder
    var body: some View {
        
        
        let content = VStack {
            Text("\(Int(entry.steps))")
            Text("\(entry.distance)")

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
struct stepsWidget: Widget {
    
    let kind: String = "StepDistance"
    
    var body: some WidgetConfiguration {
 
        StaticConfiguration(kind: kind, provider: stepsWidgetProvider()) { entry in
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
