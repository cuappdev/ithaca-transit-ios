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

    /// True if view is being peeked from Route Options
    var isPeeking: Bool = false

    override func viewDidLoad() {

        super.viewDidLoad()

        title = Constants.Titles.routeDetails

        drawerCornerRadius = 16
        shadowOpacity = 0.25
        shadowRadius = 4
        backgroundDimmingColor = .black
        backgroundDimmingOpacity = 0.5
        animationDuration = 0.5
        animationSpringDamping = 0.8
        animationSpringInitialVelocity = 2.5

        let threshold: CGFloat = 20
        snapMode = .nearestPositionUnlessExceeded(threshold: threshold)

        // Set left back button
        navigationItem.leftBarButtonItem?.setTitleTextAttributes(
            CustomNavigationController.buttonTitleTextAttributes, for: .normal
        )

    }

    /// 3D Touch Peep Pop Action(s)
    override var previewActionItems: [UIPreviewActionItem] {

        let shareAction = UIPreviewAction(title: Constants.Actions.share, style: .default, handler: { (_, viewController) -> Void in

            guard
                let routeDetailViewController = viewController as? RouteDetailViewController,
                let contentViewController = routeDetailViewController.primaryContentViewController as? RouteDetailContentViewController
            else {
                return
            }

            contentViewController.shareRoute()

        })

        return [shareAction]

    }

    // MARK: Initializers

    required init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
