//
//  PunkApiService.swift
//  PunkApp
//
//  Created by Giuseppe Mazzilli on 20/11/21.
//

import Foundation
import UIKit

extension PunkApiService {
    
    class SessionManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDownloadDelegate, URLSessionDataDelegate {
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            
        }
        
        func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
            dump(request)
        }
    }
}

struct PunkApiService: RestAPI {

    static let constItemsPerPage = 80
    
    enum APIService: WebAPIService {
    
        case getBeer(Int)
        case getBeers(Int)
        
        var scheme: HTTPScheme { .Https }
        var method: HTTPMethod { .Get }
        var host: String { "api.punkapi.com" }
        var path: String {
            switch self {
            case .getBeer(let value): return "/v2/beers/\(value)"
            case .getBeers: return "/v2/beers"
            }
        }
        var queryItems: [URLQueryItem]? {
            var items = [URLQueryItem]()
            switch self {
            case .getBeers(let page):
                items.append(URLQueryItem(name: "page", value: String(page)))
                items.append(URLQueryItem(name: "per_page", value: "\(constItemsPerPage)"))
                return items
            default:
                return nil
            }
            
        }
    }
    
    var delegate: URLSessionDelegate?
    var sessionManager: SessionManager
    
    init() {
        self.sessionManager = SessionManager()
        self.delegate = sessionManager
    }
    
    func getBeers(page: Int, completion: @escaping ([PunkBeer]) -> Void) {
        print("Fetching beers")
        fetch(.getBeers(page)) { (result: RestAPIResult<[PunkBeer]>) in
            switch result {
            case .decoded(var beers):
                DispatchQueue.global(qos: .userInitiated).async {
                    let group = DispatchGroup()
                    for (id, beer) in beers.enumerated() {
                        group.enter()
                        loadImage(urlString: beer.imageUrl) { data in
                            beers[id].imageData = data
                            group.leave()
                        }
                        _ = group.wait(timeout: .now() + 2)
                    }
                    group.notify(queue: .global(qos: .userInitiated)) {
                        print("done with fetch")
                        DispatchQueue.main.async {
                            completion(beers)
                        }
                        
                    }
                }
                
            default:
                completion([])
            }
        }
    }
    
    private func loadImage(urlString: String?, completion: @escaping (Data?) -> Void) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let request = URLRequest(url: url)
        fetch(request) { result in
            if case .success(let imageData) = result {
                completion(imageData)
            } else {
                completion(nil)
            }
        }
    }
    
}
