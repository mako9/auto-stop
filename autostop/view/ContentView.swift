//
//  ContentView.swift
//  autostop
//
//  Created by Mario Kohlhoff on 19.01.24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @State private var showingAlert = false

    var body: some View {
        VStack {
            if !viewModel.isConnectionAvailable {
                Button(action: {
                    showingAlert = true
                }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("content-view_watch-not-reachable")
                            .minimumScaleFactor(0.5)
                    }
                }
                    .font(.title2)
                    .frame(maxWidth: .infinity, maxHeight: 50.0)
                    .foregroundColor(.black)
                    .background(Color.orange)
            }

            VStack {
                Text("content-view_title")
                    .font(.title)
                    .bold()
               
                Spacer()
                
                SleepingQuokkaView(isAnimating: $viewModel.timerStarted)
                    .padding(.horizontal, 60.0)
                    .frame(maxHeight: 240)
                
                Text("content-view_detecting-sleep")
                    .padding(.top, 20.0)
                    .frame(alignment: .top)
                    .opacity(viewModel.timerStarted ? 1 : 0)
                
                Spacer()
                
                VStack {
                    Text("content-view_last-detection-at")
                        .bold()
                    Text(viewModel.stopDateString ?? "-")
                        .bold()
                }
                .padding(.bottom)


                Button(viewModel.timerStarted ? "content-view_button-title-stop" : "content-view_button-title-start") {
                    viewModel.timerStarted ? viewModel.stopTimer() : viewModel.startTimer()
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(viewModel.isConnectionAvailable ? Color.primary : Color.secondary)
                .foregroundColor(Color("WhiteTextColor", bundle: nil))
                .cornerRadius(3.0)
                .shadow(radius: 3.0, y: 5.0)
                .disabled(!viewModel.isConnectionAvailable)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("content-view_missing-connection-description", isPresented: $showingAlert) {
            Button("ok", role: .cancel) {
                showingAlert = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ContentViewModel())
        ContentView().environmentObject(ContentViewModel())
            .preferredColorScheme(.dark)
    }
}
