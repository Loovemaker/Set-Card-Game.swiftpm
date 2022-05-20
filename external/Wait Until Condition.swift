//
//  Wait Until Condition.swift
//  Set
//
//  Created by Z. D. Yu on 22.M.1.
//

import Foundation

/// Wait until some condition comes true **in background**
/// - Parameters:
///   - t: Poll interval in seconds
public func wait(
    pollInterval t: TimeInterval,
    until condition: () -> Bool
) async {
    while !(condition()) {
        let nsec = max(0, UInt64(Double(NSEC_PER_SEC) * t))
        try? await Task.sleep(nanoseconds: nsec)
    }
}

/// Wait until some condition comes true **in the main thread**
/// - Parameters:
///   - t: Poll interval in seconds
public func wait(
    pollInterval t: TimeInterval,
    until condition: () -> Bool
) {
    while !(condition()) {
        Thread.sleep(forTimeInterval: max(0, t))
    }
}
