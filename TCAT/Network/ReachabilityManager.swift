//
//  ReachabilityManager.swift
//  TCAT
//
//  Created by Daniel Vebman on 11/6/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import Foundation

class ReachabilityManager: NSObject {
    static let shared: ReachabilityManager = ReachabilityManager()
    
    private let reachability = Reachability()
    
    typealias Listener = (Reachability.Connection) -> ()
    private var listeners: [Listener] = []
    
    private override init() {
        super.init()
        
        do {
            try reachability?.startNotifier()
        } catch {
            printClass(context: "\(#function)", message: "Could not start reachability notifier.")
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
    }
    
    func addListener(_ listener: @escaping Listener) {
        listeners.append(listener)
    }
    
    @objc func reachabilityChanged(_ notification: Notification) {
        guard let reachability = reachability else { return }
        listeners.forEach { $0(reachability.connection) }
    }
    
}
