//
//  ContentView.swift
//  autostop Watch App
//
//  Created by Mario Kohlhoff on 19.01.24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewModel

    var body: some View {
        VStack {
                HStack(spacing: 8.0) {
                    SleepingQuokkaView(isAnimating: $viewModel.timerStarted)
                    VStack {
                        Text("content-view_last-detection-at")
                            .bold()
                        Text(viewModel.stopDateString ?? "-")
                            .bold()
                    }
                    .frame(minWidth: 120)
            }
            
            Spacer()
            
            Button(viewModel.timerStarted ? "content-view_button-title-stop" : "content-view_button-title-start") {
                viewModel.timerStarted ? viewModel.stopTimer() : viewModel.startTimer()
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.primary)
            .cornerRadius(3.0)
            .foregroundColor(Color.black)
            .padding(.top, 4.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(4.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ContentViewModel())
        ContentView().environmentObject(ContentViewModel())
            .preferredColorScheme(.dark)
    }
}
