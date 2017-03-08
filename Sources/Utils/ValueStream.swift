//
//  ValueStream.swift
//  Utils
//
//  Created by Damian Malarczyk on 08.03.2017.
//
//

import Foundation

public struct ValueStream<T> {
    public var fetchBlock:(inout [T]) -> Void
    public var buff: [T]
    
    @_specialize(Int)
    public init(fetchBlock: @escaping (inout [T]) -> Void) {
        self.fetchBlock = fetchBlock
        self.buff = []
        fill()
        
    }
    
    @_specialize(Int)
    mutating private func fill() {
        fetchBlock(&buff)
    }
    
    @_specialize(Int)
    mutating public func next() -> T {
        
        var last = buff.popLast()
        if last == nil {
            fill()
            last = buff.popLast()!
        }
        return last!
    }
}
