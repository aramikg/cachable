//
//  Logger.swift
//  Cachable
//
//  Created by Aramik on 9/11/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

extension CachableManager {

    /// Internal Logger
    public class Logger {

        /// set to `true` to see all debug print statements
        public static var debug = true

        /// Used Internal to contain all print statments
        ///
        /// - Parameter message: message for debugging
        internal static func log(message: String) {
            guard debug else { return }
            print(message)
        }
    }
}
