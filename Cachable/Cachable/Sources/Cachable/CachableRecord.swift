//
//  CachableRecord.swift
//  Cachable
//
//  Created by aramik on 9/8/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

public struct CachableRecord: Codable {
    public var filePath: String
    public var key: String
    public var cachedAt: TimeInterval
    public var expireDuration: TimeInterval
}
