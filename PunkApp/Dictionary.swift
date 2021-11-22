//
//  Dictionary.swift
//  RestKitUI
//
//  Created by Giuseppe Mazzilli on 02/03/2021.
//

import Foundation

extension Dictionary {
    
    init(withNonNilValues dict: [Key: Value?]) {
        self = dict.reduce(into: [:]) { (d, kv) in d[kv.0] = kv.1 }
    }
    
    mutating func union(dict: [Key: Value]) {
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
    
    mutating func union(withNonNilValues dict: [Key: Value?]) {
        let dict = [Key: Value](withNonNilValues: dict)
        self.union(dict: dict)
    }
    
    func joinedString(separator: String) -> String {
        var phrases : [String] = []
        for (k, v) in self {
            phrases.append("\(k): \(String(describing: v))")
        }
        return phrases.joined(separator: separator)
    }
    
}
