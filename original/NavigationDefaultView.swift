//
//  NavigationDefaultView.swift
//  
//
//  Created by Z. D. Yu on 22.M.24.
//

import SwiftUI

/// 边栏未选中主题时的View
///
/// 这个View会在iPad和Mac上出现
struct NavigationDefaultView: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width,
                height = geometry.size.height
            let size = min(width, height)
            VStack(spacing: size / 20) {
                AppIconView(size: size / 4)
                Label("从导航边栏寻找主题", systemImage: "arrow.left")
                    .foregroundColor(.secondary)
                    .font(.system(size: size / 25))
            }
            .frame(width: width, height: height, alignment: .center)
        }
    }
}

struct NavigationDefaultView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationDefaultView()
            .previewLayout(.fixed(width: 800, height: 600))
    }
}
