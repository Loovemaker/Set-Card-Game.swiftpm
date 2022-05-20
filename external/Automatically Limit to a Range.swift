//
//  Limit to a Range.swift
//
//
//  Created by Z. D. Yu on 22.M.20.
//

@propertyWrapper
struct AutoLimitTo<Value> where Value: Comparable {

    var wrappedValue: Value? {
        get {
            precondition(isAssigned, "Constant must be assigned before use!")
            return value
        }
        set {
            precondition(!isConstant || !isAssigned,
                         "Constant must be assigned only once!")
            if let value = newValue {
                self.value = Self.limitValue(value: value, min: min, max: max)
                self.isAssigned = true
            }
        }
    }
    private(set) var value: Value?
    let isConstant: Bool
    private(set) var isAssigned = false
    
    init(wrappedValue: Value? = nil, min: Value?, max: Value?, isConstant: Bool) {
        if let value = wrappedValue {
            self.value = Self.limitValue(value: value, min: min, max: max)
            self.isAssigned = true
        }
        self.min = min
        self.max = max
        self.isConstant = isConstant
    }
    
    private static func limitValue(value: Value,
                                   min: Value?, max: Value?) -> Value {
        var result = value
        if let min = min, result < min { result = min }
        if let max = max, result > max { result = max }
        return result
    }
    
    var projectedValue: Self { self }
    let min: Value?, max: Value?
}

