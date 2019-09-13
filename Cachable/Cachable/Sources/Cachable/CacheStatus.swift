//
//  CacheStatus.swift
//  Cachable
//
//  Created by Aramik on 9/12/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

extension CachableManager {

    /// Determines how/where the data was reterived from
    public enum CacheStatus {
        /// Uncached, requested from the custom 'fetch(completion:)' function
        case fetched

        /// Data from non-expired cache result if not in offline mode; other wise could be from expired cache.
        case cached

        /// Something went wrong, there are no results so no status either
        case none
    }
}
