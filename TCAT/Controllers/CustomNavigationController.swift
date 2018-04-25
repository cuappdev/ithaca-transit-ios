//
//  RouteDetailViewController.swift
//  TCAT
//
//  Created by Matthew Barker on 2/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    let additionalWidth: CGFloat = 30
    let additionalHeight: CGFloat = 100
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        view.backgroundColor = .white
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
    static let buttonTitleTextAttributes = [
        NSAttributedStringKey.font : UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 14)!
    ]
    
    func customizeAppearance() {
        
        navigationBar.backgroundColor = .white
        navigationBar.barTintColor = .white
        navigationBar.tintColor = .primaryTextColor
        navigationBar.titleTextAttributes = titleTextAttributes
        navigationItem.backBarButtonItem?.setTitleTextAttributes(
            CustomNavigationController.buttonTitleTextAttributes, for: .normal
        )
        
        // Saved from other view controllers in case needed
        // navigationBar.isTranslucent = false
        // navigationBar.setBackgroundImage(UIImage(), for: .default)
        // navigationBar.shadowImage = UIImage()
        
    }
    
    /// Return an instance of custom back button
    func customBackButton() -> UIBarButtonItem {
        
        let backButton = UIButton()
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.tintColor = .primaryTextColor
        
        let attributes: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.font : UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 14.0)!,
            NSAttributedStringKey.foregroundColor : UIColor.primaryTextColor,
            NSAttributedStringKey.baselineOffset : 0.3
        ]
        let attributedString = NSMutableAttributedString(string: "  Back", attributes: attributes)
        backButton.setAttributedTitle(attributedString, for: .normal)
        
        backButton.sizeToFit()
        
        // Expand frame to create bigger touch area
        backButton.frame = CGRect(x: backButton.frame.minX, y: backButton.frame.minY, width: backButton.frame.width + additionalWidth, height: backButton.frame.height + additionalHeight)
        backButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, additionalWidth)
        
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

class OnboardingNavigationController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
}

