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
    
    @_specialize(exported: true, where T: _Trivial(32))
    @_specialize(exported: true, where T: _Trivial(64))
    public init(fetchBlock: @escaping (inout [T]) -> Void) {
        self.fetchBlock = fetchBlock
        self.buff = []
        fill()
        
    }
    
    mutating public func fill() {
        fetchBlock(&buff)
    }
    
    
    @_specialize(exported: true, where T: _Trivial(32))
    @_specialize(exported: true, where T: _Trivial(64))
    mutating public func next() -> T {
        
        var last = buff.popLast()
        if last == nil {
            fill()
            last = buff.popLast()!
        }
        return last!
    }
}
