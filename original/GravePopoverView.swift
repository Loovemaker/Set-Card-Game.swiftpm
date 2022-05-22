//
//  GravePopoverView.swift
//  
//
//  Created by Z. D. Yu on 22.M.22.
//

import SwiftUI

/// 需要使用`.environmentObject(_)`从自己或父视图依赖注入`SetGameVM`类型对象，否则会在运行时crash
struct GravePopoverView: View {
    /// ViewModel，
    /// `EnvironmentObject`具有`ObservedObject`的已被观测的性质
    @EnvironmentObject var gameVM: SetGameVM
    
//    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            ForEach(gameVM.grave, id: \.hashValue) { `set` in
                HStack {
                    ForEach(`set`.cards) { card in
                        CardView(card: card)
                            .environmentObject(gameVM)
                    }
                    .aspectRatio(CardView.DEFAULT_ASPECT_RATIO, contentMode: .fit)
                }
            }
        }
        .frame(minWidth: 375, idealWidth: 414, maxWidth: 428,
               minHeight: 667, idealHeight: 896, maxHeight: 926,
               alignment: .center)
        .padding()
    }
}

struct GravePopoverView_Previews: PreviewProvider {
    static var gameVM = SetGameVM()  // FIXME: Not allowed to use `@StateObject` or the preview will IMMEDIATELY CRASH!

    /// Swift Playground会多次获取`previews`值（我看见的是两个视图预览用个4次），
    /// 因此我不得不这么写。
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
            for _ in 0 ..< 3 {
                gameVM.drawCard()
                for index in gameVM.firstPossibleIndices! {
                    gameVM.select(card: gameVM.field[index])
                }
            }
        }
        GravePopoverView()
            .environmentObject(gameVM)
            .previewLayout(.sizeThatFits)
    }
}
