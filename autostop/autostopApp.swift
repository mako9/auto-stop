//
//  autostopApp.swift
//  autostop
//
//  Created by Mario Kohlhoff on 19.01.24.
//

import SwiftUI

@main
struct autostopApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(ContentViewModel())
        }
    }
}
