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
            if !viewModel.isConnectionAvailable {
                HStack {
                    Image(systemName: "info.circle")
                    Text("content-view_iPhone-not-reachable")
                        .minimumScaleFactor(0.5)
                        .padding(4.0)
                }
                .font(.title2)
                .frame(maxWidth: .infinity, maxHeight: 50.0)
                .foregroundColor(.black)
                .background(Color.orange)
                .cornerRadius(8.0)
            } else {
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
            }
            
            Spacer()
            
            Button(viewModel.timerStarted ? "content-view_button-title-stop" : "content-view_button-title-start") {
                viewModel.timerStarted ? viewModel.stopTimer() : viewModel.startTimer()
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(viewModel.isConnectionAvailable ? Color.primary : Color.secondary)
            .foregroundColor(Color.black)
            .cornerRadius(24.0)
            .padding(.top, 4.0)
            .disabled(!viewModel.isConnectionAvailable)
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
