//
//  BinaryBuff.swift
//  Utils
//
//  Created by Damian Malarczyk on 08.03.2017.
//
//

import Foundation

@_specialize(exported: true, where T: _Trivial(32))
@_specialize(exported: true, where T: _Trivial(64))
func binaryBuff_intBitCapacity<T: FixedWidthInteger>(_ type: T.Type) -> T {
    return T(MemoryLayout<T>.size * 8)
    
}


public struct BinaryBuff<StoreType: FixedWidthInteger>: CustomStringConvertible, Equatable {
    
    public enum Error: Swift.Error {
        case indexOutOfRange, incorrectRawBufferForGivenCapacity
    }
    
    let intBitCapacity: StoreType = binaryBuff_intBitCapacity(StoreType.self)
    let _intBitCapacity: Int = Int(binaryBuff_intBitCapacity(StoreType.self))
    
    private(set) public var rawBuff: [StoreType]
    
    private(set) public var capacity: Int {
        didSet {
            buffLimit = getBuffLimit(forCapacity: capacity)
        }
    }
    private var buffLimit: Int = -1
    
    @_specialize(exported: true, where StoreType: _Trivial(32))
    @_specialize(exported: true, where StoreType: _Trivial(64))
    public init(capacity: Int) {
        self.capacity = capacity
        rawBuff = []
        self.buffLimit = getBuffLimit(forCapacity: capacity)
        for _ in 0 ..< buffLimit {
            rawBuff.append(0)
        }
    }
    
    @_specialize(exported: true, where StoreType: _Trivial(32))
    @_specialize(exported: true, where StoreType: _Trivial(64))
    public init(raw: [StoreType]) {
        self.rawBuff = raw
        self.capacity = raw.count * _intBitCapacity
        self.buffLimit = getBuffLimit(forCapacity: capacity)

    }
    
    @_specialize(exported: true, where StoreType: _Trivial(32))
    @_specialize(exported: true, where StoreType: _Trivial(64))
    public init(raw: [StoreType], capacity: Int) throws {
        
        self.rawBuff = raw
        self.capacity = capacity
        self.buffLimit = getBuffLimit(forCapacity: capacity)
        self.maskBuffer()
        
        if raw.count < buffLimit {
            throw Error.incorrectRawBufferForGivenCapacity
        }
        
        
    }
    
    @_specialize(exported: true, where StoreType: _Trivial(32))
    @_specialize(exported: true, where StoreType: _Trivial(64))
    public func getBuffLimit(forCapacity capacity: Int) -> Int {
        return ((capacity / _intBitCapacity) + (capacity % _intBitCapacity > 0 ? 1 : 0))
    }
    
    @_specialize(exported: true, where StoreType: _Trivial(32))
    @_specialize(exported: true, where StoreType: _Trivial(64))
    private mutating func maskBuffer() {
        let move = StoreType(_intBitCapacity - 1 - (capacity % _intBitCapacity))
        let mask: StoreType = StoreType.max >> move
        self.rawBuff[self.rawBuff.count - 1] = self.rawBuff[self.rawBuff.count - 1] & mask
    }
    
    @_specialize(exported: true, where StoreType: _Trivial(32))
    @_specialize(exported: true, where StoreType: _Trivial(64))
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
    
    @_specialize(exported: true, where StoreType: _Trivial(32))
    @_specialize(exported: true, where StoreType: _Trivial(64))
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
    
    @_specialize(exported: true, where StoreType: _Trivial(32))
    @_specialize(exported: true, where StoreType: _Trivial(64))
    public func get(index: Int) throws -> Bool {
        guard index >= 0 && index < capacity else {
            throw Error.indexOutOfRange
        }
        let rawIndex = index / _intBitCapacity
        let _buff = rawBuff[rawIndex]
        let current = index - (rawIndex * _intBitCapacity)
        return ((_buff >> current) & 1) == 1
    }
    
    @_specialize(exported: true, where StoreType: _Trivial(32))
    @_specialize(exported: true, where StoreType: _Trivial(64))
    public mutating func set(index: Int, value: Bool) throws {
        guard index >= 0 && index < capacity else {
            throw Error.indexOutOfRange
        }
        let rawIndex = index / _intBitCapacity
        let current = index - (rawIndex * _intBitCapacity)
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
            let rawIndex = index / _intBitCapacity
            let _buff = rawBuff[rawIndex]
            let current = index - (rawIndex * _intBitCapacity)
            return ((_buff >> current) & 1) != 0
        }
        set {
            precondition(index >= 0)
            precondition(index < capacity)
            let rawIndex = index / _intBitCapacity
            let current = index - (rawIndex * _intBitCapacity)
            let _buff = rawBuff[rawIndex]
            if newValue {
                rawBuff[rawIndex] = _buff | (1 << current)
            } else {
                rawBuff[rawIndex] = _buff & ~(1 << current)
            }
        }
        
    }
    
    @_specialize(exported: true, where StoreType: _Trivial(32))
    @_specialize(exported: true, where StoreType: _Trivial(64))
    public func toArray() -> [Bool] {
        var arr: [Bool] = []
        for v in self {
            arr.append(v)
        }
        return arr
    }
    
    @_specialize(exported: true, where StoreType: _Trivial(32))
    @_specialize(exported: true, where StoreType: _Trivial(64))
    public func crossover(with rhs: BinaryBuff, upToBits: StoreType, pointsCount: StoreType) -> (BinaryBuff, BinaryBuff) {
        
        precondition(upToBits <= self.capacity && upToBits <= rhs.capacity)
        var upToBits = upToBits
        var indx = 0
        let pointsCount = pointsCount / StoreType(rawBuff.count)
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
    
    
    @_specialize(exported: true, where StoreType: _Trivial(32))
    @_specialize(exported: true, where StoreType: _Trivial(64))
    public static func ==(_ lhs: BinaryBuff, _ rhs: BinaryBuff) -> Bool {
        
        return lhs.capacity == rhs.capacity && lhs.rawBuff == rhs.rawBuff
        
    }
    
//    @_specialize(exported: true, where StoreType: _Trivial(32))
//    @_specialize(exported: true, where StoreType: _Trivial(64))
    public mutating func unsafeSetRawBuffer(newValue: StoreType, index: Int) {
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

