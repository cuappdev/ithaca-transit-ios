//
//  RouteDetailViewController.swift
//  TCAT
//
//  Created by Matthew Barker on 2/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import Pulley

class RouteDetailViewController: PulleyViewController {
    
    required init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = "Route Details"
        
        drawerCornerRadius = 16
        shadowOpacity = 0.25
        shadowRadius = 4
        backgroundDimmingColor = .black
        backgroundDimmingOpacity = 0.5
        animationDuration = 0.5
        animationSpringDamping = 0.8
        animationSpringInitialVelocity = 2.5
        
        let threshold: CGFloat = 20
        //snapMode = .nearestPositionUnlessExceeded(threshold: threshold)
        
        setRightButton()
        
    }
    
    // MARK: Navigation Controller
    
    /// Set the right button in the navigation controller
    func setRightButton() {
        guard let buttonAttributes = (navigationController as? CustomNavigationController)?.buttonTitleTextAttributes
            else { return }
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(buttonAttributes, for: .normal)
        let button = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(exitAction))
        button.setTitleTextAttributes(buttonAttributes, for: .normal)
        self.navigationItem.setRightBarButton(button, animated: true)
    }
    
    /// Return app to home page
    @objc func exitAction() {
        navigationController?.popToRootViewController(animated: true)
    }

}
