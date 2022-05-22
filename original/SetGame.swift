//
//  SetGame.swift
//  Set
//
//  Created by Z. D. Yu on 22.F.24.
//

import Foundation


/// 游戏场景的Model
struct SetGame: Identifiable {
    
    /// 等待抽出的卡组
    var deck: [Card] = []
    /// 场上的卡
    var field: [Card] = []
    /// Set成功后的卡，3个一组
    var grave: [SetGame.Set] = []
    
    /// 游戏场景的ID
    private(set) var id: UUID? = nil
    
    /// 卡片的Model
    struct Card: Identifiable, Hashable, Equatable, CaseIterable {
        
        let number: Number
        let content: Content
        let shading: Shading
        let color: Color
        
        /// 所在卡组的ID
        private(set) var deckID: UUID? = nil
        /// 卡片的ID值，
        /// `Identifiable`协议要求，
        /// 为4个特征值与所在卡组的ID组合而成的hash值（可惜了只有64位）
        var id: Int { hashValue }
        
        /// 所有特征的共同功能，即可枚举与可判断是否相等
        typealias Feature = CaseIterable & Equatable
        /// 特征：字符数量
        enum Number: Int, Feature {
            case one = 1
            case two = 2
            case three = 3
        }
        /// 特征：字符内容
        enum Content: String, Feature {
            case a = "☠️"
            case b = "💩"
            case c = "👽"
        }
        /// 特征：边框
        enum Shading: Feature {
            case white
            case gray   // 半透明
            case black
        }
        /// 特征：颜色
        enum Color: Feature {
            case red
            case yellow
            case blue
        }
        
        /// 用于游戏场景的初始化，即排列所有81张卡
        ///
        /// Note：此时卡片所在的卡组ID值为`nil`
        static var allCases: Swift.Set<Card> {
            allCases(deckID: nil)
        }
        
        /// 用于游戏场景的初始化
        /// - Parameter deckID: 给所有卡片赋予的游戏场景ID值
        /// - Returns: 所有81张卡的集合（`Swift.Set`）
        static func allCases(deckID: UUID?) -> Swift.Set<Card> {
            var result: Swift.Set<Card> = []
            for number in Number.allCases {
                for shape in Content.allCases {
                    for shading in Shading.allCases {
                        for color in Color.allCases {
                            result.insert(.init(
                                number: number,
                                content: shape,
                                shading: shading,
                                color: color,
                                deckID: deckID
                            ))
                        }
                    }
                }
            }
            return result
        }
        
        /// 判断卡片是否相等时仅判断特征值，不判断所在游戏场景ID
        static func == (lhs: Card, rhs: Card) -> Bool {
            lhs.number == rhs.number &&
            lhs.content == rhs.content &&
            lhs.shading == rhs.shading &&
            lhs.color == rhs.color
        }
    }
    
    /// 满足游戏规则的一组3张卡的Model
    ///
    /// 3张不满足游戏规则的卡片将无法组成Set，`init`过程将会失败并返回`nil`
    struct Set: Hashable, Equatable {

        static let CARDS_COUNT = 3
        let cards: [Card]   // 游戏规则的限定条件已在`init`中生效，因此不支持修改
        
        /// 3张不满足游戏规则的卡片将无法组成Set，`init`过程将会失败并返回`nil`
        init?(_ card0: Card, _ card1: Card, _ card2: Card) {
            guard card0 == Card.fromOtherOf(card1, card2) else { return nil }
            self.cards = [card0, card1, card2]
        }
    }
    
    /// 在`init`完成前游戏场景会洗牌
    /// - Parameter id: 游戏场景ID值
    init(id: UUID? = nil) {
        self.id = id
        deck = Card.allCases(deckID: id).map { $0 }.shuffled()
    }
    
}

// MARK: 以下是功能扩展

/// 组成Set后游戏场景应该做的事
extension SetGame {

    /// 组成Set后游戏场景应该做的事
    /// - Parameter cardSet: 一组3张牌，无需提前检查是否可Set
    /// - Returns: 是否成功Set
    mutating func `set`(_ cardSet: Self.Set?) -> Bool {
        guard let cardSet = cardSet else { return false }
        
        let isInField = cardSet.cards.map { field.contains($0) }
        guard !isInField.contains(false) else { return false }
        
        for card in cardSet.cards { field.remove(matchingId: card) }
        grave.append(cardSet)
        
        return true
    }
}

/// 抽卡功能
extension SetGame {
    
    /// 普通的抽卡
    /// - Parameter count: 准备抽出的数量，默认为1张
    /// - Returns: 实际抽出的数量，可用于判断卡组是否已抽空等
    @discardableResult
    mutating func drawCard(count: Int = 1) -> Int {
        guard count > 0 else { return 0 }
        var cardsDrawnCount = 0

        for _ in 0 ..< count {
            guard let card = deck.popLast() else { break }
            field.append(card)
            cardsDrawnCount += 1
        }
        
        return cardsDrawnCount
    }
    
