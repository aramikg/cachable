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
    }


}

