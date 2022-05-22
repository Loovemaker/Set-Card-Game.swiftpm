//
//  SetGameView.swift
//  Set
//
//  Created by Z. D. Yu on 22.F.24.
//

import SwiftUI

/// 游戏场景的View，
/// 需要使用`.environmentObject(_)`进行依赖注入`SetGameVM`类型对象，否则会在运行时crash
struct SetGameView: View {
    
    /// ViewModel，
    /// `EnvironmentObject`具有`ObservedObject`的已被观测的性质
    @EnvironmentObject var gameVM: SetGameVM
    /// ViewModel中`SimpleCDSystem`的提示是否可用功能
    /// 淦！给这个bug逻辑擦屁股
    /// 这个bug逻辑是因为View不支持`ObservedObject`在后台更新给View自己更新而导致的
    @State private var hintReady = false    // FIXME: use pure functionality of `SimpleCDSystem`
    
    @Namespace private var cardGeometryNamespace
    
    /// `View`协议要求，
    /// SwiftUI View的内容
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
    
    /// 提示的View，在正下方
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
    
    /// 场地的View，在上方
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
    
    /// 卡片叠起来的View，适用于卡组和“墓地”
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
    /// 卡组的View，在左下方
    var deckView: some View {
        VStack {
            stackedCardsView(
                of: gameVM.deck,
                transition: .asymmetric(insertion: .scale,
                                        removal: .identity.animation(.spring()))
            )
                .onTapGesture {
                    withAnimation(.spring()) {
                        gameVM.drawCard()
                    }
                }
            let count = gameVM.deck.count
            Text(count == 81 ? "Tap me to start!" : "\(count) remaining")
                .font(.caption)
                .opacity(count == 0 ? 0 : 1)
        }
    }
    /// “墓地”的View，在右下方
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
    
    /// 单张卡片的View
    struct CardView: View, Identifiable {
        /// `Identifiable`协议要求
        /// 卡片的View与卡片的ID
        var id: Int { card.id }
        
        typealias Card = SetGameVM.Card
        var card: Card
        
        /// 用于判断卡片是否被选择
        @EnvironmentObject var gameVM: SetGameVM
        /// 是否被选择
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
        
        // 以下代码将卡片的特征值（Feature）转换成可被SwiftUI使用的值
        
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

/// 视图预览功能（就在你右手边）：游戏场景的View
struct SetGameView_Previews: PreviewProvider {
    static var gameVM = SetGameVM()  // FIXME: Not allowed to use `@StateObject` or the preview will IMMEDIATELY CRASH!
    
    static var initialized = false
    
    /// Swift Playground会多次获取`previews`值（我看见的是两个视图预览用个4次），
    /// 因此我不得不这么写。
    static func `init`() -> Bool {
        guard !initialized else { return false }
        defer { initialized = true }
        gameVM.drawCard()
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
