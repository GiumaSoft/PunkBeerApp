//
//  APIClient.swift
//  RestKitUI
//
//  Created by Giuseppe Mazzilli on 27/01/2021.
//

import UIKit

//MARK: - APIError
enum APIError: Error {
    case failRetrieveRootCA
    case failServerTrust
    case mismatchSSLPinningCert
    case unsupportedAuthMethod
    case unhandledResponse
    case invalidURL
    case generic(Error)
    
    var localizedDescription: String {
        switch self {
        case .failRetrieveRootCA:
            return "Failed to retrieve root ca from protected spaces."
        case .failServerTrust:
            return "Server is not trust."
        case .mismatchSSLPinningCert:
            return "Local and remote certificates are mismatch"
        case .unsupportedAuthMethod:
            return "Authentication method is not supported"
        case .unhandledResponse:
            return "Unhandled response from server"
        case .invalidURL:
            return "Can't open valid URL"
        case .generic(let error):
            return error.localizedDescription
        }
    }
}

//MARK:- APIResult
enum APIResult {
    case challenge(URLSession.AuthChallengeDisposition, URLCredential?, APIError?)
    case success(Data)
    case failure(Data?, URLResponse)
    case error(APIError)
}

//MARK:- WebAPI
protocol WebAPI {
    
    associatedtype APIService: WebAPIService
    
    var delegate: URLSessionDelegate? { get }
    var configuration: URLSessionConfiguration { get }
    
    
    func auth(for challenge: URLAuthenticationChallenge, selfSignedEnabled: Bool, localCertPath: String?, completionHandler: @escaping (APIResult) -> Void)
    func fetch(_ service: APIService, completion: @escaping (APIResult) -> Void)
    func fetch(_ request: URLRequest, completion: @escaping (APIResult) -> Void)
    
}

extension WebAPI {
    
    var configuration: URLSessionConfiguration { .default }
    
