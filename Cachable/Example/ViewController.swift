//
//  ViewController.swift
//  Example
//
//  Created by Aramik on 9/10/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var getPosts: UIButton!
    @IBOutlet var removeAllCacheButton: UIButton!
    @IBOutlet var removeUnusedCacheButton: UIButton!
    @IBOutlet var removeExpiredCacheButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        CachableManager.Network.shared.startMonitoring()
    }

    @IBAction func getPosts(sender: UIButton) {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        var request = URLRequest.init(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["last-page-key":"ksjdflk23jlfkjk","jwt":"kj388","other-header":"hello"]
        request.expireDuration = 10.0

        CachableManager.shared.fetch(request: request) { (data, response, err) in
            guard err == nil else { print(err?.localizedDescription ?? "Error"); return }
            print(data ?? "No Data")
            self.removeAllCacheButton.setEnabled(enabled: true)
            self.removeUnusedCacheButton.setEnabled(enabled: true)
            self.removeExpiredCacheButton.setEnabled(enabled: true)
        }
    }

    @IBAction func removeExpireCache(sender: UIButton) {
        do {
            try CachableManager.Storage.shared.removeExpiredCache()
            sender.setEnabled(enabled: false)
        } catch {
            sender.setEnabled(enabled: true)
        }
    }

    @IBAction func removeAllCache(sender: UIButton) {
        do {
            try CachableManager.Storage.shared.removeAllCache()
            sender.setEnabled(enabled: false)
        } catch {
            sender.setEnabled(enabled: true)
        }
    }

    @IBAction func removeUnusedCache(sender: UIButton) {
        do {
            try CachableManager.Storage.shared.removeUnusedCache()
            sender.setEnabled(enabled: false)
        } catch {
            sender.setEnabled(enabled: true)
        }
    }

}


extension UIButton {
    func setEnabled(enabled : Bool) {
        DispatchQueue.main.async {
            self.isEnabled = enabled
        }
    }
}
