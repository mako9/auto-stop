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
    private let watchSyncService = WatchSyncService()
    private let dateFormatter: DateFormatter

    @Published var stopDateString: String?
    @Published var timerStarted: Bool = false
    @Published var isRunning: Bool = false

    private var checkTimer: Timer?

    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        
        watchSyncService.dataReceived = { (key, message) in
            switch key {
            case .watchOSTimerStarted:
                self.startTimer()
            case .watchOSTimerStopped:
                self.stopTimer()
            default:
                Logger.shared.verbose("Irrelevant key: \(key.rawValue)")
            }
        }
    }

    func startTimer() {
        checkTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
            self.checkSleep()
        })
        timerStarted = true
        watchSyncService.sendMessage(.iOSTimerStarted, "Timer started")
    }

    func stopTimer() {
        checkTimer?.invalidate()
        checkTimer = nil
        DispatchQueue.main.async {
            self.timerStarted = false
        }
        self.watchSyncService.sendMessage(.iOSTimerStopped, "Timer stopped")
    }

    private func checkSleep() {
        if isRunning {
            Logger.shared.debug("Sleep check already running")
            return
        }
        DispatchQueue.main.async {
            self.isRunning = true
        }
        healthKitManager.isSleeping { [self] shouldStop in
            DispatchQueue.main.async {
                self.isRunning = false
            }
            guard shouldStop else {
                return
            }
            if self.audioManager.stopAudio() {
                self.stopTimer()
                let dateString = self.dateFormatter.string(from: Date())
                DispatchQueue.main.async {
                    self.stopDateString = dateString
                }
                self.watchSyncService.sendMessage(.iOSSleepDetected, dateString)
            }
        }
    }
}
