//
//  CachableRecord.swift
//  Cachable
//
//  Created by aramik on 9/8/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation


/// Used to store data on cached items
internal struct CachableRecord: Codable {

    /// filePath ref for location on disk
    public var filePath: String

    /// Used to retreive and as file name on disk
    public var key: String

    /// The timestamp of when the item was cached
    public var cachedAt: TimeInterval

    /// Number of second this items cache should expire
    public var expireDuration: TimeInterval
}
