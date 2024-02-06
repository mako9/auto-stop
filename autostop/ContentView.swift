//
//  ContentView.swift
//  autostop
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
            
            if viewModel.timerStarted {
                SleepingQuokkaView()
                    .padding(.horizontal, 60.0)
            } else {
                Image(uiImage: UIImage(named: "quokka")!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 60.0)
            }
            
            Text("Detecting sleep ...")
                .padding(.top, 20.0)
                .opacity(viewModel.timerStarted ? 1 : 0)
            
            Spacer()

            Button(viewModel.timerStarted ? "STOP" : "START") {
                viewModel.timerStarted ? viewModel.stopTimer() : viewModel.startTimer()
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

struct SleepingQuokkaView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image("quokka")
                .resizable()
                .scaledToFit()
                .opacity(self.isAnimating ? 1 : 0)
            Image("quokka_sleeping")
                .resizable()
                .scaledToFit()
                .opacity(self.isAnimating ? 0 : 1)
            Image("sleeping_bubble")
                .resizable()
                .scaledToFit()
                .frame(width: 100, alignment: .topTrailing)
                .opacity(self.isAnimating ? 0 : 1)
        }
        .onAppear {
            withAnimation(.bouncy(duration: 2.0).repeatForever(autoreverses: true)) {
                self.isAnimating = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ContentViewModel())
    }
}
