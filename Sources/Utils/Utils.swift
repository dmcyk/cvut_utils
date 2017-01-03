//
//  Utils.swift
//  Task1
//
//  Created by Damian Malarczyk on 14.10.2016.
//  Copyright © 2016 Damian Malarczyk. All rights reserved.
//

import Foundation
import Darwin

public extension FileManager {
    func lineReadSourceFiles<T>(atFolderPath folder: String, continueFlag: UnsafePointer<Bool>? = nil, fileExtensionCondition: (String) -> Bool = { _ in return true },
                             foundLineCallback: (String, Int) -> T? ) -> [T] {
        guard let dirEnumerator = enumerator(atPath: folder) else {
            return []
        }
        let folderUrl = URL(fileURLWithPath: folder)
        var found = [T]()
        for element in dirEnumerator {
            if let str = element as? String {
                found.append(contentsOf: lineReadSourceFile(folderUrl.appendingPathComponent(str).path, continueFlag: continueFlag, fileExtensionCondition: fileExtensionCondition, foundLineCallback: foundLineCallback))
            }
        }
        return found
    }
    
    func lineReadSourceFilesSeperate<T>(atFolderPath folder: String, continueFlag: UnsafePointer<Bool>? = nil, fileExtensionCondition: (String) -> Bool = { _ in return true },
                                     foundLineCallback: (String, Int) -> T? ) -> [[T]] {
        guard let dirEnumerator = enumerator(atPath: folder) else {
            return []
        }
        let folderUrl = URL(fileURLWithPath: folder)
        var found = [[T]]()
        for element in dirEnumerator {
            if let str = element as? String {
                found.append(lineReadSourceFile(folderUrl.appendingPathComponent(str).path, continueFlag: continueFlag, fileExtensionCondition: fileExtensionCondition, foundLineCallback: foundLineCallback))
            }
        }
        return found
    }
    
    func lineReadSourceFile<T>(_ filePath: String, continueFlag: UnsafePointer<Bool>? = nil, fileExtensionCondition: (String) -> Bool = { _ in return true },
                            foundLineCallback: (String, Int) -> T?) -> [T] {
        var found = [T]()
        
        let elementUrl = URL(fileURLWithPath: filePath)
        if fileExtensionCondition(elementUrl.pathExtension) {
            let wordContent = UnsafeMutablePointer<CChar>.allocate(capacity: 4096)
            
            let file = fopen(elementUrl.path, "r")
            
            guard file != nil else {
                fatalError("File at path \(elementUrl.path) not found")
            }
            var lineNumber = 1
            var further = true
            while further, let line = fgets(wordContent, 4096, file) {
                if let parsedItem = foundLineCallback(String(cString: line), lineNumber) {
                    found.append(parsedItem)
                }
                if let ctn = continueFlag {
                    further = ctn.pointee
                }
                lineNumber += 1
            }
            
            fclose(file)
            wordContent.deallocate(capacity: 4096)
        }
        return found
    }
    
    func exists(atPath path: String) -> (exists: Bool, isDir: Bool) {
        var bool: ObjCBool = false
        
        var isDir = false
        guard fileExists(atPath: path, isDirectory: &bool) else {
            return (false, isDir)
        }
        #if os(Linux)
            isDir = bool
        #else
            isDir = bool.boolValue
        #endif
        
        return (true, isDir)
    }
    
    enum Error: Swift.Error {
        case notFile, notFound
    }
    
    func remove(line toRemove: Int, atFile filePath: String) throws {
        let fTest = exists(atPath: filePath)
        guard fTest.exists else {
            throw Error.notFound
        }
        guard !fTest.isDir else {
            throw Error.notFile
        }
        
        let tmp = "\(filePath).tmp"
        createFile(atPath: tmp, contents: nil, attributes: [:])
        
        let fileHandler = FileHandle(forWritingAtPath: tmp)
        _  = lineReadSourceFile(filePath) { (line, number) in
            if toRemove != number {
                fileHandler?.write(line.data(using: .utf8)!)
            }
        }
        
        try removeItem(atPath: filePath)
        try copyItem(atPath: tmp, toPath: filePath)
        try removeItem(atPath: tmp)
        
        
    }
    
}


public extension Double {
    static func arc4random_uniform(_ upperBound: Double) -> Double {
        return Double(Darwin.arc4random_uniform(UInt32(upperBound)))
    }
    static func arc4random_uniform_i(_ upperBound: Double) -> Int {
        return Int(Darwin.arc4random_uniform(UInt32(upperBound)))
    }
}

public extension Int {
    static func arc4random_uniform(_ upperBound: Int) -> Int {
        return Int(Darwin.arc4random_uniform(UInt32(upperBound)))
    }
    
    static func arc4random_uniform_d(_ upperBound: Int) -> Double {
        return Double(Darwin.arc4random_uniform(UInt32(upperBound)))
    }
}


public extension Double {
    static func boxMullerRandom(_ limit: Double) -> (Double, Double) {
        
        var x1:Double = 0 , x2: Double = 0, w: Double = 0
        
        repeat {
            x1 = 2.0 * Double.arc4random_uniform(101) / 100 - 1.0
            x2 = 2.0 * Double.arc4random_uniform(101) / 100 - 1.0
            w = x1 * x1 + x2 * x2
        } while ( w >= 1.0 || w == 0)
        
        w = sqrt( (-2.0 * log( w ) ) / w );
        let y1 = ((x1 * w) + 3) / 6 * limit
        let y2 = ((x2 * w) + 3) / 6 * limit
        if y1.isNaN || y2.isNaN {
            print("error")
            fatalError()
        }
        return (y1, y2)
        
    }
}

