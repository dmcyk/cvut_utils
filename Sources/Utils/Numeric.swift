//
//  Numeric.swift
//  Utils
//
//  Created by Damian Malarczyk on 08.03.2017.
//
//

import Foundation

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
        
        precondition(pointsCount > 0 && pointsCount < upTo)
        
        let points = _divide(withCrossoverPoints: pointsCount, count: upTo)
        var son = self
        var daughter = another
        
        for point in points {
            var mask = (1 << (point.1 - point.0) - 1) << point.0
            let dad = self & mask
            let mum = another & mask
            mask = ~mask
            son &= mask
            daughter &= mask
            son |= mum
            daughter |= dad
            
        }
        
        
        return (son, daughter)
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
