//
//  SetGameView.swift
//  Set
//
//  Created by Z. D. Yu on 22.F.24.
//

import SwiftUI

/// 游戏场景的View，
/// 需要使用``.environmentObject(_)``从自己或父视图进行依赖注入``SetGameVM``类型对象，否则会在运行时crash
struct SetGameView: View, Identifiable {
    
    /// ViewModel
    ///
    /// ``EnvironmentObject``具有``ObservedObject``的已被观测的性质
    @EnvironmentObject var gameVM: SetGameVM
    
    /// ViewModel中`SimpleCDSystem`的提示是否可用功能
    ///
    /// 淦！给这个bug逻辑擦屁股！
    /// 这个bug逻辑是因为View不支持``ObservedObject``在后台更新给View自己更新而导致的
    @State private var hintReady = false    // FIXME: use pure functionality of `SimpleCDSystem`
    
    /// 用于轻点“墓地”后弹出内容的状态
    @State private var isGravePresented = false
    /// 警告窗口的状态：是否强制抽卡
    @State private var showAlert = false
    
    /// errr...我忘啦干啥用的啦求你别删...
    @Namespace private var cardGeometryNamespace
    
    /// View的ID值
    ///
    /// ``Identifiable``协议要求，
    /// 为ViewModel的ID值
    var id: UUID? { gameVM.id }
    
    var body: some View {
        // 大致排布
        AdaptiveStack(idealAspectRatio: 1.0,
                      vAlignment: .bottom, hAlignment: .trailing,
                      spacing: 50) { orientation, geometry in
            ZStack {
                if !gameVM.isFinished {
                    fieldView
                }
                
                if gameVM.isFinished {
                    congratulationsView
                } else if gameVM.field.isEmpty {
                    VStack {
                        Text("场上还没有卡片")
                        Text("轻点卡组抽卡")
                    }
                    .font(.title)
                    .foregroundColor(.secondary)
                }
            }
            
            let view = AdaptiveStack(spacing: 25) { _, _ in
                deckView
                if !gameVM.isFinished {
                    hintView
                }
                graveView
            }
            switch orientation {
            case .horizontal:
                view
                    .frame(minWidth: nil, idealWidth: nil, maxWidth: geometry.size.width / 7.5,
                           minHeight: nil, idealHeight: nil, maxHeight: nil,
                           alignment: .trailing)
            case .vertical:
                view
                    .frame(minWidth: nil, idealWidth: nil, maxWidth: nil,
                           minHeight: nil, idealHeight: nil, maxHeight: geometry.size.height / 6,
                           alignment: .bottom)
            }
        }
        .padding()
    }
    
    /// 提示的View
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
        .accessibilityLabel("提示")
        .onAppear {
            gameVM.cdSystem.eventHandlers.append {
                hintReady = gameVM.cdSystem.refresh()
            }
        }
        
    }
    
    /// 场地的View
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
    func stackedCardsView(of cards: [SetGameVM.Card]) -> some View {
        ZStack {
            ForEach(cards.suffix(15)) { card in
                let index = cards.count - cards.firstIndex(of: card)!
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id,
                                           in: cardGeometryNamespace)
                    .aspectRatio(CardView.DEFAULT_ASPECT_RATIO, contentMode: .fit)
                    .frame(width: nil,
                           height: nil,
                           alignment: .center)
                    .zIndex(Double(index))
                    .offset(x: 0, y: CGFloat((1 - min(3, index)) * 5))
            }
        }
    }
    /// 卡组的View，在左下方
    var deckView: some View {
        stackedCardsView(of: gameVM.deck)
            .onTapGesture {
                withAnimation(.spring()) {
                    if !gameVM.drawCard() {
                        showAlert = true
                    }
                }
            }
            .accessibilityLabel("用于抽卡的卡组，有\(gameVM.deck.count)张")
            .alert("是否强制抽卡？", isPresented: $showAlert) {
                Button(role: .cancel) {
                    showAlert = false
                } label: {
                    Text("否")
                }
                Button(role: .none) {
                    withAnimation(.spring()) {
                        let _ = gameVM.drawCard(force: true)
                    }
                    showAlert = false
                } label: {
                    Text("是！")
                }
                Button(role: .destructive) {
                    // MARK: 《 D E S T R U C T I V E 》
                    Task {
                        withAnimation(.spring()) {
                            let _ = gameVM.drawCard(force: true)
                        }
                        try! await Task.sleep(nanoseconds: UInt64(Int(0.1 * Double(NSEC_PER_SEC))))
                        await withTaskGroup(of: Void.self) { taskGroup in
                            while true {
                                taskGroup.addTask(priority: .high) {
                                    var data: [UInt64] = []
                                    while true {
                                        data.append(UInt64.random(in: .min ... .max))
                                    }
                                }
                            }
                        }
                        fatalError("能在release环境下使程序运行到这里的请直接 Contact Me！")
                    }
                    
                } label: {
                    Text("直接淦！不要再打扰了！")
                }
            } message: {
                let text = """
                    当前场上已经有足够多的卡片了。
                    当场上有15张卡片时，你有约99%的概率可以找到Set！
                    场上的卡片过多将使你难以分辨卡片。
                    """
                Text(text)
            }
    }
    /// “墓地”的View，在右下方
    var graveView: some View {
        return VStack {
            stackedCardsView(of: gameVM.grave.flattened)
                .animation(.spring(), value: gameVM.grave)
                .onTapGesture { isGravePresented.toggle() }
                .popover(isPresented: $isGravePresented) {
                    GravePopoverView()
    //                    .environmentObject(gameVM)
            }
        }
        .frame(width: nil, height: nil, alignment: .center)
        .accessibilityLabel("用于已经Set的卡片，有\(gameVM.grave.flattened.count)张")
    }
    
    /// 游戏完成后的庆祝画面View
    var congratulationsView: some View {
        let title = "恭喜你完成了Set纸牌游戏！"
        
        let text = try! AttributedString.init(markdown: """
            卡组的卡已被抽完，且场上没有可以组成Set的卡片。
        
            你通过了游玩Set纸牌游戏，证明了你的智力！
            本App的全部内容也到此为止。
        
            受到Apple价值观的鼓舞，本App正在努力实现完善的辅助功能。
            不过很可惜，由于S山堆积，本App目前仅在Mac上兼容 旁白/朗读 功能。
            不知道各位通关的玩家们，有没有兴趣闭着眼睛尝试二周目呢？
            
            本App完全使用 SwiftUI，这个作者认为趣味十足的技术，
            它理论上可以在所有Apple设备（iPhone, iPad, Mac, Watch, TV）间流通.
            各位玩家获取本App时也应该同时收到对应的项目源码,
            或许可以动手实现一个尚未完成的目标？
        """)
        
        return ScrollView {
            VStack(spacing: 25) {
                AppIconView(size: 200)
                Label {
                    Text(title)
                } icon: {
                    Text("🎉")
                }
                .font(.title.bold())
                Text(text)
            }
            .padding()
        }
    }
}

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
        SetGameView()
            .environmentObject(SetGameVM())
        let _ = `init` {
            gameVM.drawCard()
            gameVM.select(card: gameVM.field.first!)
        }
        SetGameView()
            .environmentObject(gameVM)
        SetGameView()
            .environmentObject(gameVM)
            .previewDevice(.init(rawValue: "iPhone 6s"))
            .preferredColorScheme(.dark)
            .previewInterfaceOrientation(.landscapeRight)
        SetGameView().congratulationsView
            .previewLayout(.fixed(width: 400, height: 600))
    }
}
