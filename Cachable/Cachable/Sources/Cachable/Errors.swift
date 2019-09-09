//
//  Errors.swift
//  Cachable
//
//  Created by aramik on 9/8/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

extension Cachable {
    enum Errors: Error {
        case fileNotFound
        case directoryNotFound
        case failedToDecode
        case faledToEncode
        case failedToSave
        case failedToRead
        case noResults
        case cacheRecordExpired
    }
}
