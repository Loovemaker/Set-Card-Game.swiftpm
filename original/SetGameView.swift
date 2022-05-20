//
//  SetGameView.swift
//  Set
//
//  Created by Z. D. Yu on 22.F.24.
//

import SwiftUI

struct SetGameView: View {
    
    @EnvironmentObject var gameVM: SetGameVM
    @State private var hintReady = false
    
    @Namespace private var cardGeometryNamespace
    
    var body: some View {
        VStack {
            fieldView
            HStack(alignment: .bottom, spacing: 50) {
                deckView
                hintView
                graveView
            }
        }
        .padding()
    }
    
    var hintView: some View {
        Button {
            withAnimation(.easeIn(duration: 1.0)) {
                let _ = gameVM.hint()
            }
        } label: {
            VStack {
                Image(systemName:
                        hintReady ? "lightbulb.fill" : "lightbulb")
                    .foregroundColor(.accentColor)
                    .font(.title)
                Text("hint")
                    .font(.caption)
            }
        }
        .disabled(!hintReady)
        .opacity(hintReady ? 1 : 0.5)
        .onAppear {
            gameVM.cdSystem.eventHandlers.append {
                hintReady = gameVM.cdSystem.refresh()
            }
        }
        
    }
    
    var fieldView: some View {
        AspectVGrid(
            items: gameVM.field,
            aspectRatio: 3 / 4
        ) { card in
            CardView(card: card)
//                .environmentObject(gameVM)
                .matchedGeometryEffect(id: card.id, in: cardGeometryNamespace)
                .onTapGesture {
                    withAnimation(.interactiveSpring()) {
                        let _ = gameVM.select(card: card)
                    }
                }
        }
    }
    func stackedCardsView(of cards: [SetGameVM.Card],
                          transition: AnyTransition) -> some View {
        ZStack {
            ForEach(cards) { card in
                let index = cards.firstIndex(of: card) ?? 0
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in:
                                            cardGeometryNamespace)
                    .transition(transition)
                    .aspectRatio(3 / 4, contentMode: .fit)
                    .frame(width: 80, height: nil, alignment: .center)
                    .zIndex(Double(index))
                    .offset(x: 0, y: CGFloat(1-min(2, index) * 5))
            }
        }
    }
    var deckView: some View {
        VStack {
            stackedCardsView(
                of: gameVM.deck,
                transition: .asymmetric(insertion: .scale,
                                        removal: .identity.animation(.spring()))
            )
                .onTapGesture {
                    Task {
                        for _ in 0 ..< 3 {
                            withAnimation(.spring()) {
                                gameVM.drawCard()
                            }
                            try? await Task.sleep(nanoseconds: UInt64(0.1 * Double(NSEC_PER_SEC)))
                        }
                    }
                }
            let count = gameVM.deck.count
            Text(count == 81 ? "Tap me to start!" : "\(count) remaining")
                .font(.caption)
                .opacity(count == 0 ? 0 : 1)
        }
    }
    var graveView: some View {
        VStack {
            stackedCardsView(
                of: gameVM.grave.flattened,
                transition: .asymmetric(insertion: .identity.animation(.spring()),
                                        removal: .opacity)
            )
                .animation(.spring(), value: gameVM.grave)
            let count = gameVM.grave.count * SetGame.Set.CARDS_COUNT
            if count >= 81 {
                Text("All Set!")
                    .font(.caption)
            } else {
                Text(count == 0 ? "                     " : "\(count) / 81 cards set")
                    .font(.caption)
            }
        }
    }
    
    struct CardView: View, Identifiable {
        
        var id: Int { card.id }
        
        typealias Card = SetGameVM.Card
        var card: Card
        
        @EnvironmentObject var gameVM: SetGameVM
        var isSelected: Bool { gameVM.selectedCards.contains(card) }
        
        var body: some View {
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)
                ZStack {
                    RoundedRectangle(cornerRadius: 0.2 * size)
                        .foregroundColor(color)
                        .shadow(color: .gray, radius: 0.02 * size)
                    RoundedRectangle(cornerRadius: 0.2 * size)
                        .strokeBorder(
                            shading,
                            lineWidth: 0.1 * size,
                            antialiased: true
                        )
                        .opacity(card.shading == .gray ? 0.5 : 1.0)
                    VStack {
                        ForEach(0 ..< card.number.rawValue, id: \.self) { i in
                            Text(content)
                                .font(.system(size: 50))
                                .scaleEffect(size / 200.0)
                                .frame(width: nil, height: 0.25 * size, alignment: .center)
                        }
                    }
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.system(size: size / 4))
                            .offset(
                                x: geometry.size.width / 2,
                                y: geometry.size.height / 2
                            )
                            .offset(
                                x: -0.1 * size,
                                y: -0.1 * size
                            )
                    }
                }
                .scaleEffect(isSelected ? 0.8 : 1.0)
                .padding(0.07 * size)
            }
        }
        
        var number: Int {
            card.number.rawValue
        }
        var content: String {
            card.content.rawValue
        }
        var color: Color {
            switch card.color {
            case .red: return .red
            case .yellow: return .yellow
            case .blue: return .blue
            }
        }
        var shading: Color {
            switch card.shading {
            case .black: return .black
            case .gray: return .secondary
            case .white: return .white
            }
        }
    }
}

struct SetGameView_Previews: PreviewProvider {
    static var gameVM = SetGameVM()  // FIXME: I can't use `@StateObject`!
    
    static var initialized = false
    
    static func `init`() -> Bool {
        guard !initialized else { return false }
        defer { initialized = true }
        gameVM.drawCard(count: 12)
        gameVM.select(card: gameVM.field.first!)
        return true
    }
    
    static var previews: some View {
        let _ = `init`()
        SetGameView()
            .environmentObject(gameVM)
            .previewDevice(.init(rawValue: "iPhone 13"))
            .preferredColorScheme(.light)
            .previewInterfaceOrientation(.portrait)
        SetGameView()
            .environmentObject(gameVM)
            .previewDevice(.init(rawValue: "iPhone 6s"))
            .preferredColorScheme(.dark)
            .previewInterfaceOrientation(.landscapeRight)
    }
}
