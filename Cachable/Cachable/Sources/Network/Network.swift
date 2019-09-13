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

    /// Internal Network Utilities
    public class Network {

        /// shared instance
        public static var shared = Network()

        /// NWPathMonitor used for detecting network status
        private let monitor = NWPathMonitor()

        /// Queue used for monitoring
        private var queue: DispatchQueue!

        /// Start monitor for network changes; Does not take in to account weak signal.  Does not check Reachability / signal strength
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

        /// Stop monitoring for network changes
        public func stopMonitoring() {
            monitor.cancel()
        }

    }
}
