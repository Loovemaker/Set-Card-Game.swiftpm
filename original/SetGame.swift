//
//  SetGame.swift
//  Set
//
//  Created by Z. D. Yu on 22.F.24.
//

import Foundation

struct SetGame: Identifiable {
    
    // MARK: Stored properties
    
    var deck: [Card] = []
    var field: [Card] = []
    var grave: [SetGame.Set] = []
    
    let id: UUID?
    
    // MARK: Data Structures
    
    struct Card: Identifiable, Hashable, Equatable, CaseIterable {
        
        let number: Number
        let content: Content
        let shading: Shading
        let color: Color
        
        private(set) var deckID: UUID? = nil
        var id: Int { hashValue }
        
        typealias Feature = CaseIterable & Equatable
        enum Number: Int, Feature {
            case one = 1
            case two = 2
            case three = 3
        }
        enum Content: String, Feature {
            case a = "☠️"
            case b = "💩"
            case c = "👽"
        }
        enum Shading: Feature {
            case white
            case gray
            case black
        }
        enum Color: Feature {
            case red
            case yellow
            case blue
        }
        
        static var allCases: Swift.Set<Card> {
            allCases(deckID: nil)
        }
        
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
        
        static func == (lhs: Card, rhs: Card) -> Bool {
            lhs.number == rhs.number &&
            lhs.content == rhs.content &&
            lhs.shading == rhs.shading &&
            lhs.color == rhs.color
        }
    }
    
    struct Set: Hashable, Equatable {

        static let CARDS_COUNT = 3
        let cards: [Card]
        
        init?(_ card0: Card, _ card1: Card, _ card2: Card) {
            guard card0 == Card.fromOtherOf(card1, card2) else { return nil }
            self.cards = [card0, card1, card2]
        }
    }
    
    init(id: UUID? = nil) {
        self.id = id
        deck = Card.allCases(deckID: id).map { $0 }.shuffled()
//        drawUntilPossibleMoveExists()
//        drawUntilThereIsEnoughCards(noLessThan: initialCardsCount)
    }
    
}

// MARK: Functionalities

extension SetGame {

    mutating func `set`(_ cardSet: Self.Set?) -> Bool {
        guard let cardSet = cardSet else { return false }
        
        let isInField = cardSet.cards.map { field.contains($0) }
        guard !isInField.contains(false) else { return false }
        
        for card in cardSet.cards { field.remove(matchingId: card) }
        grave.append(cardSet)
        
        return true
    }
}
 
extension SetGame {
    
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
    
    /// - Returns: if the deck is still not drawn to empty
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
    
extension SetGame {
    
    var isFinished: Bool {
        deck.isEmpty && (firstPossibleMove == nil)
    }
    
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

extension SetGame.Set {
    
    typealias Card = SetGame.Card
    
    /// Why?
    /// Given any two cards from the deck, there is **one and only one** other card that forms a set with them.
    /// Note: The other card will be put into the first.
    init?(_ card1: Card, _ card2: Card) {
        guard let card0 = Card.fromOtherOf(card1, card2) else { return nil }
        self.cards = [card0, card1, card2]
    }
}
extension SetGame.Card {
    
    typealias Card = SetGame.Card
    
    /// Why?
    /// Given any two cards from the deck, there is **one and only one** other card that forms a set with them.
    private static func theOtherFeatureOf<Feature>(
        _ feature1: Feature,
        _ feature2: Feature
    ) -> Feature? where Feature: Card.Feature {
        if feature1 == feature2 { return feature1 }
        
        var allFeatures = Array(Feature.allCases)
        guard allFeatures.count == 3 else { return nil }
        allFeatures.removeAll { $0 == feature1 }
        allFeatures.removeAll { $0 == feature2 }
        
        return allFeatures.first
    }
    
    /// Why?
    /// Given any two cards from the deck, there is **one and only one** other card that forms a set with them.
    static func fromOtherOf(_ card1: Card, _ card2: Card) -> Card? {
        guard let number = theOtherFeatureOf(card1.number, card2.number),
              let content = theOtherFeatureOf(card1.content, card2.content),
              let shading = theOtherFeatureOf(card1.shading, card2.shading),
              let color  = theOtherFeatureOf(card1.color, card2.color)
        else { return nil }
        return .init(
            number: number,
            content: content,
            shading: shading,
            color: color,
            deckID: card1.deckID == card2.deckID ? card1.deckID : nil
        )
    }
}

extension Array where Element == SetGame.Set {

    var flattened: [SetGame.Card] {
        self.map { $0.cards }.joined().map { $0 }
    }
}
