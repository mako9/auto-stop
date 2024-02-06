//
//  ContentViewModel.swift
//  autostop Watch App
//
//  Created by Mario Kohlhoff on 19.01.24.
//

import Foundation

class ContentViewModel: ObservableObject {
    private let watchSyncService = WatchSyncService()
    private let dateFormatter: DateFormatter

    @Published var stopDateString: String?
    @Published var stoppedAudio: Bool = false
    @Published var isRunning: Bool = false

    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm:ss.SSSS"

        watchSyncService.dataReceived = { (key, message) in
            
        }
    }

    func startTimer() {
        watchSyncService.sendMessage(.watchOSTimerStarted, "Timer started") { error in
            guard let error = error else {
                self.isRunning = true
                return
            }
            Logger.shared.error("Watch: Could not start logger: \(error.localizedDescription)")
        }
    }

    func stopTimer() {
        watchSyncService.sendMessage(.watchOSTimerStopped, "Timer stopped") { error in
            guard let error = error else {
                self.isRunning = false
                return
            }
            Logger.shared.error("Watch: Could not stop logger: \(error.localizedDescription)")
        }
    }
}

