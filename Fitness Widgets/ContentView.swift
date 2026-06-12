//
//  ContentView.swift
//  Fitness Widgets
//
//  Created by Wylan Alyea on 5/19/26.
//

import SwiftUI
import HealthKit
// App View
struct ContentView: View {
    // Instance of healthManager to access Health Store
    let healthManager = HKManager()
    // Variables of Data
    @State private var basalEnergy: Double = 0
    @State private var activeEnergy: Double = 0
    @State private var stepCount: Double = 0
    @State private var Distance: Double = 0
    @State private var heartRate: Double = 0
    @State private var restingHeartRate: Double = 0
    @State private var walkingHeartRate: Double = 0
    //Main View
    var body: some View {
        VStack {
            Text("Today's Basal Energy")
                .font(.title)
            
            Text("\(Int(basalEnergy))")
                .bold()
                .font(.largeTitle)
            
            
            VStack {
                Text("Today's Step Count")
                    .font(.title)
                
                Text("\(Int(stepCount))")
                    .bold()
                    .font(.largeTitle)
            }
            VStack {
                Text("Today's Distance Walked")
                    .font(.title)
                
                Text("\(Distance)")
                    .bold()
                    .font(.largeTitle)
                
            }
            VStack {
                Text("Heart Rate ")
                    .font(.title)
                
                Text("\(Int(heartRate))")
                    .bold()
                    .font(.largeTitle)
            }
            VStack {
                Text("Today's Resting Heart Rate")
                    .font(.title)
                
                Text("\(Int(restingHeartRate))")
                    .bold()
                    .font(.largeTitle)
            }
            VStack {
                Text("Today's Walking Heart Rate")
                    .font(.title)
                
                Text("\(Int(walkingHeartRate))")
                    .bold()
                    .font(.largeTitle)
                
                Button("Get Stats") {
                    // gets all the data to display
                    // these have closures because they are sum types
                    healthManager.getSumData(for: HKQuantityType(.basalEnergyBurned), with: HKUnit.kilocalorie()) { sample in
                        basalEnergy = sample
                    }
                    healthManager.getSumData(for: HKQuantityType(.activeEnergyBurned), with: HKUnit.kilocalorie()) { sample in
                        activeEnergy = sample
                    }
                    healthManager.getSumData(for: HKQuantityType(.distanceWalkingRunning), with: HKUnit.mile()) { sample in
                        Distance = sample
                        
                    }
                    healthManager.getSumData(for: HKQuantityType(.stepCount), with: HKUnit.count()) { sample in
                        stepCount = sample
                    }
                    healthManager.getSampleData(for: HKQuantityType(.heartRate), with: HKUnit.count().unitDivided(by: HKUnit.minute())){ sample in
                        heartRate = sample
                    }
                    healthManager.getSampleData(for: HKQuantityType(.restingHeartRate), with: HKUnit.count().unitDivided(by: HKUnit.minute())){ sample in
                        restingHeartRate = sample
                    }
                    healthManager.getSampleData(for: HKQuantityType(.walkingHeartRateAverage), with: HKUnit.count().unitDivided(by: HKUnit.minute())){ sample in
                        walkingHeartRate = sample
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.brown)
            }
            .padding()
            .onAppear {
                requestHealthKitAccess()
            }
            
        }
    }
    func requestHealthKitAccess() {
        healthManager.requestAuthorization { success, error in
            if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            } else {
                print("HealthKit authorization was successful")
            }
        }
    }
    
    
}
#Preview {
    ContentView()
}
