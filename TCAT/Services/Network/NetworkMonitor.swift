//
//  NetworkMonitor.swift
//  TCAT
//
//  Created by Jayson Hahn on 10/9/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Network
import Foundation

final class NetworkMonitor {

    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection

    public var isCellular: Bool = false
    public var isReachable: Bool { status == .satisfied }

    // Optional handlers for reachability changes
    public var whenReachable: (() -> Void)?
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

    // MARK: - Stop Monitoring
    public func stopMonitoring() {
        monitor.cancel()
    }
}

extension Notification.Name {
    static let reachabilityChanged = Notification.Name("reachabilityChanged")
}
