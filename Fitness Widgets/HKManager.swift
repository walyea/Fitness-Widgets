//
//  HKManager.swift
//  Fitness Widgets
//
//  Created by Wylan Alyea on 5/19/26.
//
import HealthKit

class HKManager {
    // Instance of health store where data is requested from
    let healthStore = HKHealthStore()
    // requests authorization
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        ]

        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    // gets data for sum quantity
    // type the data
    // unit the unit of the data
    // completion runs when the query returns return the data
    func getSumData(for type: HKQuantityType, with unit: HKUnit, completion: @escaping (Double) -> Void) {
        let startDate = Calendar.current.startOfDay(for: Date())
        // how to formate the data
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        // the query to healthkit
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            // the data could be nil so that is why there are ?
            let data = result?.sumQuantity()?.doubleValue(for: unit) ?? -1
            // for UI updates on Main Thread; it switches from the background queue, thread,  that the query is on to the main thread for ui
            DispatchQueue.main.async {
                // callback handler, the arguement is what it will return out of, and the parameter is the closure that is writen when this method is called
                completion(data)
            }
        }
        healthStore.execute(query)
    }
    // gets data for sample quantity
    // type the data
    // unit the unit of the data
    // completion runs when the query returns return the data
    func getSampleData(for type: HKQuantityType, with unit: HKUnit, completion: @escaping (Double) -> Void) {
        // how to formate the data
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        // how to sort the returned data because can return more than 1
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        // the query to healthkit
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            // force unwraps the value from an optional and then converts it into a HKQuanttitySample
            let stepCount = samples!.first! as? HKQuantitySample
            // for UI updates on Main Thread
            DispatchQueue.main.async {
                // Completion handler, explaned above
                completion(stepCount!.quantity.doubleValue(for: unit))
            }
        }
        healthStore.execute(query)

    }
}
// async await is turned into continuation based thing, generally the same idea, but flow does, not get nested, it stay linear
// reason that aa was not working was that the making of the timeline was not in the task and so got ran at a different time and did not work because of that
