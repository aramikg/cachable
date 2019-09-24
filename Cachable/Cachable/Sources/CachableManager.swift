//
//  Cachable.swift
//  Cachable
//
//  Created by aramik on 9/8/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

/// Cachable Manager / Namespace
public class CachableManager {

    /// Shared Instance
    public static var shared = CachableManager()


    public var operationQueue = OperationQueue()
    public var operations = [Operation]()
    
    /// return whether or not Cachable is working in offline mode
    public private(set) static var isOfflineModeEnabled: Bool = false

    /// returns Cachable version
    public static var version: String {
        let bundle = Bundle(identifier: "com.Cachable")
        let dictionary = bundle?.infoDictionary
        let version = dictionary?["CFBundleShortVersionString"] as! String
        let build = dictionary?["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }

    /// Enabling offline mode will return cached data even if it's expired.
    ///
    /// - Parameter enabled: set to true to enable offline mode
    public static func setOfflineMode(enabled: Bool) {
        isOfflineModeEnabled = enabled
    }

    
    public func fetch(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard request.httpMethod != "POST" else {
            networkRequest(request: request, completion: completion)
            return
        }

        do {
            let data = try getDataFor(request: request)
            completion(data, nil, nil)
        } catch {
            networkRequest(request: request, completion: completion)
        }
    }

    private func networkRequest(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let operation = CacheRequestOperation.init(withRequest: request) { (requestData, response, err) in
            if request.httpMethod == "GET", let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 400, let data = requestData {
               do {
                   try Storage.shared.writeToDisk(data: data , forKey: request.uuid, expireDuration: request.expireDuration, directory: .documents)
                } catch {
                    print(error)
                    completion(nil, nil, nil)
                    return
                }
            } else {
                Storage.shared.updateCacheRecordLastAction(lastActionTimestamp: Date().timeIntervalSince1970, forKey: request.uuid)
            }
            completion(requestData, response, err)
        }
        operationQueue.addOperation(operation)
    }

    public func getDataFor(request: URLRequest) throws -> Data? {
        do {
            let data = try Storage.shared.readFromDisk(request: request, directory: .documents)
            return data
        } catch {
            throw error
        }
    }



}


