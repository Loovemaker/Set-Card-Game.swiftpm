//
//  CDSystem.swift
//
//
//  Created by Z. D. Yu on 22.M.20.
//

import Foundation

protocol CDSystemProtocol {
    
    var ready: Bool { get }
    
    func activate() -> Bool
}

class SimpleCDSystem: CDSystemProtocol, ObservableObject {
    
    @Published var ready = true
    private(set) var nextReadyDate: Date = .distantPast
    
    var timeLeft: TimeInterval { nextReadyDate.timeIntervalSince(.now) }
    @discardableResult
    func refresh() -> Bool {
        ready = (timeLeft <= 0)
        return ready
    }
    
    private let clock: DispatchSourceTimer
    var eventHandlers: [DispatchSourceTimer.DispatchSourceHandler] = []
    
    @AutoLimitTo(min: 0, max: nil, isConstant: true) var interval: Double!
    @AutoLimitTo(min: 0, max: 100, isConstant: true) var refreshRate: Double!
    
    func activate() -> Bool {
        guard ready else { return false }
        nextReadyDate = .now.addingTimeInterval(interval)
        refresh()
        return true
    }
    
    init(interval: Double, refreshRate: Double = 50) {
        
        self.clock = DispatchSource.makeTimerSource(
            queue: DispatchQueue.global(qos: .userInteractive)
        )
        
        self.interval = interval
        self.refreshRate = refreshRate
        
        self.clock.schedule(deadline: .now(), repeating: 1.0 / refreshRate)
        self.clock.setEventHandler { [unowned self] in
            for eventHandler in eventHandlers {
                eventHandler()
            }
        }
        self.eventHandlers.append { [unowned self] in
            DispatchQueue.main.async {
                self.ready = (self.timeLeft <= 0)
            }
        }
        self.clock.resume()
    }
    deinit {
        self.clock.cancel()
    }
}
