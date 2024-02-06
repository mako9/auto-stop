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
            print("WCSession is not supported")
            return
        }
        
        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) { }
    #endif

    private func session(_ session: WCSession, didReceiveMessage message: [WatchSyncKey : Any]) {
        guard dataReceived != nil else {
            print("Received data, but 'dataReceived' handler is not provided")
            return
        }
        
        DispatchQueue.main.async {
            if let dataReceived = self.dataReceived {
                for pair in message {
                    dataReceived(pair.key, pair.value)
                }
            }
        }
    }

    func sendMessage(_ key: WatchSyncKey, _ data: Any, _ errorHandler: ((Error?) -> Void)?) {
        if session.isReachable {
            session.sendMessage([key.rawValue : data], replyHandler: { _ in
                if let errorHandler = errorHandler {
                    errorHandler(nil)
                }
            }) { (error) in
                print(error.localizedDescription)
                if let errorHandler = errorHandler {
                    errorHandler(error)
                }
            }
        }
    }
}

