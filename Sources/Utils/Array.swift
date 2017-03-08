//
//  Array.swift
//  Utils
//
//  Created by Damian Malarczyk on 08.03.2017.
//
//

import Foundation

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
