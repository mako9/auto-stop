//
//  ContentView.swift
//  AutoStop WatchKit Extension
//
//  Created by Mario Kohlhoff on 27.01.21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewModel

    var body: some View {
        VStack {
            VStack {
                Text("Last stop:")

                Text(viewModel.stopDateString ?? "-")
            }

            Spacer()

            Button("Check") {
                viewModel.checkForStop()
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
