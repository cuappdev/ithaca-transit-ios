//
//  RouteDetailViewController.swift
//  TCAT
//
//  Created by Matthew Barker on 2/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import Pulley

//struct RouteDetailCellSize {
//    static let smallHeight: CGFloat = 60
//    static let largeHeight: CGFloat = 80
//    static let regularWidth: CGFloat = 120
//    static let indentedWidth: CGFloat = 140
//}

class MyPulleyViewController: PulleyViewController {
    
    required init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
        
        customizeSettings()
        formatNavigationController()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func customizeSettings() {
        
        drawerCornerRadius = 16
        shadowOpacity = 0.25
        shadowRadius = 4
        
        backgroundDimmingColor = .clear
        backgroundDimmingOpacity = 1.0
        
        initialDrawerPosition = .partiallyRevealed
        
        guard let routeDetailViewController = primaryContentViewController as? RouteDetailTableViewController
            else { return }
//        guard let routeDetailTableViewController = drawerContentViewController as? RouteDetailTableViewController
//            else { return }
        
        setDefaultCollapsedHeight(to: routeDetailViewController.summaryViewHeight + 40)
        setDefaultPartialRevealHeight(to: (UIScreen.main.bounds.height / 2) - statusNavHeight())
        
    }
    
    /** Return height of status bar and possible navigation controller */
    func statusNavHeight(includingShadow: Bool = false) -> CGFloat {
        
        guard let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
            else { return 0 }
        
        if #available(iOS 11.0, *) {
            
            return navigationController.view.safeAreaInsets.top +
                navigationController.navigationBar.frame.height +
                (includingShadow ? 4 : 0)
            
        } else {
            
            return UIApplication.shared.statusBarFrame.height +
                navigationController.navigationBar.frame.height +
                (includingShadow ? 4 : 0)
            
        }
        
    }
    
    /// MARK: Navigation Controller
    
    /** Set title, buttons, and style of navigation controller */
    func formatNavigationController() {
        
        let otherAttributes = [NSAttributedStringKey.font: UIFont(name :".SFUIText", size: 14)!]
        let titleAttributes: [NSAttributedStringKey: Any] = [.font : UIFont(name :".SFUIText", size: 18)!,
                                                             .foregroundColor : UIColor.black]
        
        // general
        title = "Route Details"
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.backgroundColor = .white
        
        // text and font
        navigationController?.navigationBar.tintColor = .primaryTextColor
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationItem.backBarButtonItem?.setTitleTextAttributes(otherAttributes, for: .normal)
        
        // right button
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(otherAttributes, for: .normal)
        let cancelButton = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(exitAction))
        cancelButton.setTitleTextAttributes(otherAttributes, for: .normal)
        self.navigationItem.setRightBarButton(cancelButton, animated: true)
        
        // back button
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        let attributedString = NSMutableAttributedString(string: "  Back")
        // raise back button text a hair - attention to detail, baby
        attributedString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0.3, range: NSMakeRange(0, attributedString.length))
        backButton.setAttributedTitle(attributedString, for: .normal)
        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        let barButtonBackItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.setLeftBarButton(barButtonBackItem, animated: true)
        
    }
    
    /** Return app to home page */
    @objc func exitAction() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    /** Move back one view controller in navigationController stack */
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }

}
