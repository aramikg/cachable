//
//  Network.swift
//  Cachable
//
//  Created by Aramik on 9/12/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation
import Network


extension CachableManager {



    public class Network {
        public static var shared = Network()


        public let monitor = NWPathMonitor()
        public var endpoint: NWConnection!
        public var queue: DispatchQueue!


        public func startMonitoring() {



            monitor.pathUpdateHandler = { path in
                switch path.status {
                case .requiresConnection:
                    print("Requires Connection")
                case .satisfied:
                    print("Satisfied Connection")
                    CachableManager.setOfflineMode(enabled: false)
                case .unsatisfied:
                    print("Unsatisfied Connection")
                    CachableManager.setOfflineMode(enabled: true)
                @unknown default:
                    print("unknown case")
                }
            }

            queue = DispatchQueue(label: "Monitor")
            monitor.start(queue: queue)


        }
    }
}
