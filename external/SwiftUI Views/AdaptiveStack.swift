//
//  AdaptiveStack.swift
//  
//
//  Created by Z. D. Yu on 22.M.23.
//

import SwiftUI

/// Choose ``Hstack`` or ``VStack`` according to the aspect ratio of the given geometry space.
struct AdaptiveStack<Content>: View where Content: View {

    @State var idealAspectRatio = 1.0
    /// The alignment when stacked horizonally
    @State var vAlignment: VerticalAlignment = .center
    /// The alignment when stacked vertically
    @State var hAlignment: HorizontalAlignment = .center
    /// The distance between adjacent subviews,
    /// or nil if you want the stack to choose a default distance for each pair of subviews.
    @State var spacing: CGFloat? = nil
    
    /// The orientation used in ``AdaptiveStack.content``
    enum Orientation { case horizontal, vertical }
    /// The view builder passed as the trailing closure of `init`
    /// - Parameters:
    ///   - orientation: the orientation chosen by ``AdaptiveStack``
    ///   - geometry: the geometry proxy passed by ``GeometryReader``
    @ViewBuilder let content: (Orientation, GeometryProxy) -> Content
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width,
                height = geometry.size.height
            let aspectRatio = width / height
            if aspectRatio >= idealAspectRatio {
                HStack(alignment: vAlignment, spacing: spacing) {
                    content(.horizontal, geometry)
                }
                .frame(width: width,
                       height: height,
                       alignment: .center)
            } else {
                VStack(alignment: hAlignment, spacing: spacing) {
                    content(.vertical, geometry)
                }
                .frame(width: width,
                       height: height,
                       alignment: .center)
            }
        }
    }
}
