//
//  CDSystem.swift
//
//
//  Created by Z. D. Yu on 22.M.20.
//

import Foundation

fileprivate let MAX_REFRESH_RATE: Double = 100

/// How a cooldown system should behave
protocol CDSystemProtocol {
    /// readiness to activate
    var ready: Bool { get }
    
    /// Activate and cool down again
    /// - Returns: if the activation is success
    func activate() -> Bool
}

/// A really really simple cooldown system
///
/// use ``Foundation.DispatchSourceTimer`` to poll and update the state of readiness
///
/// No functionality of pausing, meaning that the only clock is the clock in the real world.
class SimpleCDSystem: CDSystemProtocol, ObservableObject {
    
    @Published var ready = true
    /// The next time point when ready
    ///
    /// Being left behind now means the readiness
    private(set) var nextReadyDate: Date = .distantPast
    
    /// The time left to be ready
    ///
    /// Not being greater than zero means the readiness
    var timeLeft: TimeInterval { nextReadyDate.timeIntervalSince(.now) }
    
    /// Manually update the readiness
    /// - Returns: the readiness
    @discardableResult
    func refresh() -> Bool {
        ready = (timeLeft <= 0)
        return ready
    }
    
    /// The clock object
    private let clock: DispatchSourceTimer
    /// A List of **customizable** closures to handle the clock event
    var eventHandlers: [DispatchSourceTimer.DispatchSourceHandler] = []
    
    @Clamped(to: 0 ... .infinity, isConstant: true) var interval: Double!
    @Clamped(to: 0 ... MAX_REFRESH_RATE, isConstant: true) var refreshRate: Double!
    
    @discardableResult
    func activate() -> Bool {
        guard ready else { return false }
        nextReadyDate = .now.addingTimeInterval(interval)
        refresh()
        return true
    }
    func waitUntilReady() async {
        await waitUntilReady(refreshRate: self.refreshRate)
    }
    
    /// - Parameters:
    ///   - interval: The cooldown time for each activation
    ///   - refreshRate: poll every 1/refreshRate second
    init(interval: Double, refreshRate: Double = 50) {
        
        self.clock = DispatchSource.makeTimerSource(
            queue: DispatchQueue.global(qos: .userInteractive)
        )
        
        self.interval = interval
        self.refreshRate = refreshRate
        
        self.clock.schedule(deadline: .now(), repeating: 1.0 / refreshRate)
        self.clock.setEventHandler { [weak self] in
            guard let self = self else { return }
            for eventHandler in self.eventHandlers {
                eventHandler()
            }
        }
        self.eventHandlers.append { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.ready = (self.timeLeft <= 0)
            }
        }
        self.clock.resume()
    }
    deinit {
        self.clock.cancel() // finalize the clock object safely
    }
}

extension CDSystemProtocol {
    
    func waitUntilReady(refreshRate: Double) async {
        let refreshRate_ = Clamped.to(value: refreshRate, range: 0 ... MAX_REFRESH_RATE)
        await wait(pollInterval: 1.0/refreshRate_, until: { ready })
    }
}
