//
//  Cachable.swift
//  Cachable
//
//  Created by aramik on 9/8/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

public class CachableManager {
    public static var shared = CachableManager()

    public private(set) static var isOfflineModeEnabled: Bool = false

    public static var version: String {
        let bundle = Bundle(identifier: "ag.Cachable")
        let dictionary = bundle?.infoDictionary
        let version = dictionary?["CFBundleShortVersionString"] as! String
        let build = dictionary?["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }

    public static func setOfflineMode(enabled: Bool) {
        isOfflineModeEnabled = enabled
        print("Offline mode: \(enabled)")
    }

}
