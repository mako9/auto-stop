//
//  SleepingQuokkaView.swift
//  autostop
//
//  Created by Mario Kohlhoff on 07.02.24.
//

import SwiftUI

struct SleepingQuokkaView: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        if isAnimating {
            SleepingQuokkaAnimationView()
        } else {
            Image(uiImage: UIImage(named: "quokka")!)
                .resizable()
                .scaledToFit()
        }
    }
}

struct SleepingQuokkaAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Image("quokka")
                .resizable()
                .scaledToFit()
                .opacity(self.isAnimating ? 0 : 1)
            GeometryReader { geometry in
                ZStack(alignment: .topTrailing) {
                    Image("quokka_sleeping")
                        .resizable()
                        .scaledToFit()
                        .opacity(self.isAnimating ? 1 : 0)
                    Image("sleeping_bubble")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.35, height: geometry.size.height * 0.35, alignment: .topTrailing)
                        .opacity(self.isAnimating ? 1 : 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            withAnimation(.bouncy(duration: 2.0).repeatForever(autoreverses: true)) {
                self.isAnimating = true
            }
        }
    }
}

struct SleepingQuokkaView_Previews: PreviewProvider {
    static var previews: some View {
        SleepingQuokkaView(isAnimating: .constant(false))
        SleepingQuokkaView(isAnimating: .constant(true))
        SleepingQuokkaView(isAnimating: .constant(true))
            .frame(height: 50)
    }
}
