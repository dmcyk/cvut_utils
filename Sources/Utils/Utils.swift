//
//  Utils.swift
//  Task1
//
//  Created by Damian Malarczyk on 14.10.2016.
//  Copyright © 2016 Damian Malarczyk. All rights reserved.
//

import Foundation


public extension FileManager {
    func lineReadSourceFiles<T>(atFolderPath folder: String, fileExtensionCondition: (String) -> Bool = { _ in return true },
                             foundLineCallback: (String) -> T?) -> [T] {
        guard let dirEnumerator = enumerator(atPath: folder) else {
            return []
        }
        var found = [T]()
        for element in dirEnumerator {
            if let str = element as? String {
                found.append(contentsOf: lineReadSourceFile(folder + str, fileExtensionCondition: fileExtensionCondition, foundLineCallback: foundLineCallback))
            }
        }
        return found
    }
    
    func lineReadSourceFile<T>(_ filePath: String, fileExtensionCondition: (String) -> Bool = { _ in return true },
                            foundLineCallback: (String) -> T?) -> [T] {
        var found = [T]()
        
        let elementUrl = URL(fileURLWithPath: filePath)
        if fileExtensionCondition(elementUrl.pathExtension) {
            let wordContent = UnsafeMutablePointer<CChar>.allocate(capacity: 4096)
            
            let file = fopen(elementUrl.path, "r")
            
            guard file != nil else {
                fatalError("File at path \(elementUrl.path) not found")
            }
            while let line = fgets(wordContent, 4096, file) {
                if let parsedItem = foundLineCallback(String(cString: line)) {
                    found.append(parsedItem)
                }
            }
            
            fclose(file)
            wordContent.deallocate(capacity: 4096)
        }
        return found
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
    static func gaussianRandom(_ limit: Double) -> (Double, Double) {
        
        
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
    static func gaussianRandom(_ limit: Int) -> (Int, Int) {
        let random  = Double.gaussianRandom(Double(limit))
        return (Int(random.0), Int(random.1))
    }

}

