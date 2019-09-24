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


        /// Used to monitor network status changes. Called after Cache is set to offline mode.
        public var listener: ((NWPath.Status) -> Void)?

        /// NWPathMonitor used for detecting network status
        private let monitor = NWPathMonitor()

        /// Queue used for monitoring
        private var queue: DispatchQueue!

        /// Start monitor for network changes; Does not take in to account weak signal.  Does not check Reachability / signal strength
        public func startMonitoring(listener: ((NWPath.Status) -> Void)? = nil) {
            Network.shared.listener = listener

            monitor.pathUpdateHandler = { path in
                switch path.status {
                case .requiresConnection:
                    CachableManager.setOfflineMode(enabled: true)
                case .satisfied:
                    CachableManager.setOfflineMode(enabled: false)
                case .unsatisfied:
                    CachableManager.setOfflineMode(enabled: true)
                @unknown default:
                    Logger.log(message: "unknown case")
                }

                Network.shared.listener?(path.status)
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
