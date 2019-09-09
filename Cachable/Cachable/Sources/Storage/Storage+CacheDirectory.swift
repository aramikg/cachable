//
//  CacheDirectory.swift
//  Cachable
//
//  Created by aramik on 9/8/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

extension Cachable.Storage {
    public enum CacheDirectory {
        case documents
        case caches

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
