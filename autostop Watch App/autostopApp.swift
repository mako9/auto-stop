//
//  autostopApp.swift
//  autostop Watch App
//
//  Created by Mario Kohlhoff on 19.01.24.
//

import SwiftUI

@main
struct autostop_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(ContentViewModel())
        }
    }
}
