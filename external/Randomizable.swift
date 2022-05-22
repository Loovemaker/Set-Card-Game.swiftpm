//
//  File.swift
//  
//
//  Created by Z. D. Yu on 22.M.22.
//

protocol Randomizable {
    static var random: Self? { get }
}

extension Randomizable where Self: CaseIterable {
    static var random: Self? {
        Self.allCases.randomElement()
    }
}
