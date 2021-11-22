//
//  WebAPIFoundation.swift
//  RestKitUI
//
//  Created by Giuseppe Mazzilli on 27/01/2021.
//

import Foundation

// MARK:- HTTPScheme
enum HTTPScheme {
    
    case Http
    case Https
    case CustomHTTP(Int)
    case CustomHTTPS(Int)
    
    init?(port: Int) {
        switch port {
        case 80: self = .Http
        case 443: self = .Https
        default:
            self = .CustomHTTPS(port)
        }
    }
    
    var port: Int {
        switch self {
        case .Http:
            return 80
        case .Https:
            return 443
        case .CustomHTTP(let value),
             .CustomHTTPS(let value):
            return value
        }
    }
    
    var description: String {
        switch self {
        case .CustomHTTP: return "http"
        case .CustomHTTPS: return "https"
        default:
            return "\(self)".components(separatedBy: "(").first ?? ""
        }
    }
    
    
}

// MARK:- HTTPMethod
enum HTTPMethod {
    case Get
    case Post
    case Put
    case Delete
    case Head
    case Connect
    case Options
    case Patch
    
    var description: String {
        return "\(self)".uppercased()
    }
}
