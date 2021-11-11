//
//  ContentViewModel.swift
//  AutoStop WatchKit Extension
//
//  Created by Mario Kohlhoff on 11.11.21.
//

import Foundation
import SwiftUI

class ContentViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager()
    private let audioManager = AudioManager()
    private let dateFormatter: DateFormatter

    @Published var stopDateString: String?

    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm:ss.SSSS"
    }

    func checkForStop() {
        healthKitManager.isSleeping { shouldStop in
            guard shouldStop else {
                return
            }
            if self.audioManager.stopAudio() {
                self.stopDateString = self.dateFormatter.string(from: Date())
            }
        }
    }
}
