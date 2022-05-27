//
//  TutorialView.swift
//  
//
//  Created by Z. D. Yu on 22.M.23.
//

import SwiftUI

/// 如何游玩界面的View
///
/// 需要使用`.environmentObject(_)`从自己或父视图进行依赖注入`SetGameVM`类型对象，否则会在运行时crash
struct TutorialView: View {
    
    static let title = "如何游玩Set纸牌游戏"
    /// 游戏的状态
    ///
    /// 用于非标准的返回键
    @Binding var gameState: GameState
    
    @EnvironmentObject var gameVM: SetGameVM
    
    /// 系统的环境变量：是否为暗黑模式
    ///
    /// 显示logo时用到
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            List {
                Section("Set纸牌游戏的规则") {
                    NavigationLink(CardIntroView.title) {
                        CardIntroView()
                            .navigationTitle(CardIntroView.title)
                    }
                    NavigationLink(StepsView.title) {
                        StepsView()
                            .navigationTitle(StepsView.title)
                    }
                    NavigationLink(TestSetView.title) {
                        TestSetView()
                            .navigationTitle(TestSetView.title)
                    }
                    NavigationLink(HintUsageView.title) {
                        HintUsageView()
                            .navigationTitle(HintUsageView.title)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
                Section("进一步了解") {
                    Link(destination: .init(
                        string: "https://en.wikipedia.org/wiki/Set_(card_game)"
                            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    )!) {
                        let view = HStack {
                            Image("wikipedia-wordmark-en")
                                .accessibilityLabel("WikiPedia")
                        }
                        if colorScheme == .dark {
                            HStack {
                                view.colorInvert()
                                Text("...")
                            }
                        } else {
                            HStack {
                                view
                                Text("...")
                            }
                        }

                    }
                    
                    Link(destination: .init(
                        string: "https://baike.baidu.com/item/SET纸牌/8059167"
                            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    )!) {
                        Text("百度百科...")
                            .foregroundColor(.secondary)
                            .font(.caption2)
                            .opacity(0.5)
                    }
                }
                Section("关于本App") {
                    NavigationLink {
                        LicenseView()
                            .navigationTitle(LicenseView.title)
                    } label: {
                        Label {
                            Text("使用许可")
                        } icon: {
                            let view = Image("wtfpl")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32, alignment: .center)
                            switch colorScheme {
                            case .dark:
                                view.colorInvert()
                            default:
                                view
                            }
                        }
                    }
                    
                    Link(destination: .init(
                        string: "https://github.com/Loovemaker/Set-Card-Game.swiftpm"
                            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    )!) {
                        Label {
                            Text("项目源码...")
                        } icon: {
                            let view = Image("pinned-octocat")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32, alignment: .center)
                            switch colorScheme {
                            case .dark:
                                view.colorInvert()
                            default:
                                view
                            }
                        }
                    }
                }
                Section("准备好了吗？") {
                    Button {
                        gameState = .inGame
                    } label: {
                        Label("准备好了，开始游戏！", systemImage: "checkmark.circle")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .navigationTitle(Self.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        gameState = .intro
                    } label: {
                        HStack(spacing: 0) {
                            Image(systemName: "chevron.left")
                            Text("返回")
                        }
                    }
                }
            }
            // NaviagationView中第一个以外的View，为iPad/Mac上的默认展示View
            NavigationDefaultView()
        }
    }
    
    /// View：Set是个纸牌游戏？牌长啥样？
    ///
    /// 需要使用`.environmentObject(_)`从自己或父视图进行依赖注入`SetGameVM`类型对象，否则会在运行时crash
    struct CardIntroView: View, HasTitleAndText {
        static let title = "Set是个纸牌游戏？牌长啥样？"
        
        static let text = try! AttributedString.init(markdown: """
            如图，每张卡具有4个特征，每个特征具有3种值。每种特征都可以从外观辨认出来，它们在本App中分别为：
            
            1.  卡面的颜色：红色、黄色、蓝色
            2.  边框：白边框、半透明边框、黑边框
            3.  字符内容：\(SetGame.Card.Content.allCases[0].rawValue)、\(SetGame.Card.Content.allCases[1].rawValue)、\(SetGame.Card.Content.allCases[2].rawValue)
            4.  字符数量：1个、2个、3个
            
            所有特征值进行排列，所对应的81张卡可组成一副卡组，
            
            因此，在一副卡组中，你不会遇到两张卡外观完全相同的情况。
        """)
        
        @State private var card: SetGame.Card = .random
        var cardView: some View {
            CardView(card: card)
                .aspectRatio(CardView.DEFAULT_ASPECT_RATIO, contentMode: .fit)
        }
        
        @EnvironmentObject var gameVM: SetGameVM
        
        let cdSystem = SimpleCDSystem(interval: 4)
        
        
        var body: some View {
            AdaptiveStack { _, _ in
                AdaptiveStack { _, _ in
                    cardView
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                card = .random
                            }
                            cdSystem.activate()
                        }
                        .frame(minWidth: 60, idealWidth: nil, maxWidth: nil,
                               minHeight: 80, idealHeight: nil, maxHeight: nil,
                               alignment: .center)
                    Divider()
                    VStack(alignment: .leading, spacing: 20) {
                        Text("特征：")
                            .font(.title.bold())
                        HStack {
                            Text("红色")
                                .foregroundColor(.red)
                                .shadow(radius: 1)
                                .highlight(condition: card.color == .red)
                            Text("黄色")
                                .foregroundColor(.yellow)
                                .shadow(radius: 1)
                                .highlight(condition: card.color == .yellow)
                            Text("蓝色")
                                .foregroundColor(.blue)
                                .shadow(radius: 1)
                                .highlight(condition: card.color == .blue)
                        }
                        HStack {
                            Text("黑边框")
                                .border(Color.black, width: 1)
                                .highlight(condition: card.shading == .black)
                            Text("半透明边框")
                                .border(Color.secondary, width: 1)
                                .highlight(condition: card.shading == .gray)
                            Text("白边框")
                                .border(Color.white, width: 1)
                                .highlight(condition: card.shading == .white)
                        }
                        HStack {
                            ForEach(SetGame.Card.Content.allCases, id: \.hashValue) {
                                content in
                                Text(content.rawValue)
                                    .highlight(condition: card.content == content)
                            }
                        }
                        HStack {
                            ForEach(SetGame.Card.Number.allCases, id: \.hashValue) {
                                number in
                                Text("\(number.rawValue)个字符")
                                    .highlight(condition: card.number == number)
                            }
                        }
                    }
                    .frame(minWidth: 225, idealWidth: nil, maxWidth: nil,
                           minHeight: 225, idealHeight: nil, maxHeight: nil,
                           alignment: .center)
                }
                .onAppear {
                    startRefreshingCard()
                }
                ScrollView {
                    Text(Self.text).text
                }
                .frame(minWidth: 150, idealWidth: 225, maxWidth: 600,
                       minHeight: 100, idealHeight: nil, maxHeight: nil,
                       alignment: .top)
            }
            .padding()
        }
        
        /// 启动卡片每4秒刷新一次的功能
        private func startRefreshingCard() {
            Task {
                while true {
                    await cdSystem.waitUntilReady()
                    guard cdSystem.activate() else { continue }
                    withAnimation(.easeInOut) {
                        card = .random
                    }
                }
            }
        }
    }
    
    /// View：如何开始游戏？然后如何操作？
    struct StepsView: View, HasTitleAndText {
        static let title = "如何开始游戏？然后如何操作？"
        
        static let text = try! AttributedString.init(markdown: """
            1.  从主页面开始游戏；
            2.  找到卡组，轻点以发牌；
            3.  在场上找出符合以下条件的3张牌，称为一组Set：
                对于4个特征任意一个，满足以下其中一个条件：
                -   3张卡片的该特征值完全相等
                -   3张卡片任意取2张卡片，其特征值均不相等
            4.  Set成功的卡片会被收集起来并不再使用，此时可能会因为场上的卡片数量太少而无法找到Set，轻点卡组发牌即可；
            5.  当卡组的牌已发完，且场上没有Set时，游戏完成。
        """)
        
        var body: some View {
            ScrollView {
                Text(Self.text).text
            }
            .padding()
        }
    }
    
    /// View：怎样的三张卡片可以构成Set？
    ///
    /// 需要使用`.environmentObject(_)`从自己或父视图进行依赖注入`SetGameVM`类型对象，否则会在运行时crash
    struct TestSetView: View {
        static let title = "怎样的三张卡片可以构成Set？"
        
        @EnvironmentObject var gameVM: SetGameVM
        /// 是否显示答案
        @State private var answerShown = true
        
        typealias Card = SetGame.Card
        @State private var cards = getRandomCards(ensureSetProbability: 1/6)
        
        /// 得到随机的3张卡片
        ///
        /// 由于随机的3张卡片正好可以组成Set的概率较低，需要人为控制概率。
        /// - Parameters:
        ///   - ensureSetProbability: 有多少概率确保3张卡片可以组成Set
        ///   - deckID: 卡组的ID值
        /// - Returns: 一组3张卡片
        static func getRandomCards(ensureSetProbability: Double,
                                   deckID: UUID? = nil) -> [Card] {
            let normRange = 0.0 ... 1.0
            let ensureSet = Double.random(in: normRange) <
                Clamped.to(value: ensureSetProbability, range: normRange)
            return ensureSet ?
                SetGame.Set.random(deckID: deckID).cards :
                (0 ..< 3).map { _ in Card.random(deckID: deckID) }
        }
        
        var body: some View {
            List {
                VStack {
                    HStack {
                        ForEach(cards) { card in
                            CardView(card: card)
                                .aspectRatio(CardView.DEFAULT_ASPECT_RATIO, contentMode: .fit)
                        }
                    }
                    .frame(minWidth: nil, idealWidth: nil, maxWidth: nil,
                           minHeight: nil, idealHeight: nil, maxHeight: 240,
                           alignment: .center)
                    Group {
                        if answerShown {
                            Label("轻点这里换一组卡片", systemImage: "arrow.triangle.2.circlepath")
                        } else {
                            Label("轻点这里显示答案", systemImage: "lightbulb")
                        }
                    }
                    .foregroundColor(.accentColor)
                }
                .padding(.vertical)
                .onTapGesture {
                    if answerShown {
                        cards = Self.getRandomCards(ensureSetProbability: 1/6)
                    }
                    withAnimation(.spring()) {
                        answerShown.toggle()
                    }
                }
                
                if answerShown {
                    let featureNameOrder = ["颜色", "边框", "字符内容", "字符数量"]
                    let featureEquals = SetGame.Set.ofFeatures(cards[0], cards[1], cards[2])
                    let featureEqualsValuesWithNameOrder = [
                        featureEquals.color,
                        featureEquals.shading,
                        featureEquals.content,
                        featureEquals.number
                    ]
                    Group {
                        Section("单个特征判断") {
                            ForEach(featureNameOrder, id: \.hashValue) { name in
                                let value = featureEqualsValuesWithNameOrder[
                                    featureNameOrder.firstIndex(of: name)!
                                ]
                                label(when: value,
                                      titleWhenTrue: "三张卡片的 \(name) \n完全相等或完全不相等",
                                      titleWhenFalse: "三张卡片的其中一个 \(name) \n与另外两张不相等")
                            }
                        }
                        Section("结论") {
                            label(when: SetGame.Set(cards[0], cards[1], cards[2]) != nil,
                                  titleWhenTrue: "所有特征均满足条件\n可以组成Set",
                                  titleWhenFalse: "有特征未满足条件\n无法组成Set")
                        }
                    }
                }
            }
        }
    }
    
    /// View：我尝试着选中一组牌，可它们始终无法Set！怎么办？
    struct HintUsageView: View, HasTitleAndText {
        static let title = "我尝试着选中一组牌，可它们始终无法Set！怎么办？"
        
        static let text = try! AttributedString.init(markdown: """
            如果你在遵守游戏规则的情况下，
            选中的三张牌始终无法组成Set，
            你需要停下来**仔细地检查**每一个特征是否满足条件！
            
            此外，你还可以在游戏中使用提示功能。
            使用提示功能后，将会有两张卡片被自动选中。
            根据Set卡牌游戏的性质，选中两张卡片后，
            一定能找到唯一的第三张卡片，并组成Set。
            使用提示功能并Set后，请发牌并仔细地寻找下一组Set，
            或者等待提示功能冷却...
            
            如果你确定App出现问题，可以找我反馈~
        """)
        var body: some View {
            ScrollView {
                Text(Self.text)
                    .text
                    .padding()
            }
        }
    }
    
    /// View：使用许可
    struct LicenseView: View, HasTitleAndText {
        static let title = "使用许可"
        
        static let text = try! AttributedString.init(markdown: """
            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
            Version 2, December 2004

            Copyright (C) 2022 Loovemaker <bows-02.roper@icloud.com>

            Everyone is permitted to copy and distribute verbatim or modified copies of this license document, and changing it is allowed as long as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
            TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

             0. You just DO WHAT THE FUCK YOU WANT TO.
        """)
        
        var body: some View {
            ScrollView {
                Text(Self.text)
                .padding()
                .font(.system(size: 18, weight: .regular, design: .monospaced))
            }
        }
    }
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView(gameState: .constant(.tutorial))
            .environmentObject(SetGameVM())
        TutorialView.CardIntroView()
            .environmentObject(SetGameVM())
            .previewDevice(.init(rawValue: "iPhone 11"))
            .previewDisplayName(TutorialView.CardIntroView.title)
        TutorialView.CardIntroView()
            .environmentObject(SetGameVM())
            .previewDevice(.init(rawValue: "Mac Catalyst"))
            .previewDisplayName(TutorialView.CardIntroView.title)
            .preferredColorScheme(.dark)
            .previewInterfaceOrientation(.landscapeLeft)
        TutorialView.StepsView()
            .previewDevice(.init(rawValue: "iPhone 11"))
            .previewDisplayName(TutorialView.StepsView.title)
        TutorialView.StepsView()
            .previewDevice(.init(rawValue: "Mac Catalyst"))
            .previewDisplayName(TutorialView.StepsView.title)
            .preferredColorScheme(.dark)
            .previewInterfaceOrientation(.landscapeLeft)
        TutorialView.TestSetView()
            .environmentObject(SetGameVM())
            .previewDevice(.init(rawValue: "iPhone 11"))
            .previewDisplayName(TutorialView.TestSetView.title)
            .previewInterfaceOrientation(.landscapeLeft)
        TutorialView.TestSetView()
            .environmentObject(SetGameVM())
            .previewDevice(.init(rawValue: "Mac Catalyst"))
            .previewDisplayName(TutorialView.TestSetView.title)
            .preferredColorScheme(.dark)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

