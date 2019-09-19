//
//  ViewController.swift
//  Example
//
//  Created by Aramik on 9/10/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let feedAPI = API.Feed.init()

    override func viewDidLoad() {
        super.viewDidLoad()

        CachableManager.Network.shared.startMonitoring()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        feedAPI.get { posts, status in
            print(posts?.count ?? "No Posts")
        }

        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        var request = URLRequest.init(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["last-page-key":"ksjdflk23jlfkjk","jwt":"kj388","other-header":"hello"]
        request.expireDuration = 1000.0
        let cache = Cache.init(directory: .documents, maxSizeMB: 100)
        cache.request(request: request) { (data, response, err) in
            print(data)
        }
    }


}