    //MARK:- auth(for:)
    func auth(for challenge: URLAuthenticationChallenge, selfSignedEnabled: Bool = false, localCertPath: String? = nil, completionHandler: @escaping (APIResult) -> Void) {

        let authMethod = challenge.protectionSpace.authenticationMethod
        
        switch authMethod {
        case NSURLAuthenticationMethodServerTrust:
            guard
                // Get certificate chain for contacted server
                 let serverTrust = challenge.protectionSpace.serverTrust
                // Get a valid server certificate for the remote host
                ,let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0)
                // Check if SSL certificate is present into bundled resources (only Base64 DER format is supported)
                // ,let localCert = Bundle.main.path(forResource: "mobile.alitalia.com", ofType: "der")
            else {
                // Cancel authentication if any parameter is missing
                // should provide some error logs information from here
                // ...
                dLog("Failed to retrieve internals Root CA")
                completionHandler(.challenge(.cancelAuthenticationChallenge, nil, .failRetrieveRootCA))
                return
            }
            
            var isServerTrust : Bool = false
            
            // Check is server certificate is valid or bypass check for self-signed
            isServerTrust = selfSignedEnabled || SecTrustEvaluateWithError(serverTrust, nil)
                
            if isServerTrust {
                
                if let localCertPath = localCertPath {
                    
                    do {
                        // Try to load bundled resource into a memory data storage
                        let localCertData = try NSData(contentsOfFile: localCertPath) as NSData
                        // Try to convert server certificate to a Data type
                        let remoteCertData = SecCertificateCopyData(serverCert) as Data
                        
                        dLog("localCertData = \(sha256(data: localCertData as Data).hashValue)")
                        dLog("remoteCertData = \(sha256(data: remoteCertData.base64EncodedData()).hashValue)")
                        
                        // Compare local with remote certificate then proceed if same or deny if different
                        if localCertData.isEqual(to: remoteCertData.base64EncodedData()) {
                            completionHandler(.challenge(.useCredential, URLCredential(trust: serverTrust), nil))
                        } else {
                            completionHandler(.challenge(.cancelAuthenticationChallenge, nil, .mismatchSSLPinningCert))
                        }
                        return
                        
                    } catch {
                        // Something failed. Cancel authentication
                        dLog(error.localizedDescription)
                        completionHandler(.challenge(.cancelAuthenticationChallenge, nil, .generic(error)))
                        return
                    }
                    
                } else {
                    // Proceed with not pinned certificate
                    completionHandler(.challenge(.useCredential, URLCredential(trust: serverTrust), nil))
                    return
                }
            }
            
            // Server is not trust. Cancel authentication
            dLog("Server is not trust, authentication failed")
            completionHandler(.challenge(.cancelAuthenticationChallenge, nil, .failServerTrust))
            return
        default:
            completionHandler(.challenge(.cancelAuthenticationChallenge, nil, .unsupportedAuthMethod))
        }

    }
    
    //MARK:- download(service:)
    func download(_ service: APIService, completion: @escaping (APIResult) -> Void) {
        
        guard let url = service.urlComponents.url else {
            dLog("Can't open a valid URL.")
            completion(.error(.invalidURL))
            return
        }
        
        download(url, completion: completion)
    }
    
    //MARK:- download(request:)
    func download(_ service: APIService) {
        
        guard let url = service.urlComponents.url else {
            dLog("Can't open a valid URL.")
            return
        }
        
        let session = URLSession(configuration: configuration,
                                 delegate: delegate,
                                 delegateQueue: OperationQueue())
        
        session.downloadTask(with: url).resume()

    }
    
    //MARK:- download(request:)
    func download(_ url: URL, completion: @escaping (APIResult) -> Void) {
        
        let session = URLSession(configuration: configuration,
                                 delegate: delegate,
                                 delegateQueue: OperationQueue())
        
        session.downloadTask(with: url) { (tempURL, response, error) in
            if let error = error {
                completion(.error(.generic(error)))
            } else {
                if let tempURL = tempURL, let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) {
                    do {
                        let baseURL = try FileManager.default.url(for: .documentDirectory,
                                                                      in: .userDomainMask,
                                                                      appropriateFor: nil,
                                                                      create: false)
                        
                        let documentURL = baseURL.appendingPathComponent(tempURL.lastPathComponent)
                        try FileManager.default.copyItem(at: tempURL, to: documentURL)
                        try completion(.success(Data(contentsOf: documentURL)))
                    } catch {
                        completion(.error(.generic(error)))
                    }
                } else {
                    completion(.error(.unhandledResponse))
                }
            }
        }.resume()
    
    }
    
    //MARK:- fetch(service:)
    func fetch(_ service: APIService, completion: @escaping (APIResult) -> Void) {
        guard let url = service.urlComponents.url else {
            dLog("Can't open a valid URL.")
            completion(.error(.invalidURL))
            return
        }

        var request = URLRequest(url: url,
                                 cachePolicy: service.cachePolicy,
                                 timeoutInterval: service.timeout)
    
        request.httpMethod = service.method.description
        request.allHTTPHeaderFields = service.headers
        request.httpBody = service.payload
        
        fetch(request, completion: completion)
    }

    //MARK:- fetch(request:)
    func fetch(_ request: URLRequest, completion: @escaping (APIResult) -> Void) {
        
        let session = URLSession(configuration: configuration,
                                 delegate: delegate,
                                 delegateQueue: .main)
        
        session.dataTask(with: request) { (data, response, error) in
            switch (data, response, error) {
            // Error case
            case (_, _, let .some(error)):
                dLog("Client returned an error.")
                dLog(error.localizedDescription)
                completion(.error(.generic(error)))
            // Success case
            case (let .some(data), let .some(response as HTTPURLResponse), _) where data.count > 0:
                if case 200..<300 = response.statusCode {
                    dLog("Client retrieved data successfully.")
                    completion(.success(data))
                } else {
                    completion(.failure(data, response))
                }
                // debugResponse(response, data: data)
            // Failure case
            case (_, let .some(response), _):
                debugResponse(response, data: data)
                completion(.failure(data, response))
            default:
                dLog("Client failed to handle response")
                completion(.error(.unhandledResponse))
            }
        }.resume()
        
    }
    
    func fetch(_ service: APIService) {
        guard let url = service.urlComponents.url else {
            dLog("Can't open a valid URL.")
            return
        }

        var request = URLRequest(url: url,
                                 cachePolicy: service.cachePolicy,
                                 timeoutInterval: service.timeout)
    
        request.httpMethod = service.method.description
        request.allHTTPHeaderFields = service.headers
        request.httpBody = service.payload
        
        fetch(request)
    }
    
    func fetch(_ request: URLRequest) {
        
        let session = URLSession(configuration: configuration,
                                 delegate: delegate,
                                 delegateQueue: .main)
        
        session.dataTask(with: request).resume()
    }
    
    private func responseHandler(response: (Data?, URLResponse?, Error?) -> Void, completion: @escaping (APIResult) -> Void) {
        
        
        
    }
    
    //MARK:- debugRespose(_:)
    private func debugResponse(_ response: URLResponse, data: Data?) {
        switch response {
        case let response as HTTPURLResponse:
            dLog("Server response code = \(response.statusCode), ", HTTPURLResponse.localizedString(forStatusCode: response.statusCode))
            if let url = response.url { dLog("URL:", url) }
            dLog("Headers\n{")
            for (key, value) in response.allHeaderFields {
                dLog("  \(key) = \(value)")
            }
            dLog("}")
            if let data = data {
                dLog("Body")
                dLog(String(decoding: data, as: UTF8.self))
                dLog(data.count, "bytes")
            }
        default:
            break
        }
    }


}
