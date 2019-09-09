//
//  Cachable.swift
//  Cachable
//
//  Created by aramik on 9/8/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

public class Cachable {
    public static var shared = Cachable()

    public static var version: String {
        let bundle = Bundle(identifier: "ag.Cachable")
        let dictionary = bundle?.infoDictionary
        let version = dictionary?["CFBundleShortVersionString"] as! String
        let build = dictionary?["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
}
