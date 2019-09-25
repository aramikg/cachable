//
//  CachableRecord.swift
//  Cachable
//
//  Created by aramik on 9/8/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

internal protocol CacheRecord {
    var filePath: String  { get set }
    var key: String { get set }
    var cachedAt: TimeInterval { get set }
    var lastUsed: TimeInterval { get set }
    var expireDuration: TimeInterval { get set }
    var lastActionTime: TimeInterval { get set }
}

/// Used to store data on cached items
internal struct CachableRecord: Codable, CacheRecord {

    /// filePath ref for location on disk
    public var filePath: String

    /// Used to retreive and as file name on disk
    public var key: String

    /// The timestamp of when the item was cached
    public var cachedAt: TimeInterval

    /// The timestamp of the last time this record was read
    public var lastUsed: TimeInterval

    /// Number of second this items cache should expire
    public var expireDuration: TimeInterval

    /// Last time user modified this record
    public var lastActionTime: TimeInterval
}
