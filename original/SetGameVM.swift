//
//  SetGameVM.swift
//  Set
//
//  Created by Z. D. Yu on 22.F.24.
//

import Foundation
import SwiftUI

#if DEBUG
let interval = 1
#else
let interval = 90
#endif

/// 游戏场景的ViewModel。（本App采用SwiftUI采用的 [MVVM](https://zhuanlan.zhihu.com/p/59467370) 架构）
/// 
/// 由于需要使用观察者模式（符合`ObservableObject`协议），成为引用类型（`class`）而不是值类型（`struct`）。
class SetGameVM: ObservableObject {
    /// 游戏场景的Model
    @Published private var game: SetGame
    
    typealias Card = SetGame.Card
    #if DEBUG
    static let interval = 1.0
    #else
    static let interval = 90.0
    #endif
    /// 类似游戏技能冷却的计时系统，用于提示功能
    ///
    /// 冷却时间一般为90秒，Debug模式下为1秒
    @Published var cdSystem = SimpleCDSystem(interval: interval)
    
    /// 游戏场景的ID为随机生成的UUID（version 4）
    init() {
        game = .init()
        #if DEBUG
        print("There is a possible move, in indices: \(firstPossibleIndices.debugDescription)")
        #endif
    }
    
    /// 使用了多少次提示
    @Published private(set) var hintsUsed = 0

    /// 选中的卡片
    @Published var selectedCards: Set<Card> = []
    /// 选中的卡片对应在场上的索引值
    var selectedIndices: [Int] {
        selectedCards.map { game.field.firstIndex(matchingId: $0)! }
    }
    
    /// 等待抽出的卡组
    var deck: [Card] { game.deck }
    /// 场上的卡
    var field: [Card] { game.field }
    /// Set成功后的卡，3个一组
    var grave: [SetGame.Set] { game.grave }
}

// MARK: 以下是功能扩展

/// 抽卡功能
extension SetGameVM {
    /// 满足以下条件地抽卡
    /// -   在卡组正常的情况下，至少抽3张
    /// -   在卡组正常的情况下，场上至少12张
    /// -   除非游戏完成，场上有至少一组Set
    func drawCard() {
        game.drawCard(count: 3)
        game.drawUntilThereIsEnoughCards(noLessThan: 12)
        game.drawUntilPossibleMoveExists()
        #if DEBUG
        print("A possible move is these indices: \(firstPossibleIndices.debugDescription)")
        #endif
    }
}

/// 提示功能
extension SetGameVM {
    #if DEBUG
    /// 在场上卡片中找到一个Set，返回在场上对应的索引值
    ///
    /// Note: 仅Debug模式可用
    var firstPossibleIndices: Set<Int> {
        guard let move = game.firstPossibleMove else { return [] }
        
        return Set(move.cards.map { card in
            game.field.firstIndex { $0 == card }!
        })
    }
    #endif

    /// 尝试得到提示
    /// - Returns: 是否成功得到提示
    @discardableResult
    func hint() -> Bool {
        guard cdSystem.activate() else {
            print("""
            请求过于频繁！
            请在 \(Int(cdSystem.timeLeft))秒 后尝试。
            """)
            return false
        }
        
        defer { hintsUsed += 1 }

        selectedCards.removeAll()
        
        game.drawUntilPossibleMoveExists()
        guard let move = game.firstPossibleMove else { return false }   // false means game finished
        
        select(card: move.cards[0])
        select(card: move.cards[1])
        
        return true
    }
}

/// 选择与Set功能
extension SetGameVM {
    /// 选择卡片并尝试进行Set
    /// - Returns: 是否Set成功
    @discardableResult
    func select(card: Card) -> Bool {
        guard game.field.contains(card) else { return false }
        if let _ = selectedCards.remove(card) {}
        else { selectedCards.insert(card) }
        guard selectedCards.count == 3 else { return false }
//        defer { selectedCards.removeAll() }
        return set(.init(
            selectedCards.popFirst()!,
            selectedCards.popFirst()!,
            selectedCards.popFirst()!)
        )
    }
    
    /// 尝试进行Set
    /// - Parameter cardSet: 可传入任意3张卡片，无需关心是否能组成Set
    /// - Returns: Set是否成功
    private func `set`(_ cardSet: SetGame.Set?) -> Bool {
        let result = game.set(cardSet)
        
        if result {
            #if DEBUG
            print("A possible move is these indices: \(firstPossibleIndices.debugDescription)")
            #endif
        }
        
        return result
    }
}
