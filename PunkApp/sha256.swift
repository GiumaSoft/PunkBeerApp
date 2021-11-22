//
//  sha256.swift
//  RestKitUI
//
//  Created by Giuseppe Mazzilli on 28/01/2021.
//

import Foundation
import CommonCrypto

func sha256(string: String) -> Data? {
    guard let data = string.data(using: .utf8) else { return nil }
    return sha256(data: data)
}

func sha256(data : Data) -> Data {
    var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash)
}

