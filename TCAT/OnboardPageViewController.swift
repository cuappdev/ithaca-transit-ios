//
//  OnboardPageViewController.swift
//  TCAT
//
//  Created by Matthew Barker on 9/20/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class OnboardPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let controllers: [UIViewController] = [
        
        ActionOnboardViewController(type: .welcome),
        ActionOnboardViewController(type: .locationServices)
        
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        let appearance = UIPageControl.appearance()
        appearance.backgroundColor = .white
        appearance.pageIndicatorTintColor = .lightGray
        appearance.currentPageIndicatorTintColor = .darkGray
        
        for view in self.view.subviews {
            if view is UIPageControl { view.backgroundColor = .clear }
        }
        
        setViewControllers([controllers.first!], direction: .forward, animated: true)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard var index = controllers.index(of: viewController)
            else { return nil }
        if index == 0 { return nil }
        index -= 1
        return controllers[index]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var index = controllers.index(of: viewController)
            else { return nil }
        if index == controllers.count - 1 { return nil }
        index += 1
        return controllers[index]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return controllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}

