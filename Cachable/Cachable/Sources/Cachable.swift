//
//  Cachable.swift
//  Cachable
//
//  Created by Aramik on 9/11/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation
import Network


public class Cachable<T:Codable> {
    public typealias resultType = T

    public var cacheKey: String { return "CacheKey" }
    public var expireDuration: TimeInterval { return 300.0 }

    init() {
        CachableManager.Storage.shared.updateCacheRecordExpireDuration(newExpireDuration: expireDuration, forKey: cacheKey)
        print("cache expire duration updated")
    }

    open func fetch(completion: @escaping ((T)->Void)) {

    }

    final func get(completion: @escaping ((T?)->Void)) {
        print(CachableManager.Network.shared.monitor.currentPath)

  
        do {
            let cachedVersion = try CachableManager.Storage.shared.readFromDisk(readable: resultType.self, forKey: cacheKey, directory: .caches)
            completion(cachedVersion )
        } catch {
            fetch { results in
                do {
                    try CachableManager.Storage.shared.writeToDisk(codable: results, forKey: self.cacheKey,  expireDuration: self.expireDuration, directory: .caches)
                    print("fetching from api")
                    completion(results)
                } catch {
                    print(error)
                    completion(nil)

                }
            }
        }

    }
}
