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

    public struct RequestData {
        init(fromData: Data?) throws { guard fromData != nil else { throw Errors.failedToDecode }}
    }

    typealias RequestBuilder = () throws -> RequestData

    
    /// return whether or not Cachable is working in offline mode
    public private(set) static var isOfflineModeEnabled: Bool = false

    /// returns Cachable version
    public static var version: String {
        let bundle = Bundle(identifier: "a4c.Cachable")
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

    public static func fetch(request: URLRequest, completion: @escaping (RequestData) -> Void) {
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            if data != nil {
                let newData = try RequestData.init(fromData: data)
                completion(newData)
            }

            }.resume()
    }

    public static func getDataFor(request: URLRequest) throws -> Data? {
        do {
            let data = try Storage.shared.readFromDisk(request: request)
            return data
        } catch {
            throw error
        }
    }

    public static func getFromServer(request: URLRequest) throws -> Data? {

    }

}