public func _divide(withCrossoverPoints pointsCount: Int, count: Int) -> [(Int, Int)] {
    assert(pointsCount > 0 && pointsCount < count)
    
    let upperBound = count / (pointsCount + 1)
    
    var start = 0
    var till = upperBound - 1
    var points: [(Int, Int)] = []
    for _ in 0 ... Int(pointsCount) {
        points.append((start, till))
        start = till + 1
        till += upperBound
    }
    points[points.count - 1] = (start - upperBound, count - 1)
    return points
}


public struct BinaryBuff: CustomStringConvertible {
    public enum Error: Swift.Error {
        case indexOutOfRange
    }
    
    static let intBitCapacity = MemoryLayout<Int>.size * 8
    private(set) public var rawBuff: [Int]
    private(set) public var capacity: Int
    
    private func buffLimit(forCapacity capacity: Int) -> Int {
        return ((capacity / BinaryBuff.intBitCapacity) + (capacity % BinaryBuff.intBitCapacity > 0 ? 1 : 0))
    }
    
    public init(capacity: Int) {
        self.capacity = capacity
        rawBuff = []
        for _ in 0 ..< buffLimit(forCapacity: capacity) {
            rawBuff.append(0)
        }
    }
    
    public init(raw: [Int]) {
        self.rawBuff = raw
        self.capacity = raw.count * BinaryBuff.intBitCapacity
    }
    
    public mutating func extend(toCapacity to: Int) {
        if to <= capacity {
            capacity = to
        } else {
            capacity = to
            
            for _  in rawBuff.count ..< buffLimit(forCapacity: capacity) {
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
            assert(index >= 0)
            assert(index < capacity)
            let rawIndex = index / BinaryBuff.intBitCapacity
            let _buff = rawBuff[rawIndex]
            let current = index - (rawIndex * BinaryBuff.intBitCapacity)
            return ((_buff >> current) & 1) == 1
        }
        set {
            assert(index >= 0)
            assert(index < capacity)
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
    
    public func crossover(with rhs: BinaryBuff, upToBits: Int, pointsCount: Int) -> (BinaryBuff, BinaryBuff) {
        assert(upToBits <= self.capacity && upToBits <= rhs.capacity)
        
        var upToBits = upToBits
        var indx = 0
        var son = self
        var daughter = rhs
        while upToBits > 0 {
            (daughter.rawBuff[indx], son.rawBuff[indx]) = self.rawBuff[indx].bitCrossover(with: rhs.rawBuff[indx], upToBit: upToBits > BinaryBuff.intBitCapacity ? BinaryBuff.intBitCapacity : upToBits, pointsCount: pointsCount)
            
            indx += 1
            upToBits -= BinaryBuff.intBitCapacity
        }
        return (son, daughter)
    }
    
    public var description: String {
        var res = ""
        for i in 0 ..< capacity {
            res += "\(self[i] ? 1 : 0)"
        }
        return res
    }
    
}

public extension Int {
    static func boxMullerRandom(_ limit: Int) -> (Int, Int) {
        let random  = Double.boxMullerRandom(Double(limit))
        return (Int(random.0), Int(random.1))
    }
    
    subscript(index: Int) -> Bool {
        get {
            return ((self >> index) & 1) == 1
        }
        
        set {
            if newValue {
                self = self | (1 << index)
            } else {
                self = self & ~(1 << index)
            }
        }
    }
    
    
    
    func bitCrossover(with another: Int, upToBit upTo: Int, pointsCount: Int) -> (Int, Int) {
        assert(pointsCount > 0 && pointsCount < upTo)
        
        let points = _divide(withCrossoverPoints: pointsCount, count: upTo)
        var son = self
        var daughter = another
        for point in points {
            let mask = (1 << (point.1 - point.0) - 1) << point.0
            let dad = self & mask
            let mum = another & mask
            son &= ~mask
            daughter &= ~mask
            son |= mum
            daughter |= dad
            
        }

        return (son, daughter)
    }
    
}

public extension Array {
    
    func divide(withCrossoverPoints pointsCount: Int) -> [(Int, Int)] {
        return _divide(withCrossoverPoints: pointsCount, count: self.count)
    }
    
    func crossover(with another: [Element], pointsCount: Int) -> ([Element], [Element]) {
        let points = self.divide(withCrossoverPoints: pointsCount)
        var son = self
        var daughter = another
        
        for point in points {
            let range = point.0 ... point.1
            let dadGenom = self[range]
            let mumGenom = another[range]
            son[range] = mumGenom
            daughter[range] = dadGenom
        }
        return (son, daughter)
    }
    
}

public extension Array where Element: FloatingPoint {
    func normalized(scale: Element) -> [Element] {
        guard let maxVal = self.max(), let minVal = self.min() else {
            return []
        }
        let diff = maxVal - minVal
        return self.map { val in
            ((val - minVal) / diff) * scale
        }
    }
}

public extension String {
    func lastIndexOf(_ string: String) -> String.Index? {
        if let r = self.range(of: string, options: .backwards) {
            return r.lowerBound
        }
        return nil
    }
}
