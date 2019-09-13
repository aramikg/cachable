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
