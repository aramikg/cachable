//
//  CachedURLResponse+ExpireDuration.swift
//  Cachable
//
//  Created by Aramik on 9/17/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

extension CachedURLResponse {
    func response(withExpirationDuration duration: TimeInterval) -> CachedURLResponse {
        var cachedResponse = self
        if let httpResponse = cachedResponse.response as? HTTPURLResponse, var headers = httpResponse.allHeaderFields as? [String : String], let url = httpResponse.url{
            headers["Cache-Control"] = "max-age=\(duration)"
            headers.removeValue(forKey: "Expires")
            headers.removeValue(forKey: "s-maxage")

            if let updatedResponse = HTTPURLResponse(url: url, statusCode: httpResponse.statusCode, httpVersion: "HTTP/1.1", headerFields: headers) {
                cachedResponse = CachedURLResponse.init(response: updatedResponse, data: cachedResponse.data, userInfo: headers, storagePolicy: cachedResponse.storagePolicy)
            }
            
             
        }
        return cachedResponse
    }
}
