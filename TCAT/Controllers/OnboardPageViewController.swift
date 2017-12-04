//
//  OnboardPageViewController.swift
//  TCAT
//
//  Created by Matthew Barker on 9/20/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class OnboardViewController: UIViewController, OnboardingDelegate {

    var page = 0
    
    let controllers: [ActionOnboardViewController] = [
        
        ActionOnboardViewController(type: .welcome),
        ActionOnboardViewController(type: .tracking),
        ActionOnboardViewController(type: .destination),
        ActionOnboardViewController(type: .locationServices)
        //ActionOnboardViewController(type: .favorites)
        
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
        page += 1
    }
    
    func moveToNextViewController(vc: ActionOnboardViewController) {
        let controller = controllers[page]
        controller.onboardingDelegate = self
        addChildViewController(controller)
        vc.navigationController?.pushViewController(controller, animated: true)
        didMove(toParentViewController: controller)
        vc.removeFromParentViewController()
        page += 1
    }
    
}

