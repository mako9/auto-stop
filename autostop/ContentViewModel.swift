//
//  ContentViewModel.swift
//  AutoStop WatchKit Extension
//
//  Created by Mario Kohlhoff on 11.11.21.
//

import Foundation
import SwiftUI

class ContentViewModel: ObservableObject {
    private let audioManager = AudioManager()
    private let watchSyncService = WatchSyncService()

    @Published var stopDateString: String?
    @Published var timerStarted: Bool = false

    init() {
        watchSyncService.dataReceived = { (key, message) in
            DispatchQueue.main.async {
                switch key {
                case .watchOSTimerStarted:
                    self.timerStarted = true
                case .watchOSTimerStopped:
                    self.timerStarted = false
                case .watchOSSleepDetected:
                    self.timerStarted = false
                    self.stopDateString = message as? String
                    self.stopAudio()
                default:
                    Logger.shared.verbose("Irrelevant key: \(key.rawValue)")
                }
            }
        }
    }

    func startTimer() {
        watchSyncService.sendMessage(.iOSTimerStarted, "Timer started")
    }

    func stopTimer() {
        watchSyncService.sendMessage(.iOSTimerStopped, "Timer stopped")
    }

    private func stopAudio() {
        let stoppedAudio = audioManager.stopAudio()
        Logger.shared.debug("Stopped audio successfully: \(stoppedAudio)")
    }
}
