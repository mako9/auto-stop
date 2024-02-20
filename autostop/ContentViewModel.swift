//
//  ContentViewModel.swift
//  AutoStop WatchKit Extension
//
//  Created by Mario Kohlhoff on 11.11.21.
//

import Foundation
import SwiftUI

class ContentViewModel: NSObject, ObservableObject, WatchSyncServiceDelegate {
    private let userDefaultsKeyStopDateString = "STOP_DATE_STRING"
    private let audioManager = AudioManager()
    private let userDefaults = UserDefaults.standard
    private var watchSyncService: WatchSyncService?

    @Published var isConnectionAvailable: Bool = false
    @Published var stopDateString: String?
    @Published var timerStarted: Bool = false

    override init() {
        super.init()
        stopDateString = userDefaults.string(forKey: userDefaultsKeyStopDateString)
        watchSyncService = WatchSyncService(delegate: self)
        watchSyncService?.dataReceived = { (key, message) in
            DispatchQueue.main.async {
                switch key {
                case .watchOSTimerStarted:
                    self.timerStarted = true
                    self.stopDateString = nil
                    self.userDefaults.removeObject(forKey: self.userDefaultsKeyStopDateString)
                case .watchOSTimerStopped:
                    self.timerStarted = false
                case .watchOSSleepDetected:
                    self.timerStarted = false
                    self.stopDateString = message as? String
                    self.userDefaults.set(self.stopDateString, forKey: self.userDefaultsKeyStopDateString)
                    self.stopAudio()
                default:
                    Logger.shared.verbose("Irrelevant key: \(key.rawValue)")
                }
            }
        }
    }

    func startTimer() {
        watchSyncService?.sendMessage(.iOSTimerStarted, "Timer started")
    }

    func stopTimer() {
        watchSyncService?.sendMessage(.iOSTimerStopped, "Timer stopped")
    }

    private func stopAudio() {
        let stoppedAudio = audioManager.stopAudio()
        Logger.shared.debug("Stopped audio successfully: \(stoppedAudio)")
    }

    func connectionAvailable(_ isAvailable: Bool) {
        DispatchQueue.main.async {
            self.isConnectionAvailable = isAvailable
        }
    }
}
