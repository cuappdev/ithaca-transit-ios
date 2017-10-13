//
//  OnboardPageViewController.swift
//  TCAT
//
//  Created by Matthew Barker on 9/20/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class OnboardViewController: UIViewController, OnboardingDelegate {
    
    let controllers: [ActionOnboardViewController] = [
        
        ActionOnboardViewController(type: .welcome),
        ActionOnboardViewController(type: .locationServices)
        
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controller = controllers.first!
        controller.view.bounds = view.bounds
        controller.onboardingDelegate = self
        addChildViewController(controller)
        view.addSubview(controller.view)
        didMove(toParentViewController: controller)
    }
    
    func moveToNextViewController(vc: ActionOnboardViewController) {
        let controller = controllers[1]
        addChildViewController(controller)
        vc.navigationController?.pushViewController(controller, animated: true)
        didMove(toParentViewController: controller)
        vc.removeFromParentViewController()
    }
    
}

