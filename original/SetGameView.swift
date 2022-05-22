//
//  SetGameView.swift
//  Set
//
//  Created by Z. D. Yu on 22.F.24.
//

import SwiftUI

/// 游戏场景的View，
/// 需要使用`.environmentObject(_)`从自己或父视图进行依赖注入`SetGameVM`类型对象，否则会在运行时crash
struct SetGameView: View, Identifiable {
    
    /// ViewModel，
    /// `EnvironmentObject`具有`ObservedObject`的已被观测的性质
    @EnvironmentObject var gameVM: SetGameVM
    /// ViewModel中`SimpleCDSystem`的提示是否可用功能
    /// 淦！给这个bug逻辑擦屁股
    /// 这个bug逻辑是因为View不支持`ObservedObject`在后台更新给View自己更新而导致的
    @State private var hintReady = false    // FIXME: use pure functionality of `SimpleCDSystem`
    
    @State private var isGravePresented = false
    
    @Namespace private var cardGeometryNamespace
    
    var id: UUID? { gameVM.id }
    
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
                Text("提示")
                    .font(.caption)
                    .opacity(hintReady ? 1 : 0)
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
            aspectRatio: CardView.DEFAULT_ASPECT_RATIO
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
    ///
    /// 为了保持排版，没有卡片时将使用空的View
    func stackedCardsView(of cards: [SetGameVM.Card],
                          width: CGFloat,
                          transition: AnyTransition) -> some View {
        ZStack {
            ForEach(cards) { card in
                let index = cards.firstIndex(of: card) ?? 0
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in:
                                            cardGeometryNamespace)
                    .transition(transition)
                    .frame(width: width,
                           height: width / CardView.DEFAULT_ASPECT_RATIO,
                           alignment: .center)
                    .zIndex(Double(index))
                    .offset(x: 0, y: CGFloat(1-min(2, index) * 5))
            }
            EmptyView()
        }
        .frame(width: width, height: nil, alignment: .center)
    }
    /// 卡组的View，在左下方
    var deckView: some View {
        let width: CGFloat = 90
        return VStack {
            stackedCardsView(
                of: gameVM.deck,
                width: width,
                transition: .asymmetric(insertion: .scale,
                                        removal: .identity.animation(.spring()))
            )
                .onTapGesture {
                    withAnimation(.spring()) {
                        gameVM.drawCard()
                    }
                }
            let count = gameVM.deck.count
            if count > 0 {
                ProgressView(value: Double(count) / (81 - 9))
            }
        }
        .frame(width: width, height: nil, alignment: .center)
    }
    /// “墓地”的View，在右下方
    var graveView: some View {
        let width: CGFloat = 90
        return VStack {
            stackedCardsView(
                of: gameVM.grave.flattened,
                width: width,
                transition: .asymmetric(insertion: .identity.animation(.spring()),
                                        removal: .opacity)
            )
            .animation(.spring(), value: gameVM.grave)
            .onTapGesture { isGravePresented.toggle() }
            .popover(isPresented: $isGravePresented) {
                GravePopoverView()
            }
            
            let count = gameVM.grave.count * SetGame.Set.CARDS_COUNT
            if count > 0 {
                ProgressView(value: Double(count) / (81 - 9))
            }
        }
        .frame(width: width, height: nil, alignment: .center)
    }
}

/// 视图预览功能（就在你右手边）：游戏场景的View
struct SetGameView_Previews: PreviewProvider {
    static var gameVM = SetGameVM()
    
    /// Swift Playground会多次获取`previews`值（我看见的是两个视图预览用个4次），
    /// 因此我不得不这么写。
    /// - Parameter closure: 要执行的内容
    /// - Returns: 此次是否执行成功（是否为唯一一次执行）
    @discardableResult
    static func `init`(_ closure: () throws -> Void) rethrows -> Bool {
        guard !initialized else { return false }
        defer { initialized = true }
        try closure()
        return true
    }
    static var initialized = false
    
    static var previews: some View {
        let _ = `init` {
            gameVM.drawCard()
            gameVM.select(card: gameVM.field.first!)
        }
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
