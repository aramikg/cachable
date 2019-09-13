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

        public override var expireDuration: TimeInterval { return 10 }
        public override var cacheKey: String { return "posts-api" }

        public override func fetch(completion: @escaping (([FeedModel]) -> Void)) {
            let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!

            let task = URLSession.shared.dataTask(with: url) {(data, res, error) in
                guard let data = data else { return }
                do {
                    let decoded = try JSONDecoder().decode([FeedModel].self, from: data)
                    completion(decoded)
                } catch {
                    print(error)
                }
            }

            task.resume()
        }

    }
}
