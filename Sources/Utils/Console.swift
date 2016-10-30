//
//  Console
//  Task1
//
//  Created by Damian Malarczyk on 14.10.2016.
//  Copyright © 2016 Damian Malarczyk. All rights reserved.
//

import Foundation


indirect enum ArgumentValueType {
    case int, double, array(ArgumentValueType)
}

enum ArgumentValue {
    case int(Int)
    case double(Double)
    case array([ArgumentValue])
    
    var intValue: Int? {
        if case .int(let value) = self {
            return value
        }
        return nil
    }
    
    var doubleValue: Double? {
        if case .double(let value) = self {
            return value
        }
        return nil
    }
    
    var arrayValue: [ArgumentValue]? {
        if case .array(let value) = self {
            return value
        }
        return nil
    }
    
    
    
}

enum ArgumentError: Error {
    case noAssignment, incorrectValue, indirectValue, noValue
}

struct ContainedArgumentError: Error {
    let error: ArgumentError
    let argument: Argument
}

struct Argument {
    var expected: ArgumentValueType
    var name: String
    var `default`: ArgumentValue?
    
    init(_ name: String, expectedValue: ArgumentValueType, `default`: ArgumentValue? = nil ) {
        self.name = name
        self.expected = expectedValue
        self.default = `default`
    }
    
    private func extractNumber(_ src: String) throws -> NSNumber {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en-US")
        guard let number = numberFormatter.number(from: src) else {
            throw ArgumentError.incorrectValue
        }
        return number
    }
    
    func extract(_ srcs: [String]) throws -> ArgumentValue {
        for src in srcs {
            guard src.contains("--\(name)=") else {
                continue
            }
            if let equal = src.characters.index(of: "=") {
                let afterEqual = src.characters.index(after: equal)
                let value = src.substring(from: afterEqual)
                
                switch expected {
                case .int, .double:
                    let number = try extractNumber(value)
                    
                    if case .int = expected {
                        return .int(number.intValue)
                    } else {
                        return .double(number.doubleValue)
                    }
                case .array(let inner):
                    let values = value.components(separatedBy: ",")
                    switch inner {
                    case .double:
                        return try .array(values.map {
                            try .double(extractNumber($0).doubleValue)
                        })
                    case .int:
                        return try .array(values.map {
                            try .int(extractNumber($0).intValue)
                        })
                    case .array(_):
                        throw ArgumentError.indirectValue
                    }
                    
                }
            }
        }
        if let def = self.default {
            return def
        } else {
            throw ArgumentError.noValue
        }
    }
}
