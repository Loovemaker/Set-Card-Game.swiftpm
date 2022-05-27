//
//  SwiftUIView.swift
//  
//
//  Created by Z. D. Yu on 22.M.22.
//

import SwiftUI

/// 进入游戏的初始View
struct IntroView: View {
    
    @Binding var gameState: GameState
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            AdaptiveStack(vAlignment: .center, hAlignment: .center, spacing: 75) { _, _ in
                VStack(spacing: size / 20) {
                    AppIconView(size: size / 2)
                    Text("Set纸牌游戏")
                        .font(.system(size: size / 16))
                        .foregroundColor(.secondary)
                }
                buttons
            }
            .frame(width: geometry.size.width,
                   height: geometry.size.height,
                   alignment: .center)
        }
    }

    var buttons: some View {
        VStack(spacing: 50) {
            Button {
                gameState = .inGame
            } label: {
                Label("进入游戏", systemImage: "play.circle.fill")
                    .font(.largeTitle.bold())
            }
            Button {
                gameState = .tutorial
            } label: {
                Label("如何游玩", systemImage: "questionmark.circle.fill")
                    .font(.largeTitle.bold())
            }
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView(gameState: .constant(.intro))
            .previewDevice(.init(rawValue: "iPhone 11"))
            .preferredColorScheme(.light)
            .previewInterfaceOrientation(.portrait)
        IntroView(gameState: .constant(.intro))
            .previewDevice(.init(rawValue: "iPhone 6s"))
            .preferredColorScheme(.dark)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
