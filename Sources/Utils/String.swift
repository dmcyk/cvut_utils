//
//  String.swift
//  Utils
//
//  Created by Damian Malarczyk on 08.03.2017.
//
//

import Foundation


public extension String {
    func lastIndexOf(_ string: String) -> String.Index? {
        if let r = self.range(of: string, options: .backwards) {
            return r.lowerBound
        }
        return nil
    }
}
