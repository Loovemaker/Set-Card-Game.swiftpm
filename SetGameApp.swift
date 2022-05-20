//
//  SetGameApp.swift
//  Set
//
//  Created by Z. D. Yu on 22.F.24.
//

import SwiftUI

@main
struct SetGameApp: App {
    
    @StateObject private var gameVM = SetGameVM()

    var body: some Scene {
        WindowGroup {
            SetGameView()
                .environmentObject(gameVM)
        }
    }
}
