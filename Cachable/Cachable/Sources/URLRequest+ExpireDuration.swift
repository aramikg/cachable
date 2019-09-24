//
//  URLRequest+ExpireDuration.swift
//  Cachable
//
//  Created by Aramik on 9/17/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

extension URLRequest {

    struct Container {
        static var expireDuartion = TimeInterval.init(exactly: 0)
    }

    var expireDuration: TimeInterval {
        get {
            return Container.expireDuartion ?? 0
        }

        set(newValue) {
             Container.expireDuartion = newValue
        }
    }

    var uuid: String {
        var id = self.url?.absoluteString ?? ""

        if let headers = self.allHTTPHeaderFields {
            let headersArray = headers.compactMap { "\($0.value)" }
            let sortedHeaders = headersArray.sorted { $0 < $1 }
            let headersString = sortedHeaders.joined(separator: "-")
            id.append("-\(headersString)")
        }

        id = id.replacingOccurrences(of: "https://", with: "")
        id = id.replacingOccurrences(of: "/", with: "-")
        id = id.replacingOccurrences(of: ".", with: "-")
        return id
    }

}
