//
//  BinaryBuff.swift
//  Utils
//
//  Created by Damian Malarczyk on 08.03.2017.
//
//

import Foundation

func intbinaryBuff_intBitCapacity() -> Int {
    return MemoryLayout<Int>.size * 8
}


public struct IntBinaryBuff: CustomStringConvertible, Equatable {
    
    public enum Error: Swift.Error {
        case indexOutOfRange, incorrectRawBufferForGivenCapacity
    }
    
    let intBitCapacity = intbinaryBuff_intBitCapacity()
    
    private(set) public var rawBuff: [Int]
    
    private(set) public var capacity: Int {
        didSet {
            buffLimit = getBuffLimit(forCapacity: capacity)
        }
    }
    private var buffLimit: Int = -1
    
    public init(capacity: Int) {
        self.capacity = capacity
        rawBuff = []
        self.buffLimit = getBuffLimit(forCapacity: capacity)
        for _ in 0 ..< buffLimit {
            rawBuff.append(0)
        }
    }
    
    public init(raw: [Int]) {
        self.rawBuff = raw
        self.capacity = raw.count * intBitCapacity
        self.buffLimit = getBuffLimit(forCapacity: capacity)
        
    }
    
    public init(raw: [Int], capacity: Int) throws {
        
        self.rawBuff = raw
        self.capacity = capacity
        self.buffLimit = getBuffLimit(forCapacity: capacity)
        self.maskBuffer()
        
        if raw.count < buffLimit {
            throw Error.incorrectRawBufferForGivenCapacity
        }
        
        
    }
    
    public func getBuffLimit(forCapacity capacity: Int) -> Int {
        return ((capacity / intBitCapacity) + (capacity % intBitCapacity > 0 ? 1 : 0))
    }
    
    private mutating func maskBuffer() {
        let move = intBitCapacity - 1 - (capacity % intBitCapacity)
        let mask = Int.max >> move
        self.rawBuff[self.rawBuff.count - 1] = self.rawBuff[self.rawBuff.count - 1] & mask
    }
    
    public mutating func extend(toCapacity to: Int) {
        if to <= capacity {
            capacity = to
        } else {
            capacity = to
            
            for _  in rawBuff.count ..< buffLimit {
                rawBuff.append(0)
            }
        }
    }
    
    public func evaluate(usingWeights: [Double]) -> Double {
        assert(usingWeights.count <= capacity)
        var res: Double = 0
        for (indx, weight) in usingWeights.enumerated() {
            if self[indx] {
                res += weight
            }
        }
        return res
    }
    
    public func get(index: Int) throws -> Bool {
        guard index >= 0 && index < capacity else {
            throw Error.indexOutOfRange
        }
        let rawIndex = index / intBitCapacity
        let _buff = rawBuff[rawIndex]
        let current = index - (rawIndex * intBitCapacity)
        return ((_buff >> current) & 1) == 1
    }
    
    public mutating func set(index: Int, value: Bool) throws {
        guard index >= 0 && index < capacity else {
            throw Error.indexOutOfRange
        }
        let rawIndex = index / intBitCapacity
        let current = index - (rawIndex * intBitCapacity)
        let _buff = rawBuff[rawIndex]
        if value {
            rawBuff[rawIndex] = _buff | (1 << current)
        } else {
            rawBuff[rawIndex] = _buff & ~(1 << current)
        }
    }
    
    public subscript(index: Int) -> Bool {
        get {
            precondition(index >= 0)
            precondition(index < capacity)
            let rawIndex = index / intBitCapacity
            let _buff = rawBuff[rawIndex]
            let current = index - (rawIndex * intBitCapacity)
            return ((_buff >> current) & 1) != 0
        }
        set {
            precondition(index >= 0)
            precondition(index < capacity)
            let rawIndex = index / intBitCapacity
            let current = index - (rawIndex * intBitCapacity)
            let _buff = rawBuff[rawIndex]
            if newValue {
                rawBuff[rawIndex] = _buff | (1 << current)
            } else {
                rawBuff[rawIndex] = _buff & ~(1 << current)
            }
        }
        
    }
    
    public func toArray() -> [Bool] {
        var arr: [Bool] = []
        for v in self {
            arr.append(v)
        }
        return arr
    }
    
