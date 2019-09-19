//
//  Cachable.swift
//  Cachable
//
//  Created by Aramik on 9/11/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation
import Network


/// Create a Cachable object from any object that conforms to Codable.
public class Cachable<T:Codable> {

    /// Used as primary key to reterieve data as well as the file name that will be stored on disk for caching
    public var cacheKey: String { return "CacheKey" }

    /// Number of seconds this object should expire after.
    public var expireDuration: TimeInterval { return 300.0 }

    /// Keeps the expireDuration in sync with the cacheRecord for this item.
    public init() {
        CachableManager.Storage.shared.updateCacheRecordExpireDuration(newExpireDuration: expireDuration, forKey: cacheKey)
    }

    /// Used to reterive data for this cachable item.  If this is a cachable API, your URLRequest would go here. Make sure to call the completion handler when ready.
    ///
    /// - Parameter completion: Used to cache results for this item
    open func fetch(completion: @escaping ((T)->Void)) {

    }

    /// Will check to see if the item exists in cache before using the 'fetch(completion:)' method to get new results.
    ///
    /// - Parameter completion: optional results of the defined generic type
    final func get(completion: @escaping ((T?, CachableManager.CacheStatus)->Void)) {
        do {
            let cachedVersion = try CachableManager.Storage.shared.readFromDisk(readable: T.self, forKey: cacheKey, directory: .caches)
            completion(cachedVersion, .cached)
        } catch {
            fetch { results in
                do {
                    try CachableManager.Storage.shared.writeToDisk(codable: results, forKey: self.cacheKey,  expireDuration: self.expireDuration, directory: .caches)
                    completion(results, .fetched)
                } catch {
                    completion(nil, .none)
                }
            }
        }

    }
}





public class Cache: NSObject, URLSessionDataDelegate {

    public convenience init(directory: CacheDirectory, maxSizeMB: Int) {
        self.init()
        guard let cacheDirectoryPath = directory.url?.path else { return }
        let capacity = maxSizeMB * 1000 * 1000
        URLCache.shared = URLCache.init(memoryCapacity: capacity, diskCapacity: capacity, diskPath: cacheDirectoryPath)
    }

    public func request(request: URLRequest, refreshJwtAccessTokenOnAuthenticationError: Bool = true, completion: @escaping (Data?, URLResponse?, Error?)->Void) {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .useProtocolCachePolicy
     
        let session = URLSession.init(configuration: config, delegate: self, delegateQueue: URLSession.shared.delegateQueue)
        session.dataTask(with: request).resume()
        print(request.expireDuration)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        guard let expireDuration = dataTask.currentRequest?.expireDuration else {
            completionHandler(proposedResponse)
            return
        }

        let newResponse = proposedResponse.response(withExpirationDuration: expireDuration)
        completionHandler(newResponse)
        print("Updated cache time!!!!")
    }
}


extension Cache {
    /// Directory used by Cachable to store data to disk
    public enum CacheDirectory {

        /// Should be used only for data that is user generated and can't be retrieved from server.  These will be sync with iCloud.
        case documents

        /// Should be used for anything that can be retrieved from server. This directory can be wiped clean from Apple at anytime.
        case caches

        /// Returns the specified path url for the directory
        public var url: URL? {
            var searchPathDirectory: FileManager.SearchPathDirectory

            switch self {
            case .documents:
                searchPathDirectory = .documentDirectory
            case .caches:
                searchPathDirectory = .cachesDirectory
            }

            return FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first
        }
    }
}
