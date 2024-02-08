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
            Text("content-view_title")
                .font(.title)
                .bold()
                .padding(.bottom)
           
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
            .background(Color.primary)
            .foregroundColor(Color("WhiteTextColor", bundle: nil))
            .cornerRadius(3.0)
            .shadow(radius: 3.0, y: 5.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ContentViewModel())
        ContentView().environmentObject(ContentViewModel())
            .preferredColorScheme(.dark)
    }
}
