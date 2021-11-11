//
//  AutoStopApp.swift
//  AutoStop WatchKit Extension
//
//  Created by Mario Kohlhoff on 27.01.21.
//

import SwiftUI

@main
struct AutoStopApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView().environmentObject(ContentViewModel())
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
