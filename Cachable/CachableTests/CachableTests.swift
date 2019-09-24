//
//  CachableTests.swift
//  CachableTests
//
//  Created by aramik on 9/8/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import XCTest
@testable import Cachable


class CachableTests: XCTestCase {



    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
         print("Cachable version: \(CachableManager.version)")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testSaveRequest() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        var request = URLRequest.init(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["last-page-key":"ksjdflk23jlfkjk","jwt":"kj388","other-header":"hello"]
        request.expireDuration = 1000.0

        let expectation = self.expectation(description: "Network Call")
        CachableManager.shared.fetch(request: request) { (data, response, err) in
            guard err == nil else { print(err?.localizedDescription ?? "Error"); return }
            print(request.uuid)

            let saved = CachableManager.Storage.shared.fileExists(forKey: request.uuid, usingDirectory: .documents)
            
            XCTAssert(saved)
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}





