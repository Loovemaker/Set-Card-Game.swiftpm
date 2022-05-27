//
//  SwiftUIView.swift
//  
//
//  Created by Z. D. Yu on 22.M.24.
//

import SwiftUI

/// App图标的视图
///
/// 形状为圆角正方形，并添加了阴影。
/// 需要手动输入大小。
struct AppIconView: View {
    @State var size: CGFloat
    
    var body: some View {
        Image("Set Game")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(size / 6)
            .shadow(color: .secondary, radius: size / 50, x: 0, y: size / 100)
            .frame(width: size, height: size, alignment: .center)
            .accessibilityLabel("App图标")
    }
}

struct AppIconView_Previews: PreviewProvider {
    static var previews: some View {
        let view = AppIconView(size: 200)
            .padding()
            .previewLayout(.sizeThatFits)
        view
            .previewDisplayName("Light mode")
            .preferredColorScheme(.light)
        view
            .previewDisplayName("Dark mode")
            .preferredColorScheme(.dark)
    }
}
