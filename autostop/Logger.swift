//
//  Logger.swift
//  AutoStop WatchKit Extension
//
//  Created by Mario Kohlhoff on 11.11.21.
//

import Foundation

enum LogLevel: String {
    case verbose = "VERBOSE"
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

class Logger {
    static let shared = Logger()

    private let dateFormatter: DateFormatter

    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm:ss.SSSS"
    }

    func log(_ message: Any?, level: LogLevel = .debug) {
        #if DEBUG
        let timestamp = dateFormatter.string(from: Date())
        if let stringMessage = message as? String {
            print("\(timestamp)  |  \(level.rawValue):  \(stringMessage)")
        } else if let anyObject = message as Any? {
            print("\(timestamp)  |  \(level.rawValue):  \(anyObject)")
        } else {
            print("\(timestamp)  |  \(level.rawValue):   nil")
        }
        #endif
    }

    func verbose(_ message: Any) {
        log(message, level: .verbose)
    }

    func debug(_ message: Any?) {
        log(message)
    }

    func info(_ message: Any) {
        log(message, level: .info)
    }

    func warn(_ message: Any) {
        log(message, level: .warning)
    }

    func error(_ message: Any) {
        log(message, level: .error)
    }
}

