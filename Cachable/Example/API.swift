//
//  API.swift
//  Example
//
//  Created by Aramik on 9/12/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

public class API { }


extension API {
    public class Feed: Cachable<[FeedModel]> {

        public override var expireDuration: TimeInterval { return 1 }
        public override var cacheKey: String { return "posts-api" }

        public override func fetch(completion: @escaping (([FeedModel]) -> Void)) {
            let url = URL(string: "https://jsonplaceholder.typicode.com/post")!

            var request = URLRequest.init(url: url)
            request.allHTTPHeaderFields = ["last-page-key":"ksjdflk23jlfkjk","jwt":"kj388","other-header":"hello"]

            let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
                guard let data = data else { return }
                do {
                    let decoded = try JSONDecoder().decode([FeedModel].self, from: data)
                    completion(decoded)
                } catch {
                    print(error)
                }
            }

            let t = URLSession.shared.dataTask(with: request)

            let req = URLSession.shared.delegate

            task.resume()
          
        }

    }
}



extension URLRequest {

    struct Container {
        static var expireDuartion = TimeInterval.init(exactly: 0)
    }


    var expireDuration: TimeInterval? {
        get {
            return Container.expireDuartion
        }

        set(newValue) {
            if let timeInterval = newValue {
                Container.expireDuartion = timeInterval
            }
        }
    }


    var uuid: String {
        var id = self.url?.absoluteString ?? ""

        if let headers = self.allHTTPHeaderFields {
            let headersArray = headers.compactMap { "\($0.value)" }
            let headersString = headersArray.joined(separator: "--")
            id.append("--\(headersString)")
        }

        return id
    }

  

}
