//
//  HeathKitManager.swift
//  AutoStop WatchKit Extension
//
//  Created by Mario Kohlhoff on 10.11.21.
//

import Foundation
import HealthKit

class HealthKitManager {
    private let healthStore = HKHealthStore()
    private let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
    var startDate: Date?

    func isSleeping(completion: @escaping (Bool) -> Void) {
        guard isAuthorized() else {
            requestAuthorization { authorized, error in
                if let error = error { Logger.shared.error("Error during HealthKit authorization: \(error)")}
                guard authorized else {
                    completion(false)
                    return
                }
                self.retrieveSleepAnalysis(completion: completion)
            }
            return
        }
        self.retrieveSleepAnalysis(completion: completion)
    }

    private func isAuthorized() -> Bool {
        return healthStore.authorizationStatus(for: sleepType) == .sharingAuthorized
    }

    private func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        healthStore.requestAuthorization(toShare: nil, read: [sleepType]) { (isAuthorized, error) in
            if let error = error { Logger.shared.error("Error during HealthKit authorization: \(error)")}
            guard isAuthorized else {
                completion(isAuthorized, error)
                return
            }
            self.healthStore.enableBackgroundDelivery(for: self.sleepType, frequency: HKUpdateFrequency(rawValue: 10)!, withCompletion: completion)
        }
    }

    private func retrieveSleepAnalysis(completion: @escaping (Bool) -> Void) {
        // only consider values with start date after initial start
        if self.startDate == nil { self.startDate = Date() }
        let predicate = HKQuery.predicateForSamples(withStart: startDate ?? nil, end: nil, options: .strictStartDate)
        // use a sortDescriptor to get the recent data first
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // we create our query with a block completion to execute
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
            
            if let error = error {
                Logger.shared.error("Error during sleep analysis retrieval: \(error)")
                completion(false)
                return
                
            }

            guard let result = tmpResult else {
                Logger.shared.warn("Could not fetch sleep result.")
                completion(false)
                return
            }
                
            var isSleeping = false
            for item in result {
                if let sample = item as? HKCategorySample {
                    Logger.shared.info("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(sample.value)")
                    isSleeping = sample.value != HKCategoryValueSleepAnalysis.inBed.rawValue && sample.value != HKCategoryValueSleepAnalysis.awake.rawValue
                    if isSleeping { break }
                }
            }
            Logger.shared.debug("User is sleeping: \(isSleeping)")
            completion(isSleeping)
        }

        // finally, we execute our query
        healthStore.execute(query)
    }
}
