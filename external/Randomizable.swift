//
//  File.swift
//  
//
//  Created by Z. D. Yu on 22.M.22.
//

/// Ability to give some random things
protocol Randomizable {
    /// Give some random things
    static var random: Self? { get }
}

extension Randomizable where Self: CaseIterable {
    /// Give some random things chosen from all cases
    static var random: Self? {
        Self.allCases.randomElement()
    }
}
