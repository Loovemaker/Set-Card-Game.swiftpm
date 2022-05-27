//
//  SetGameApp.swift
//  Set
//
//  Created by Z. D. Yu on 22.F.24.
//

import SwiftUI

/// **《Set纸牌游戏》**
///
///
/// Set纸牌游戏中每张牌具有4个特征，每种特征有3种值，在本App中为：
///
/// -   颜色：🔴、🟡、🔵
/// -   边框：白色、半透明、黑色
/// -   字符内容：☠️、👽、💩 _（哈哈哈，这游戏我不是用来上架的，不需要看某局的脸色）_
/// -   字符数量：▢、▢▢、▢▢▢
///
/// 卡组则是由所有4个特征排列而成的所有卡的集合，因此为81张且不存在重复的卡片。
///
/// 抽出其中的一些卡片（一般为12张或15张）至场上。你需要找出满足以下所有条件的一组3张卡，称为 “Set”：
///
/// 对于4个特征任意一个，满足以下其中一个条件：
///
/// -   3张卡片的该特征值完全相等
/// -   3张卡片任意取2张卡片，其特征值均不相等
///
/// Set后该组卡片不再使用，移入“墓地”即可。
///
/// 直至卡组的所有卡片全部抽出，且场上的卡片无法构成Set（一般剩余6张或9张），游戏完成。
///
///
///
/// 详见[Wiki](https://en.wikipedia.org/wiki/Set_(card_game))。
///
@main
struct SetGameApp: App {
    
    // TODO: 添加多语言支持（其实俺只会Chinglish）
    // TODO: 添加自动化测试功能
    
    @State private var gameState: GameState = .initial

    var body: some Scene {
        WindowGroup {
            gameState.view($gameState)
        }
    }
}
