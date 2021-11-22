//
//  Functions.swift
//  PunkApp
//
//  Created by Giuseppe Mazzilli on 21/11/21.
//

import Foundation

func dLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if _DEBUG
    print(items, separator: separator, terminator: terminator)
    #endif
}
