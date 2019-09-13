//
//  CacheDirectory.swift
//  Cachable
//
//  Created by aramik on 9/8/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation


// MARK: - Available Cache Directories
extension CachableManager.Storage {

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
