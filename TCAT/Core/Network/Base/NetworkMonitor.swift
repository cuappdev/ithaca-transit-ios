//
//  NetworkMonitor.swift
//  TCAT
//
//  Created by Jayson Hahn on 10/9/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Network
import Foundation

/// A singleton class that monitors the network status using `NWPathMonitor`.
final class NetworkMonitor {

    /// The shared instance of `NetworkMonitor`.
    static let shared = NetworkMonitor()

    /// A network path monitor that observes changes in network status.
    /// This instance is used to monitor the network connectivity status of the device.
    private let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection

    /// Indicates whether the current connection is cellular.
    public var isCellular: Bool = false

    /// Indicates whether the network is reachable.
    public var isReachable: Bool { status == .satisfied }

    /// Optional handler that gets called when the network becomes reachable.
    public var whenReachable: (() -> Void)?

    /// Optional handler that gets called when the network becomes unreachable.
    public var whenUnreachable: (() -> Void)?

    private init() {}

    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            self?.isCellular = path.isExpensive

            // Notify handlers and observers based on connection status
            if path.status == .satisfied {
                print("Connected to the network.")
                self?.whenReachable?()
                NotificationCenter.default.post(name: .reachabilityChanged, object: self)
            } else {
                print("No network connection.")
                self?.whenUnreachable?()
                NotificationCenter.default.post(name: .reachabilityChanged, object: self)
            }

            if path.usesInterfaceType(.wifi) {
                print("We're connected over Wifi!")
            } else if path.usesInterfaceType(.cellular) {
                print("We're connected over Cellular!")
            } else {
                print("We're connected over other network!")
            }
        }

        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)
    }

    /// Stops monitoring the network status.
    public func stopMonitoring() {
        monitor.cancel()
    }
}

extension Notification.Name {
    /// Notification name for reachability changes.
    static let reachabilityChanged = Notification.Name("reachabilityChanged")
}
