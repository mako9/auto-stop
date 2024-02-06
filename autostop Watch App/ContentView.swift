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
            VStack {
                Text("Last stop:")

                Text(viewModel.stopDateString ?? "-")

                if viewModel.stoppedAudio {
                    Image(systemName: "pause")
                }

                if viewModel.isRunning {
                    ProgressView()
                        .frame(width: 12, height: 12)
                }
            }

            Spacer()

            Button(viewModel.isRunning ? "STOP" : "START") {
                viewModel.isRunning ? viewModel.stopTimer() : viewModel.startTimer()
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.blue)
            .foregroundColor(Color.white)
            .cornerRadius(3.0)
            .shadow(radius: 3.0, y: 5.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
