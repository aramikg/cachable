//
//  ViewController.swift
//  Example
//
//  Created by Aramik on 9/10/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        CachableManager.Network.shared.startMonitoring()
        try? CachableManager.Storage.shared.removeAllCache()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print( CachableManager.shared.operationQueue.operationCount)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        var request = URLRequest.init(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["last-page-key":"ksjdflk23jlfkjk","jwt":"kj388","other-header":"hello"]
        request.expireDuration = 10.0

        CachableManager.shared.fetch(request: request) { (data, response, err) in
            guard err == nil else { print(err?.localizedDescription ?? "Error"); return }
            print(String(describing: data), CachableManager.shared.operationQueue.operationCount)
        }

    

    }


}

