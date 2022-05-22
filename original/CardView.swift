//
//  CardView.swift
//  
//
//  Created by Z. D. Yu on 22.M.22.
//

import SwiftUI

/// 单张卡片的View
struct CardView: View, Identifiable {
    /// `Identifiable`协议要求
    /// 卡片的View与卡片的ID
    var id: Int { card.id }
    
    typealias Card = SetGameVM.Card
    var card: Card
    
    static let DEFAULT_ASPECT_RATIO: CGFloat = 3 / 4
    /// 卡片的宽高比
    let aspectRatio: CGFloat = DEFAULT_ASPECT_RATIO
    
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
            .aspectRatio(self.aspectRatio, contentMode: .fit)
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


struct CardView_Previews: PreviewProvider {
    static let gameVM = SetGameVM()
    
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
    
    static var cards = SetGame.Set.random!.cards
    
    static var previews: some View {
        let _ = `init` {
            cards = SetGame.Set.random(deckID: gameVM.id).cards
        }
        return ForEach(cards) { card in
            CardView(card: card)
                .environmentObject(gameVM)
                .frame(width: 150, height: 200, alignment: .center)
                .previewLayout(.sizeThatFits)
        }
    }
}
