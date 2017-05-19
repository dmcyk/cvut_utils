//
//  Utils.swift
//  Utils
//
//  Created by Damian Malarczyk on 19.05.2017.
//
//

import Foundation


public class Utilities {
    public static var cpuTime: Double {
        return Double(clock()) / Double(CLOCKS_PER_SEC)
    }
    
    public static func measureTime(block: () -> ()) -> Double {
        let start = cpuTime
        block()
        return cpuTime - start
    }
    public static func measureTimePassed(block: () -> ()) -> TimeInterval {
        let start = Date()
        block()
        return Date().timeIntervalSince(start)
    }
}
