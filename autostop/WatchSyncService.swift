//
//  WatchSyncService.swift
//  autostop
//
//  Created by Mario Kohlhoff on 19.01.24.
//

import Foundation
import WatchConnectivity

protocol WatchSyncServiceDelegate {
    func connectionAvailable(_ isAvailable: Bool)
}

class WatchSyncService : NSObject, WCSessionDelegate {
    private var delegate: WatchSyncServiceDelegate
    private var session: WCSession = .default
    var dataReceived: ((WatchSyncKey, Any) -> Void)?
    
    init(delegate: WatchSyncServiceDelegate, session: WCSession = .default) {
        self.delegate = delegate
        self.session = session

        super.init()

        self.session.delegate = self
        self.connect()
    }

    func connect(){
        guard WCSession.isSupported() else {
            Logger.shared.warn("WCSession is not supported")
            delegate.connectionAvailable(false)
            return
        }

        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Logger.shared.debug("activationDidCompleteWith: ActivationState: \(activationState.rawValue) | isReachable: \(session.isReachable)")
        if let error = error {
            Logger.shared.error("activationDidCompleteWith: \(error.localizedDescription)")
        }
        updateConnectionAvailability(session)
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        Logger.shared.debug("sessionDidBecomeInactive")
        updateConnectionAvailability(session)
    }

    func sessionDidDeactivate(_ session: WCSession) {
        Logger.shared.debug("sessionDidDeactivate")
        updateConnectionAvailability(session)
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        Logger.shared.debug("sessionWatchStateDidChange: \(session.activationState)")
        updateConnectionAvailability(session)
    }
    #endif

    func sessionReachabilityDidChange(_ session: WCSession) {
        Logger.shared.debug("sessionReachabilityDidChange: \(session.isReachable)")
        updateConnectionAvailability(session)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        receivedMessage(message)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        receivedMessage(userInfo)
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
        } else {
            session.transferUserInfo([key.rawValue : data])
        }
    }

    private func updateConnectionAvailability(_ session: WCSession) {
        #if os(watchOS)
            delegate.connectionAvailable(session.activationState == .activated && session.isCompanionAppInstalled)
        #elseif os(iOS)
            delegate.connectionAvailable(
                session.activationState == .activated &&
                session.isPaired &&
                session.isWatchAppInstalled
            )
        #endif
    }

    private func receivedMessage(_ message: [String: Any]) {
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
}

