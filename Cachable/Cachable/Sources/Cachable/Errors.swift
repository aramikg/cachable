//
//  Errors.swift
//  Cachable
//
//  Created by aramik on 9/8/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

extension CachableManager {
    enum Errors: Error {
        /// Couldn't Find file for key in the specified directory
        case fileNotFound

        /// Specified CacheDirectory not found. Possibly running on Simulator
        case directoryNotFound

        /// Failed to decode data reterieved from disk to specified object
        case failedToDecode

        /// Failed to Encode given Codable to data
        case faledToEncode

        /// Failed to save data to disk
        case failedToSave

        /// Failed to read data from disk
        case failedToRead

        /// Found cache but results are empty.
        case noResults

        /// CacheRecord shows that this item should be expired and refetched.
        case cacheRecordExpired
    }
}
