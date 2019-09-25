//
//  CacheRequestOperation.swift
//  Cachable
//
//  Created by Aramik on 9/19/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation

public class CacheRequestOperation: Operation {

    private var request: URLRequest!
    private var requestTask: URLSessionDataTask?
    private var session: URLSession?
    private var requestCompletionHandler: (Data?, URLResponse?, Error?) -> Void

    public override var isAsynchronous: Bool { return true }
    public override var isExecuting: Bool { return state == .executing }
    public override var isFinished: Bool { return state == .finished }

    private var state = State.ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }

    public init(withRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        session = URLSession.shared
        request = withRequest
        requestCompletionHandler = completionHandler
        super.init()
    }

    public override func start() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .ready
            main()
        }

        requestTask = session?.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard error == nil else {
                return
            }
            guard let self = self else { return }
            self.requestCompletionHandler(data, response, error)
            self.state = .finished
        })
        requestTask?.resume()
    }

    public override func main() {
         if self.isCancelled {
           state = .finished
        } else {
           state = .executing
        }
    }

    public override func cancel() {
        requestTask?.cancel()
        session?.invalidateAndCancel()
        request = nil
        requestTask = nil
        session = nil
        super.cancel()
    }
    
}


extension CacheRequestOperation {
    enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        fileprivate var keyPath: String { return "is" + self.rawValue }
    }
}
