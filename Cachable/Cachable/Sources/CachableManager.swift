//
//  Cachable.swift
//  Cachable
//
//  Created by aramik on 9/8/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

/// Cachable Manager / Namespace
public class CachableManager {

    /// Shared Instance
    public static var shared = CachableManager()
    
    /// return whether or not Cachable is working in offline mode
    public private(set) static var isOfflineModeEnabled: Bool = false

    /// returns Cachable version
    public static var version: String {
        let bundle = Bundle(identifier: "a4c.Cachable")
        let dictionary = bundle?.infoDictionary
        let version = dictionary?["CFBundleShortVersionString"] as! String
        let build = dictionary?["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }

    /// Enabling offline mode will return cached data even if it's expired.
    ///
    /// - Parameter enabled: set to true to enable offline mode
    public static func setOfflineMode(enabled: Bool) {
        isOfflineModeEnabled = enabled
    }

}
