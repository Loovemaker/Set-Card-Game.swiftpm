//
//  GameState.swift
//  
//
//  Created by Z. D. Yu on 22.M.23.
//

import SwiftUI

/// 游戏场景的状态
///
/// 二年级小学生都知道，游戏的状态管理最好由**状态机**完成。
///
/// 我在gayhub上物色了一个看起来还不错的状态机模型，
/// 但鉴于两国关系，我无法正常使用它。
enum GameState {
    /// 游戏场景的状态：初始状态
    case intro
    /// 游戏场景的状态：初始状态
    static var initial: Self { .intro }
    /// 游戏场景的状态：如何游玩
    case tutorial
    /// 游戏场景的状态：进入游戏
    case inGame
    
    /// 游戏状态对应的View
    ///
    /// 想要修改View，只要修改游戏状态就好了。
    @ViewBuilder
    func view(_ state: Binding<Self>) -> some View {
        switch self {
        case .intro:
            IntroView(gameState: state)
                .transition(.opacity.animation(.easeInOut(duration: 0.7)))
        case .tutorial:
            TutorialView(gameState: state)
                .environmentObject(SetGameVM())
                .transition(.opacity.animation(.easeInOut(duration: 0.7)))
        case .inGame:
            SetGameView()
                .environmentObject(SetGameVM())
                .transition(.opacity.animation(.easeInOut(duration: 0.7)))
//        default:
//            fatalError("Illegal game state!")
        }
    }
}
