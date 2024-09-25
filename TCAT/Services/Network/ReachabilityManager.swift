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
    private var listeners: [Pair] = []

    typealias Listener = AnyObject
    typealias Closure = (Reachability.Connection) -> Void

    private struct Pair {
        weak var listener: Listener?
        var closure: Closure
    }

    override private init() {
        super.init()

        do {
            try reachability?.startNotifier()
        } catch {
            print("[ReachabilityManager] init: Could not start reachability notifier.")
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
    }

    /// Adds a listener to reachability updates.
    /// Reminder: Be sure to begin the closure with `[weak self]`.
    func addListener(_ listener: Listener, _ closure: @escaping Closure) {
        listeners.append(Pair(listener: listener, closure: closure))
    }

    @objc func reachabilityChanged(_ notification: Notification) {
        guard let reachability = reachability else { return }
        listeners = listeners.filter { pair -> Bool in
            pair.closure(reachability.connection) // call the closures
            return pair.listener != nil // remove closures for deinitialized listeners
        }
    }

}
