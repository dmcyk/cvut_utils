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
            wordContent.deallocate(capacity: 2048)
        }
        return found
    }
    
}
