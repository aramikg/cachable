//
//  URLRequest+ExpireDuration.swift
//  Cachable
//
//  Created by Aramik on 9/17/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation


extension URLRequest {

    private struct ExpireDuration {
        static var Key: UInt8 = 0
    }

    var expireDuration: TimeInterval? {
        get {
            return objc_getAssociatedObject(self, &ExpireDuration.Key) as? Double
        }

        set(newValue) {
            objc_setAssociatedObject(self, &ExpireDuration.Key, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}
