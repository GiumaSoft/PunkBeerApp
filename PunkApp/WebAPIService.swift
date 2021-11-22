//
//  WebAPIService.swift
//  RestKitUI
//
//  Created by Giuseppe Mazzilli on 27/01/2021.
//

import Foundation

protocol WebAPIService {
    var scheme      : HTTPScheme            { get }
    var host        : String                { get }
    var path        : String                { get }
    var port        : Int                   { get }
    var queryItems  : [URLQueryItem]?       { get }
    var method      : HTTPMethod            { get }
    var headers     : [String: String]      { get }
    var payload     : Data?                 { get }
    
    var urlComponents: URLComponents { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var timeout: TimeInterval { get }
    
    func base64EncodedCredentials(user: String, secret: String) throws -> String
}

extension WebAPIService {

    var scheme      : HTTPScheme            { .Https }
    var path        : String                { "/" }
    var port        : Int                   { scheme.port }
    var queryItems  : [URLQueryItem]?       { nil }
    var method      : HTTPMethod            { .Get }
    var headers     : [String: String]      { [:] }
    var payload     : Data?                 { nil }
    
    var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = scheme.description
        components.host = host
        components.path = path
        components.port = port
        components.queryItems = queryItems
        return components
    }
    var cachePolicy: URLRequest.CachePolicy { .reloadIgnoringLocalCacheData }
    var timeout: TimeInterval { 30 }
    
    
// MARK:- Public methods
    
    
    
    // MARK:- base64EncodedCredentials(_:)
    func base64EncodedCredentials(user: String, secret: String) -> String {
        guard let encodedString = String(format: "%@:%@", user, secret).data(using: .utf8) else {
            dLog("Basic authentication base64 string failed to generate due to invalid characters in user or secret params")
            return String()
        }
        return encodedString.base64EncodedString()
    }
    
}
