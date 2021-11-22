//
//  RestClient.swift
//  RestKitUI
//
//  Created by Giuseppe Mazzilli on 27/01/2021.
//

import Foundation

enum RestAPIResult<T> {
    case decoded(T)
    case encoded(Data)
    case failure
    case error(Error)
}

protocol RestAPI: WebAPI {
    
    func fetch<T: Decodable>(_ service: APIService, completion: @escaping (RestAPIResult<T>) -> Void)
    func fetch<T: Decodable>(_ request: URLRequest, completion: @escaping (RestAPIResult<T>) -> Void)
}

extension RestAPI {
    
    func download<T: Decodable>(_ service: APIService, completion: @escaping (RestAPIResult<T>) -> Void) {
        
        download(service) { result in
            if case let .success(data) = result {
                do {
                    try completion(.decoded(JSONDecoder().decode(T.self, from: data)))
                    dLog("Provider returned decodable data")
                } catch {
                    dLog("Provider returned encoded data")
                    debugError(error)
                    completion(.encoded(data))
                }
            } else {
                completion(.failure)
            }
        }
    }
    
    func fetch<T: Decodable>(_ service: APIService, completion: @escaping (RestAPIResult<T>) -> Void) {
        fetch(service) { result in fetchHandler(result: result, completion: completion) }
    }
    
    func fetch<T: Decodable>(_ request: URLRequest, completion: @escaping (RestAPIResult<T>) -> Void) {
        fetch(request) { result in fetchHandler(result: result, completion: completion) }
    }
    
    private func fetchHandler<T: Decodable>(result: APIResult, completion: @escaping (RestAPIResult<T>) -> Void) {
        if case let .success(data) = result {
            do {
                try completion(.decoded(JSONDecoder().decode(T.self, from: data)))
                dLog("Provider returned decodable data")
            } catch {
                dLog("Provider returned encoded data")
                completion(.encoded(data))
            }
        } else {
            completion(.failure)
        }
    }
    
    private func debugError(_ error: Error) {
        switch error {
        case let error as DecodingError :
            dLog("---\n", "Decoding Error")
            switch error {
            case .keyNotFound(let key, let context):
                dLog("Key '\(key)' not found:", context.debugDescription)
                dLog("codingPath:", context.codingPath)
            case .valueNotFound(let value, let context):
                dLog("Value '\(value)' not found:", context.debugDescription)
                dLog("codingPath:", context.codingPath)
            case .typeMismatch(let type, let context):
                dLog("Type '\(type)' mismatch:", context.debugDescription)
                dLog("codingPath:", context.codingPath)
            case .dataCorrupted(let context):
                dLog(context)
            default:
                break
            }
        case let error as NSError:
            dLog(error.localizedDescription)
            dLog(error.localizedFailureReason ?? "")
            dLog(error.localizedRecoveryOptions ?? "")
        }
    }
    
}
