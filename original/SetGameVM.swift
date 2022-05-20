//
//  SetGameVM.swift
//  Set
//
//  Created by Z. D. Yu on 22.F.24.
//

import Foundation
import SwiftUI

class SetGameVM: ObservableObject {
    @Published private var game: SetGame
    typealias Card = SetGame.Card
    #if DEBUG
    @Published var cdSystem = SimpleCDSystem(interval: 1)
    #else
    @Published var cdSystem = SimpleCDSystem(interval: 90)
    #endif
    
    init(drawCard count: Int = 0) {
        game = .init(id: UUID())
        drawCard(count: count)
        #if DEBUG
        print("There is a possible move, in indices: \(firstPossibleIndices.debugDescription)")
        #endif
    }

    @Published private(set) var hintsUsed = 0

    @Published var selectedCards: Set<Card> = []
    var selectedIndices: [Int] {
        selectedCards.map { game.field.firstIndex(matchingId: $0)! }
    }
    
    // MARK: Intent
    
    var deck: [Card] { game.deck }
    var field: [Card] { game.field }
    var grave: [SetGame.Set] { game.grave }
    
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
    
    private func `set`(_ cardSet: SetGame.Set?) -> Bool {
        let result = game.set(cardSet)
        
        if result {
            #if DEBUG
            print("A possible move is these indices: \(firstPossibleIndices.debugDescription)")
            #endif
//            game.drawUntilPossibleMoveExists()
//            game.drawUntilThereIsEnoughCards(noLessThan: 12)
        }
        
        return result
    }
    
    #if DEBUG
    /// A cheating tool that is public to player's view
    /// Dev mode only!
    var firstPossibleIndices: Set<Int> {
        guard let move = game.firstPossibleMove else { return [] }
        
        return Set(move.cards.map { card in
            game.field.firstIndex { $0 == card }!
        })
    }
    #endif
    
    @discardableResult
    func hint() -> Bool {
        guard cdSystem.activate() else {
            print("""
            Hinted too frequent!
            Try again \(Int(cdSystem.timeLeft)) seconds later
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
    
    func drawCard(count: Int = 1) {
        game.drawCard(count: count)
        #if DEBUG
        print("A possible move is these indices: \(firstPossibleIndices.debugDescription)")
        #endif
    }
}
