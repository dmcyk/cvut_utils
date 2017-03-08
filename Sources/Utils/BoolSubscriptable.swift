//
//  BoolSubscriptable.swift
//  Utils
//
//  Created by Damian Malarczyk on 08.03.2017.
//
//

import Foundation


public protocol BoolSubscriptable {
    var capacity: Int { get }
    subscript (index: Int) -> Bool { get set }
}

extension BoolSubscriptable where Self: Collection & Equatable {
    
    @discardableResult
    public mutating func replacement() -> Int {
        
        let atIndex = Int.arc4random_uniform(capacity)
        self[atIndex] = !self[atIndex]
        return atIndex
    }
    
    @discardableResult
    public mutating func removal() -> (Bool, Int) {
        let indx = Int.arc4random_uniform(capacity)
        let current = self[indx]
        self[indx] = false
        return (current, indx)
    }
    
    @discardableResult
    public mutating func randomSwap() -> (Int, Int) {
        
        let left = Int.arc4random_uniform(capacity)
        var right = Int.arc4random_uniform(capacity)
        if left == right {
            right = left > 0 ? left - 1 : left + 1
        }
        (self[left], self[right]) = (self[right], self[left])
        return (left, right)
        
    }
    
    @discardableResult
    public mutating func adjacentSwap() -> (Int, Int) {
        
        let left = Int.arc4random_uniform(capacity)
        let right: Int
        if left < capacity - 1 {
            right = left + 1
        } else {
            right = left - 1
        }
        (self[left], self[right]) = (self[right], self[left])
        return (left, right)
    }
    
}

extension BinaryBuff: BoolSubscriptable {
    
    public mutating func endForEndSwap() {
        let intBitCapacity = MemoryLayout<Int>.size * 8
        var remainingCap = capacity
        for i in 0 ..< rawBuff.count {
            var v = rawBuff[i]
            v = ((v >> 1) & 0x55555555) | ((v & 0x55555555) << 1)
            v = ((v >> 2) & 0x33333333) | ((v & 0x33333333) << 2)
            v = ((v >> 4) & 0x0F0F0F0F) | ((v & 0x0F0F0F0F) << 4)
            v = ((v >> 8) & 0x00FF00FF) | ((v & 0x00FF00FF) << 8)
            if remainingCap > 16 {
                v = ( v >> 16 ) | ( v  << 16)
                if remainingCap > 32 {
                    v = ( v >> 32 ) | ( v << 32)
                }
            }
            remainingCap -= intBitCapacity
            unsafeSetRawBuffer(newValue: v, index: i)
            
        }
        
    }
    
    public mutating func inversion() {
        var center = Int.arc4random_uniform(capacity - 1)
        center = center > 0 ? center : 1
        var spread = Int.arc4random_uniform(Swift.min(center, capacity - center) / 2)
        spread = spread > 0 ? spread : 1
        for i in 1 ... spread {
            (self[center + i], self[center - i]) = (self[center - i], self[center + i])
        }
    }
}
