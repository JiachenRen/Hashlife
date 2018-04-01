//
//  Fetcher.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/30/17. Modified from Van Simmon's Fetcher.
//  Copyleft © 2017 Jiachen. I do not have rights :), modified from Van's.
//

import Foundation

class Fetcher: NSObject, URLSessionDelegate {
    
    func initSession(timeout: TimeInterval) -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    enum Status {
        case success(Data)
        case failure(String?)
    }
    
    func fetch(from url: URL, handler: @escaping (Status) -> Void) -> Void {
        let task = self.initSession(timeout: 30.0).dataTask(with: url) {(data, response, err) in
            guard let response = response as? HTTPURLResponse, err == nil else {
                return handler(.failure(err!.localizedDescription))
            }
            guard response.statusCode == 200 else {
                return handler(.failure("\(response.description)"))
            }
            guard let data = data else {
                return handler(.failure("valid response but no data"))
            }
            handler(.success(data))
        }
        task.resume()
    }
    
}