// MARK: 以下是本文件内部的扩展功能

fileprivate extension View {
    /// 用于``TutorialView.CardIntroView``的特征值高亮显示功能
    /// - Parameter condition: 是否高亮显示的条件，为动态值（`@autoclosure`）
    /// - Returns: 高亮或未高亮的View
    func highlight(condition: @autoclosure () -> Bool) -> some View {
        self
            .scaleEffect(condition() ? 1.75 : 1.0)
            .opacity(condition() ? 1.0 : 0.25)
    }
}
fileprivate extension Text {
    /// 添加正文该有的格式
    var text: some View {
        self
            .monospacedDigit()
            .font(.title2)
            .lineSpacing(10)
    }
}
/// 根据一定的条件显示不同文本，并添加正确（􀁢）或错误（􀒉）标志
///
/// 用于``TutorialView.TestSetView``
/// - Parameters:
///   - condition: 需要满足的条件
///   - titleWhenTrue: 满足条件后显示的文本
///   - titleWhenFalse: 未满足条件后显示的文本
/// - Returns: 对应的View
fileprivate func label<Word>(when condition: Bool,
                             titleWhenTrue: Word,
                             titleWhenFalse: Word) -> some View
where Word: StringProtocol {
    if condition {
        return HStack(alignment: .center) {
            Image(systemName: "checkmark.circle")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
            Text(titleWhenTrue)
        }
    } else {
        return HStack(alignment: .center) {
            Image(systemName: "xmark.octagon")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text(titleWhenFalse)
        }
    }
}

fileprivate extension SetGame.Set {
    
    /// 批量得到一组卡片的各个特征是否满足Set
    /// - Returns: 各个特征是否满足Set的元组
    static func ofFeatures(_ card0: Card, _ card1: Card, _ card2: Card)
    -> (color: Bool, shading: Bool, content: Bool, number: Bool) {
        (
            color: card0.color == Card.Color.theOtherOf(card1.color, card2.color),
            shading: card0.shading == Card.Shading.theOtherOf(card1.shading, card2.shading),
            content: card0.content == Card.Content.theOtherOf(card1.content, card2.content),
            number: card0.number == Card.Number.theOtherOf(card1.number, card2.number)
        )
    }
}

/// 含有标题和正文
fileprivate protocol HasTitleAndText {
    /// 标题
    static var title: String { get }

    /// 正文，Markdown或其它富文本格式
    static var text: RichText { get }
    associatedtype RichText: AttributedStringProtocol
}
