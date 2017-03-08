//
//  BinaryBuff.swift
//  Utils
//
//  Created by Damian Malarczyk on 08.03.2017.
//
//

import Foundation


public struct BinaryBuff: CustomStringConvertible, Equatable {
    public enum Error: Swift.Error {
        case indexOutOfRange, incorrectRawBufferForGivenCapacity
    }
    
    static let intBitCapacity = MemoryLayout<Int>.size * 8
    private(set) public var rawBuff: [Int]
    
    private(set) public var capacity: Int
    
    public static func buffLimit(forCapacity capacity: Int) -> Int {
        return ((capacity / BinaryBuff.intBitCapacity) + (capacity % BinaryBuff.intBitCapacity > 0 ? 1 : 0))
    }
    
    public init(capacity: Int) {
        self.capacity = capacity
        rawBuff = []
        for _ in 0 ..< BinaryBuff.buffLimit(forCapacity: capacity) {
            rawBuff.append(0)
        }
    }
    
    public init(raw: [Int]) {
        self.rawBuff = raw
        self.capacity = raw.count * BinaryBuff.intBitCapacity
    }
    
    private mutating func maskBuffer() {
        let move = BinaryBuff.intBitCapacity - 1 - (capacity % BinaryBuff.intBitCapacity)
        let mask: Int = Int.max >> move
        self.rawBuff[self.rawBuff.count - 1] = self.rawBuff[self.rawBuff.count - 1] & mask
    }
    
    public init(raw: [Int], capacity: Int) throws {
        if raw.count < BinaryBuff.buffLimit(forCapacity: capacity) {
            throw Error.incorrectRawBufferForGivenCapacity
        }
        
        self.rawBuff = raw
        self.capacity = capacity
        self.maskBuffer()
        
    }
    
    public mutating func extend(toCapacity to: Int) {
        if to <= capacity {
            capacity = to
        } else {
            capacity = to
            
            for _  in rawBuff.count ..< BinaryBuff.buffLimit(forCapacity: capacity) {
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
        let rawIndex = index / BinaryBuff.intBitCapacity
        let _buff = rawBuff[rawIndex]
        let current = index - (rawIndex * BinaryBuff.intBitCapacity)
        return ((_buff >> current) & 1) == 1
    }
    
    public mutating func set(index: Int, value: Bool) throws {
        guard index >= 0 && index < capacity else {
            throw Error.indexOutOfRange
        }
        let rawIndex = index / BinaryBuff.intBitCapacity
        let current = index - (rawIndex * BinaryBuff.intBitCapacity)
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
            let rawIndex = index / BinaryBuff.intBitCapacity
            let _buff = rawBuff[rawIndex]
            let current = index - (rawIndex * BinaryBuff.intBitCapacity)
            return ((_buff >> current) & 1) > 0
        }
        set {
            precondition(index >= 0)
            precondition(index < capacity)
            let rawIndex = index / BinaryBuff.intBitCapacity
            let current = index - (rawIndex * BinaryBuff.intBitCapacity)
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
    
    public func crossover(with rhs: BinaryBuff, upToBits: Int, pointsCount: Int) -> (BinaryBuff, BinaryBuff) {
        
        precondition(upToBits <= self.capacity && upToBits <= rhs.capacity)
        var upToBits = upToBits
        var indx = 0
        let pointsCount = pointsCount / rawBuff.count
        var son = self
        var daughter = rhs
        
        while upToBits > BinaryBuff.intBitCapacity {
            (daughter.rawBuff[indx], son.rawBuff[indx]) = self.rawBuff[indx].bitCrossover(with: rhs.rawBuff[indx], upToBit: BinaryBuff.intBitCapacity, pointsCount: pointsCount)
            
            indx += 1
            upToBits -= BinaryBuff.intBitCapacity
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
    
    
    public static func==(_ lhs: BinaryBuff, _ rhs: BinaryBuff) -> Bool {
        
        return lhs.capacity == rhs.capacity && lhs.rawBuff == rhs.rawBuff
        
    }
    
    public mutating func unsafeSetRawBuffer(newValue: Int, index: Int) {
        rawBuff[index] = newValue
    }
    
    
}


extension BinaryBuff: Collection {
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

extension BinaryBuff {
    
    public class CodingHelper: NSObject, NSCoding {
        public var buff: BinaryBuff
        
        public  func encode(with aCoder: NSCoder) {
            aCoder.encode(buff.capacity, forKey: "cap")
            aCoder.encode(buff.rawBuff, forKey: "buff")
        }
        
        public init(_ buff: BinaryBuff) {
            self.buff = buff
        }
        
        
        public required init?(coder aDecoder: NSCoder) {
            let capacity = aDecoder.decodeInteger(forKey: "cap")
            guard let rawBuff: [Int] = (aDecoder.decodeObject(forKey: "buff") as? NSArray as? [Int]) else {
                return nil
            }
            if let buff = try? BinaryBuff(raw: rawBuff, capacity: capacity) {
                self.buff = buff
            } else {
                return nil
            }
        }
    }
    
}
