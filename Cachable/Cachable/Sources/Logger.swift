//
//  Logger.swift
//  Cachable
//
//  Created by Aramik on 9/11/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

extension CachableManager {
    public class Logger {
        public static var debug = true

        public static func log(message: String) {
            guard debug else { return }
            print(message)
        }
    }
}
