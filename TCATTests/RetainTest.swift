//
//  RetainTest.swift
//  TCATTests
//
//  Created by Daniel Vebman on 11/10/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import Foundation
import UIKit

class TestRetainVC: UIViewController {
    let v = UIView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        TestManager.shared.addListener(self) { [weak self] (s) in
            self?.v.backgroundColor = .red
            print("Recevied " + s)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TestManager {
    
    static let shared = TestManager()
    
    private var listeners: [Pair] = []
    
    private struct Pair {
        weak var listener: Listener?
        var closure: Closure
    }
    typealias Listener = AnyObject
    typealias Closure = (String) -> ()
    
    func addListener(_ listener: Listener, _ closure: @escaping Closure) {
        listeners.append(Pair(listener: listener, closure: closure))
    }
    
    func fire(_ s: String) {
        listeners = listeners.filter { pair -> Bool in
            pair.closure(s)
            return pair.listener != nil
        }
        
        print("*", listeners)
    }
    
}
