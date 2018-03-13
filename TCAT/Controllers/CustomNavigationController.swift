//
//  RouteDetailViewController.swift
//  TCAT
//
//  Created by Matthew Barker on 2/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        view.backgroundColor = .white // for demo
        customizeAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            interactivePopGestureRecognizer?.delegate = self
            delegate = self
        }
    }
    
    /// Attributed string details for the title text of a navigation controller
    let titleTextAttributes: [NSAttributedStringKey: Any] = [
        .font : UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 18)!,
        .foregroundColor : UIColor.black
    ]
    
    /// Attributed string details for the back button text of a navigation controller
    let buttonTitleTextAttributes = [
        NSAttributedStringKey.font : UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 14)!
    ]
    
    func customizeAppearance() {
        
        navigationBar.backgroundColor = .white
        navigationBar.barTintColor = .white
        navigationBar.tintColor = .primaryTextColor
        navigationBar.titleTextAttributes = titleTextAttributes
        navigationItem.backBarButtonItem?.setTitleTextAttributes(buttonTitleTextAttributes, for: .normal)
        
        // Saved from other view controllers in case needed
        // navigationBar.isTranslucent = false
        // navigationBar.setBackgroundImage(UIImage(), for: .default)
        // navigationBar.shadowImage = UIImage()
        
    }
    
    /// Return an instance of custom back button
    func customBackButton() -> UIBarButtonItem {
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        let attributedString = NSMutableAttributedString(string: "  Back")
        
        // raise back button text a hair - attention to detail, baby
        attributedString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0.3, range: NSMakeRange(0, attributedString.length))
        
        backButton.setAttributedTitle(attributedString, for: .normal)
        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return UIBarButtonItem(customView: backButton)
        
    }
    
    /** Move back one view controller in navigationController stack */
    @objc func backAction() {
        _ = popViewController(animated: true)
    }
    
    // MARK: UINavigationController Functions
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            interactivePopGestureRecognizer?.isEnabled = false
        }

        super.pushViewController(viewController, animated: animated)
        
        if viewControllers.count > 1 {
            
            navigationBar.titleTextAttributes = titleTextAttributes
            
            // Add back button for non-modal non-peeked screens
        
            if !viewController.isModal {
                viewController.navigationItem.hidesBackButton = true
                viewController.navigationItem.setLeftBarButton(customBackButton(), animated: true)
            }
            
        }
        
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        
        let viewController = super.popViewController(animated: animated)
        if viewControllers.last is HomeViewController {
            viewControllers.last!.navigationItem.leftBarButtonItem = nil
        }
        return viewController
        
    }
    
    // MARK: UINavigationControllerDelegate Functions
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        interactivePopGestureRecognizer?.isEnabled = (responds(to: #selector(getter: interactivePopGestureRecognizer)) && viewControllers.count > 1)
    }

}

