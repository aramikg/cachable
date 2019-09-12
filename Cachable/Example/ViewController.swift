//
//  ViewController.swift
//  Example
//
//  Created by Aramik on 9/10/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import UIKit

public struct PostModel: Codable {
    var userId: Int
    var id: Int
    var title: String
    var body: String
}


public class PostsAPI: Cachable<[PostModel]> {

    public typealias resultType = [String]
    public override var expireDuration: TimeInterval { return 10 }
    public override var cacheKey: String { return "posts-api" }
    



    public override func fetch(completion: @escaping (([PostModel]) -> Void)) {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!

        let task = URLSession.shared.dataTask(with: url) {(data, res, error) in
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode([PostModel].self, from: data)
                completion(decoded)
            } catch {
                print(error)
            }
        }

        task.resume()
    }

}

class ViewController: UIViewController {

    let postsAPI = PostsAPI()

    override func viewDidLoad() {
        super.viewDidLoad()

        CachableManager.Network.shared.startMonitoring()
        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        postsAPI.get { (results) in
            print(results?.count)
        }
    }


}

