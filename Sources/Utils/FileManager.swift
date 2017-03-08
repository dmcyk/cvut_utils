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
    
    func lineReadSourceFilesSeperate<T>(atFolderPath folder: String, continueFlag: UnsafePointer<Bool>? = nil, fileExtensionCondition: (String) -> Bool = { _ in return true }, foundLineCallback: (String, Int) -> T? ) -> [[T]] {
        guard let dirEnumerator = enumerator(atPath: folder) else {
            return []
        }
        let folderUrl = URL(fileURLWithPath: folder)
        var found = [[T]]()
        for element in dirEnumerator {
            if let str = element as? String {
                let res = lineReadSourceFile(folderUrl.appendingPathComponent(str).path, continueFlag: continueFlag, fileExtensionCondition: fileExtensionCondition, foundLineCallback: foundLineCallback)
                if !res.isEmpty {
                    found.append(res)
                }
            }
        }
        return found
    }
    
    func lineReadSourceFilesSeperate<T>(atFolderPath folder: String, continueFlag: UnsafePointer<Bool>? = nil, fileExtensionCondition: (String) -> Bool = { _ in return true }, foundLineCallback: (String, Int) -> T?, fileCallback: ([T], String) -> Bool) {
        guard let dirEnumerator = enumerator(atPath: folder) else {
            return
        }
        let folderUrl = URL(fileURLWithPath: folder)
        for element in dirEnumerator {
            if let str = element as? String {
                let res = lineReadSourceFile(folderUrl.appendingPathComponent(str).path, continueFlag: continueFlag, fileExtensionCondition: fileExtensionCondition, foundLineCallback: foundLineCallback)
                if !res.isEmpty {
                    if !fileCallback(res, str) {
                        return
                    }
                }
            }
        }
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
