//
//  Limit to a Range.swift
//
//
//  Created by Z. D. Yu on 22.M.20.
//

/// Auto Limit a value to a designated range
///
/// Example of usage:
///
///     @AutoLimit(to: 0 ... .infinity) var mass: Double? = 1.0
///     mass = -1.0
///     mass    // 0.0
///
///     @AutoLimit(to: 1 ... 12, isConstant: true) var month: Int!
///     //month     // Error❌: Constant must be assigned before use!
///     month = 5
///     //month = 6 // Error❌: Constant must be assigned only once!
///
///     let projectedValue = $mass // In AutoLimit, `$` (projected value)
///                                // is the value after `@` processing
///     projectedValue.range    // 0.0 ... inf
///
/// Due to technical limitations, please note:
///
/// -   You **won't get warned** when a constant here is assigned 0 or more than 1 times, since its functionality
///     is fully implemented in normal code to be executed in **runtime**, and it's none o' f_king business of complier.
///     Thanks to God, by using `precondition`, Swift runtime will ensure the process get crashed
///     when there is something wrong with constant instead of keeping security issues growing.
/// -   Wrapped value must be of an optional type to express the state of unassigned, so you may want to
///     use `!` to force unwrapping the optional type when you define an `@AutoLimit` value, as seen in the examples.
@propertyWrapper
struct AutoLimit<Value> where Value: Comparable {

    var wrappedValue: Value? {
        get {
            precondition(isAssigned, "Constant must be assigned before use!")
            return value
        }
        set {
            precondition(!isConstant || !isAssigned,
                         "Constant must be assigned only once!")
            if let value = newValue {
                self.value = Self.limitValue(value: value, range: range)
                self.isAssigned = true
            }
        }
    }
    private(set) var value: Value?
    let isConstant: Bool
    private(set) var isAssigned = false
    
    init(wrappedValue: Value? = nil, to range: ClosedRange<Value>, isConstant: Bool = false) {
        if let value = wrappedValue {
            self.value = Self.limitValue(value: value, range: range)
            self.isAssigned = true
        }
        self.range = range
        self.isConstant = isConstant
    }
    
    private static func limitValue(value: Value,
                                   range: ClosedRange<Value>) -> Value {
        var result = value
        let lower = range.lowerBound, upper = range.upperBound
        if result < lower { result = lower }
        if result > upper { result = upper }
        return result
    }
    
    var projectedValue: Self { self }
    let range: ClosedRange<Value>
}

