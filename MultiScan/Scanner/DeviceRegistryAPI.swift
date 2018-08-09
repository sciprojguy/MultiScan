//
//  APNS.swift
//  MultiScan
//
//  Created by Chris Woodard on 7/2/18.
//  Copyright © 2018 Chris Woodard. All rights reserved.
//

import Foundation

typealias CompletionBlock = (Error?, [String:Any]) -> Void

class DeviceRegistryAPI: NSObject, URLSessionDelegate {
    
    var queue:OperationQueue? = nil
    var session:URLSession? = nil
    static var shared:DeviceRegistryAPI = DeviceRegistryAPI()
    
    private override init() {
    
        super.init()
        
        self.queue = OperationQueue()
        self.queue?.maxConcurrentOperationCount = 4
        
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.httpMaximumConnectionsPerHost = 4
        config.timeoutIntervalForRequest = 15
        
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: queue)
    }
    
 //MARK: - HTTP Methods

    func httpGet(url:URL, headers:[String:Any], completion:@escaping CompletionBlock) {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.httpMethod = "GET"
        if let task = self.session?.dataTask(with: request, completionHandler: { (data, response, error) in
            completion(error, self.resultsDict(err: error, response: response, data: data))
            }) {
            task.resume()
        }
        else {
            completion(nil, ["Error" : "ARGH"])
        }
    }
    
    func httpDelete(url:URL, headers:[String:Any], body:Data?, completion:@escaping CompletionBlock) {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
        request.httpMethod = "DELETE"
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let task = self.session?.dataTask(with: request, completionHandler: { (data, response, error) in
            completion(error, self.resultsDict(err: error, response: response, data: data))
            }) {
            task.resume()
        }
        else {
            completion(nil, ["Error" : "ARGH"])
        }
    }
    
    func httpPost(url:URL, headers:[String:Any], body:Data, completion:@escaping CompletionBlock) {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let task = session?.uploadTask(with: request, from: body, completionHandler: {data, response, error in
            completion(error, self.resultsDict(err: error, response: response, data: data))
        }) {
            task.resume()
        }
        else {
            completion(nil, ["Error" : "ARGH"])
        }
    }
    
    func httpPut(url:URL, headers:[String:Any], body:Data?, completion:@escaping CompletionBlock) {
    
    }

    func resultsDict( err:Error?, response:URLResponse?, data:Data?) -> [String:Any] {
        print("checking response: \(String(describing: response))")
        if let httpResponse = response as? HTTPURLResponse {
            var results:[String:Any] = [:]
            
            results["Status"] = httpResponse.statusCode
            results["Headers"] = httpResponse.allHeaderFields
            
            if let responseBody = data {
                if let stations = try? JSONSerialization.jsonObject(with: responseBody, options: .mutableContainers) {
                    results["Data"] = stations
                }
            }
            
            return results
        }

        return [:]
    }

    //MARK: - API methods for APNS -
    
    func register( device:Device ) {
    
        if let jsonData = try? JSONSerialization.data(withJSONObject: device.json(), options: []),
//        if let jsonData = try? JSONEncoder().encode(device),
           let url = URL(string: "https://builder-of-things.net:4343/device") {
           let jsonStr = String(data: jsonData, encoding: .utf8)!
            print("JSON: \(String(describing: jsonStr))")
            self.httpPost(url:url , headers: ["Content-Type":"application/json"], body: jsonData, completion: { results, err in
            })
        }
    }
    
    func unregister( device:Device ) {
        if let jsonData = try? JSONEncoder().encode(device),
           let url = URL(string: "https://builder-of-things.net:4343/device") {
            self.httpDelete(url:url, headers: [:], body: jsonData, completion: { results, err in
            
            })
        }
    }
    
    func registered_devices(completion:@escaping CompletionBlock) {
        if let url = URL(string: "https://builder-of-things.net:4343/devices") {
        
            self.httpGet(url: url, headers: [:], completion: {err, results in
                completion(err, results)
            })
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
