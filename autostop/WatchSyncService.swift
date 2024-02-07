//
//  WatchSyncService.swift
//  autostop
//
//  Created by Mario Kohlhoff on 19.01.24.
//

import Foundation
import WatchConnectivity

class WatchSyncService : NSObject, WCSessionDelegate {
    private var session: WCSession = .default
    var dataReceived: ((WatchSyncKey, Any) -> Void)?
    
    init(session: WCSession = .default) {
        self.session = session

        super.init()

        self.session.delegate = self
        self.connect()
    }

    func connect(){
        guard WCSession.isSupported() else {
            Logger.shared.warn("WCSession is not supported")
            return
        }

        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { 
        Logger.shared.debug("activationDidCompleteWith: \(activationState.rawValue)")
        if let error = error {
            Logger.shared.error("activationDidCompleteWith: \(error.localizedDescription)")
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        Logger.shared.verbose("sessionDidBecomeInactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        Logger.shared.verbose("sessionDidDeactivate")
    }
    #endif

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard dataReceived != nil else {
            Logger.shared.warn("Received data, but 'dataReceived' handler is not provided")
            return
        }

        DispatchQueue.main.async {
            if let dataReceived = self.dataReceived {
                for pair in message {
                    guard let watchSyncKey = WatchSyncKey(rawValue: pair.key) else {
                        Logger.shared.warn("Invalid WatchSyncKey sent: \(pair.key)")
                        continue
                    }
                    Logger.shared.debug("Received message: KEY: [\(watchSyncKey.rawValue)] - MESSAGE: [\(pair.value)]")
                    dataReceived(watchSyncKey, pair.value)
                }
            }
        }
    }

    func sendMessage(_ key: WatchSyncKey, _ data: Any, _ errorHandler: ((Error?) -> Void)? = nil) {
        Logger.shared.debug("Send message: KEY: [\(key.rawValue)] - MESSAGE: [\(data)]")
        if session.isReachable {
            session.sendMessage([key.rawValue : data], replyHandler: nil) { (error) in
                Logger.shared.error("Could not send message for key [\(key.rawValue)]: \(error.localizedDescription)")
                if let errorHandler = errorHandler {
                    errorHandler(error)
                }
            }
        }
    }
}

