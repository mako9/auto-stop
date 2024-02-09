//
//  ContentViewModel.swift
//  autostop Watch App
//
//  Created by Mario Kohlhoff on 19.01.24.
//

import Foundation

class ContentViewModel: NSObject, ObservableObject, WatchSyncServiceDelegate {
    private var watchSyncService: WatchSyncService?
    private let healthKitManager = HealthKitManager()
    private var checkTimer: Timer?
    private var isRunning: Bool = false
    private let dateFormatter: DateFormatter

    @Published var isConnectionAvailable: Bool = false
    @Published var stopDateString: String?
    @Published var timerStarted: Bool = false

    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"

        super.init()
        
        watchSyncService = WatchSyncService(delegate: self)
        watchSyncService?.dataReceived = { (key, message) in
            switch key {
            case .iOSTimerStarted:
                self.startTimer()
            case .iOSTimerStopped:
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
        watchSyncService?.sendMessage(.watchOSTimerStarted, "Timer started")
    }

    func stopTimer() {
        checkTimer?.invalidate()
        checkTimer = nil
        DispatchQueue.main.async {
            self.timerStarted = false
        }
        self.watchSyncService?.sendMessage(.watchOSTimerStopped, "Timer stopped")
    }

    private func checkSleep() {
        if isRunning {
            Logger.shared.debug("Sleep check already running")
            return
        }
        isRunning = true
        healthKitManager.isSleeping { [self] shouldStop in
            self.isRunning = false
            guard shouldStop else {
                return
            }
            self.stopTimer()
            let dateString = self.dateFormatter.string(from: Date())
            DispatchQueue.main.async {
                self.stopDateString = dateString
            }
            self.watchSyncService?.sendMessage(.watchOSSleepDetected, dateString)
        }
    }
    
    func connectionAvailable(_ isAvailable: Bool) {
        DispatchQueue.main.async {
            self.isConnectionAvailable = isAvailable
        }
    }
}