    public func crossover(with rhs: IntBinaryBuff, upToBits: Int, pointsCount: Int) -> (IntBinaryBuff, IntBinaryBuff) {
        
        precondition(upToBits <= self.capacity && upToBits <= rhs.capacity)
        var upToBits = upToBits
        var indx = 0
        let pointsCount = pointsCount / rawBuff.count
        var son = self
        var daughter = rhs
        
        while upToBits > intBitCapacity {
            (daughter.rawBuff[indx], son.rawBuff[indx]) = self.rawBuff[indx].bitCrossover(with: rhs.rawBuff[indx], upToBit: intBitCapacity, pointsCount: pointsCount)
            
            indx += 1
            upToBits -= intBitCapacity
        }
        (daughter.rawBuff[indx], son.rawBuff[indx]) = self.rawBuff[indx].bitCrossover(with: rhs.rawBuff[indx], upToBit: upToBits, pointsCount: pointsCount < upToBits ? pointsCount : upToBits / 2)
        son.maskBuffer()
        daughter.maskBuffer()
        return (son, daughter)
    }
    
    public var description: String {
        var res = ""
        for i in 0 ..< capacity {
            res += "\(self[i] ? 1 : 0)"
        }
        res += "/\(capacity)"
        return res
    }
    
    
    public static func ==(_ lhs: IntBinaryBuff, _ rhs: IntBinaryBuff) -> Bool {
        
        return lhs.capacity == rhs.capacity && lhs.rawBuff == rhs.rawBuff
        
    }
    
    public mutating func unsafeSetRawBuffer(newValue: Int, index: Int) {
        rawBuff[index] = newValue
    }
    
    
}


extension IntBinaryBuff: Collection {
    public typealias Index = Int
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return capacity
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
}