    /// 一直抽，直到场上出现至少一组Set
    ///
    /// Warning⚠️：游戏后期可能会出现卡组抽空、场上剩余卡片且无法组成Set的情况，此时使用此方法会导致死循环。
    /// - Returns: 卡组是否已经被抽空
    @discardableResult
    mutating func drawUntilPossibleMoveExists() -> Bool {
        while firstPossibleMove == nil {
            guard drawCard(count: 3) == 3 else { return false }
        }
        return true
    }
    
    /// - Returns: if the deck is still not drawn to empty
    @discardableResult
    mutating func drawUntilThereIsEnoughCards(noLessThan n: Int) -> Bool {
        while field.count < n {
            guard drawCard(count: 3) == 3 else { return false }
        }
        return true
    }
}

/// 判断游戏是否已完成
extension SetGame {
    var isFinished: Bool {
        deck.isEmpty && (firstPossibleMove == nil)
    }
}

/// 在游戏中给予提示的功能
extension SetGame {
    
    /// 在场上卡片中找到一个Set，有可能找不到而为`nil`
    var firstPossibleMove: Set? {
        guard field.count >= 3 else { return nil }
        
        for index1 in 0..<(field.count-1) {
            for index2 in (index1+1) ..< field.count {
                let card1 = field[index1], card2 = field[index2]
                guard let card0 = Card.fromOtherOf(card1, card2) else { continue }
                guard ![card0, card1, card2].map({ field.contains($0) }).contains(false)
                else { continue }
                return .init(card0, card1, card2)
            }
        }
        
        return nil
    }
    
    /// 在场上卡片中找到所有Set
    var allPossibleMoves: [Set] {
        var result: [Set] = []
        
        guard field.count >= 3 else { return [] }
        
        for index1 in 0..<(field.count-1) {
            for index2 in (index1+1) ..< field.count {
                let card1 = field[index1], card2 = field[index2]
                guard let card0 = Card.fromOtherOf(card1, card2) else { continue }
                guard ![card0, card1, card2].map({ field.contains($0) }).contains(false)
                else { continue }
                result.append(.init(card0, card1, card2)!)
            }
        }
        
        return result
    }
}

/// 因为《Set纸牌游戏》有以下性质，所以可扩展功能：
/// -  同一个游戏场景中，给予任意两张卡片，在该游戏场景的81张卡片中有且仅有一张卡片组成Set。
extension SetGame.Set {
    
    typealias Card = SetGame.Card
    
    /// 同一个游戏场景中，给予任意两张卡片，在该游戏场景的81张卡片中有且仅有一张卡片组成Set。
    init?(_ card1: Card, _ card2: Card) {
        guard let card0 = Card.fromOtherOf(card1, card2) else { return nil }
        self.cards = [card0, card1, card2]
    }
}
extension SetGame.Card {
    
    typealias Card = SetGame.Card
    
    /// 给予两个特征值，会发生以下情况：
    /// -   两个特征值相等，需要另一个相等的特征值以组成Set
    /// -   两个特征值不等，需要另一个互不相等的特征值以组成Set
    /// - Returns: 能组成Set的另一个特征值
    private static func theOtherFeatureOf<Feature>(
        _ feature1: Feature,
        _ feature2: Feature
    ) -> Feature where Feature: Card.Feature {
        if feature1 == feature2 { return feature1 }
        
        var allFeatures = Array(Feature.allCases)
        precondition(allFeatures.count == 3)
        allFeatures.removeAll { $0 == feature1 }
        allFeatures.removeAll { $0 == feature2 }
        
        return allFeatures.first!
    }
    
    /// 同一个游戏场景中，给予任意两张卡片，在该游戏场景的81张卡片中有且仅有一张卡片组成Set。
    /// - Returns:在相同的游戏场景下传入两张特征值完全相同的卡片并不符合游戏规则，会返回`nil`；
    /// 而不同游戏场景下会返回特征值完全相同的另一张卡片。
    /// 若传入的两张卡片中有相同的游戏场景ID，返回的另一张卡片也将有相同的游戏场景ID，否则游戏场景ID为`nil`。
    static func fromOtherOf(_ card1: Card, _ card2: Card) -> Card? {
        let isSameDeckID = (card1.deckID == card2.deckID)
        guard !isSameDeckID || card1 != card2 else { return nil }
        return .init(
            number: theOtherFeatureOf(card1.number, card2.number),
            content: theOtherFeatureOf(card1.content, card2.content),
            shading: theOtherFeatureOf(card1.shading, card2.shading),
            color: theOtherFeatureOf(card1.color, card2.color),
            deckID: isSameDeckID ? card1.deckID : nil
        )
    }
}

/// 使3张卡片的Set为一组的“墓地”展开变成普通的`Array`
extension Array where Element == SetGame.Set {

    var flattened: [SetGame.Card] {
        self.map { $0.cards }.joined().map { $0 }
    }
}
