//
//  ContentViewModel.swift
//  autostop Watch App
//
//  Created by Mario Kohlhoff on 19.01.24.
//

import Foundation

class ContentViewModel: ObservableObject {
    private let watchSyncService = WatchSyncService()

    @Published var stopDateString: String?
    @Published var timerStarted: Bool = false {
        didSet {
            print(timerStarted)
        }
    }

    init() {
        watchSyncService.dataReceived = { (key, message) in
            DispatchQueue.main.async {
                switch key {
                case .iOSTimerStarted:
                    self.timerStarted = true
                case .iOSTimerStopped:
                    self.timerStarted = false
                case .iOSSleepDetected:
                    self.timerStarted = false
                    self.stopDateString = message as? String
                default:
                    Logger.shared.verbose("Irrelevant key: \(key.rawValue)")
                }
            }
        }
    }

    func startTimer() {
        watchSyncService.sendMessage(.watchOSTimerStarted, "Timer started")
    }

    func stopTimer() {
        watchSyncService.sendMessage(.watchOSTimerStopped, "Timer stopped")
    }
}