////
////  IntBinaryBuff.swift
////  Utils
////
////  Created by Damian Malarczyk on 08.03.2017.
////
////
//
//import Foundation
//
//
//public struct IntBinaryBuff: CustomStringConvertible, Equatable {
//    public enum Error: Swift.Error {
//        case indexOutOfRange, incorrectRawBufferForGivenCapacity
//    }
//    
//    static let intBitCapacity = MemoryLayout<Int>.size * 8
//    private(set) public var rawBuff: [Int]
//    private(set) public var capacity: Int {
//        didSet {
//            buffLimit = IntBinaryBuff.getBuffLimit(forCapacity: capacity)
//        }
//    }
//    private var buffLimit: Int
//    
//    public static func getBuffLimit(forCapacity capacity: Int) -> Int {
//        return ((capacity / IntBinaryBuff.intBitCapacity) + (capacity % IntBinaryBuff.intBitCapacity > 0 ? 1 : 0))
//    }
//    
//    public init(capacity: Int) {
//        self.capacity = capacity
//        self.buffLimit = IntBinaryBuff.getBuffLimit(forCapacity: capacity)
//        rawBuff = []
//        for _ in 0 ..< buffLimit {
//            rawBuff.append(0)
//        }
//    }
//    
//    public init(raw: [Int]) {
//        self.rawBuff = raw
//        self.capacity = raw.count * IntBinaryBuff.intBitCapacity
//        self.buffLimit = IntBinaryBuff.getBuffLimit(forCapacity: self.capacity)
//    }
//    
//    private mutating func maskBuffer() {
//        let move = IntBinaryBuff.intBitCapacity - 1 - (capacity % IntBinaryBuff.intBitCapacity)
//        let mask: Int = Int.max >> move
//        self.rawBuff[self.rawBuff.count - 1] = self.rawBuff[self.rawBuff.count - 1] & mask
//    }
//    
//    public init(raw: [Int], capacity: Int) throws {
//        self.buffLimit = IntBinaryBuff.getBuffLimit(forCapacity: capacity)
//        if raw.count < buffLimit {
//            throw Error.incorrectRawBufferForGivenCapacity
//        }
//        
//        self.rawBuff = raw
//        self.capacity = capacity
//        self.maskBuffer()
//        
//    }
//    
//    public mutating func extend(toCapacity to: Int) {
//        if to <= capacity {
//            capacity = to
//        } else {
//            capacity = to
//            
//            for _  in rawBuff.count ..< buffLimit {
//                rawBuff.append(0)
//            }
//        }
//    }
//    
//    public func evaluate(usingWeights: [Double]) -> Double {
//        assert(usingWeights.count <= capacity)
//        var res: Double = 0
//        for (indx, weight) in usingWeights.enumerated() {
//            if self[indx] {
//                res += weight
//            }
//        }
//        return res
//    }
//    
//    
//    public func get(index: Int) throws -> Bool {
//        guard index >= 0 && index < capacity else {
//            throw Error.indexOutOfRange
//        }
//        let rawIndex = index / IntBinaryBuff.intBitCapacity
//        let _buff = rawBuff[rawIndex]
//        let current = index - (rawIndex * IntBinaryBuff.intBitCapacity)
//        return ((_buff >> current) & 1) != 0
//    }
//    
//    public mutating func set(index: Int, value: Bool) throws {
//        guard index >= 0 && index < capacity else {
//            throw Error.indexOutOfRange
//        }
//        let rawIndex = index / IntBinaryBuff.intBitCapacity
//        let current = index - (rawIndex * IntBinaryBuff.intBitCapacity)
//        let _buff = rawBuff[rawIndex]
//        if value {
//            rawBuff[rawIndex] = _buff | (1 << current)
//        } else {
//            rawBuff[rawIndex] = _buff & ~(1 << current)
//        }
//    }
//    
//    public subscript(index: Int) -> Bool {
//        get {
//            precondition(index >= 0)
//            precondition(index < capacity)
//            let rawIndex = index / IntBinaryBuff.intBitCapacity
//            let _buff = rawBuff[rawIndex]
//            let current = index - (rawIndex * IntBinaryBuff.intBitCapacity)
//            return ((_buff >> current) & 1) != 0
//        }
//        set {
//            precondition(index >= 0)
//            precondition(index < capacity)
//            let rawIndex = index / IntBinaryBuff.intBitCapacity
//            let current = index - (rawIndex * IntBinaryBuff.intBitCapacity)
//            let _buff = rawBuff[rawIndex]
//            if newValue {
//                rawBuff[rawIndex] = _buff | (1 << current)
//            } else {
//                rawBuff[rawIndex] = _buff & ~(1 << current)
//            }
//        }
//        
//    }
//    
//    public func toArray() -> [Bool] {
//        var arr: [Bool] = []
//        for v in self {
//            arr.append(v)
//        }
//        return arr
//    }
//    
//    public func crossover(with rhs: IntBinaryBuff, upToBits: Int, pointsCount: Int) -> (IntBinaryBuff, IntBinaryBuff) {
//        
//        precondition(upToBits <= self.capacity && upToBits <= rhs.capacity)
//        var upToBits = upToBits
//        var indx = 0
//        let pointsCount = pointsCount / rawBuff.count
//        var son = self
//        var daughter = rhs
//        
//        while upToBits > IntBinaryBuff.intBitCapacity {
//            (daughter.rawBuff[indx], son.rawBuff[indx]) = self.rawBuff[indx].bitCrossover(with: rhs.rawBuff[indx], upToBit: IntBinaryBuff.intBitCapacity, pointsCount: pointsCount)
//            
//            indx += 1
//            upToBits -= IntBinaryBuff.intBitCapacity
//        }
//        (daughter.rawBuff[indx], son.rawBuff[indx]) = self.rawBuff[indx].bitCrossover(with: rhs.rawBuff[indx], upToBit: upToBits, pointsCount: pointsCount < upToBits ? pointsCount : upToBits / 2)
//        son.maskBuffer()
//        daughter.maskBuffer()
//        return (son, daughter)
//    }
//    
//    public var description: String {
//        var res = ""
//        for i in 0 ..< capacity {
//            res += "\(self[i] ? 1 : 0)"
//        }
//        res += "/\(capacity)"
//        return res
//    }
//    
//    
//    public static func==(_ lhs: IntBinaryBuff, _ rhs: IntBinaryBuff) -> Bool {
//        
//        return lhs.capacity == rhs.capacity && lhs.rawBuff == rhs.rawBuff
//        
//    }
//    
//    public mutating func unsafeSetRawBuffer(newValue: Int, index: Int) {
//        rawBuff[index] = newValue
//    }
//    
//    
//}
//
//
//extension IntBinaryBuff: Collection {
//    public typealias Index = Int
//    public var startIndex: Int {
//        return 0
//    }
//    
//    public var endIndex: Int {
//        return capacity
//    }
//    
//    public func index(after i: Int) -> Int {
//        return i + 1
//    }
//}
