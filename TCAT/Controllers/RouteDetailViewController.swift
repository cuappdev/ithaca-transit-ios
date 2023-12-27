//
//  RouteDetailViewController.swift
//  TCAT
//
//  Created by Matthew Barker on 2/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Pulley
import UIKit

class RouteDetailViewController: PulleyViewController {

    override func viewDidLoad() {

        super.viewDidLoad()

        title = Constants.Titles.routeDetails

        drawerCornerRadius = 16
        shadowOpacity = 0.25
        shadowRadius = 4
        backgroundDimmingColor = Colors.black
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
        let shareAction = UIPreviewAction(
            title: Constants.Buttons.share,
            style: .default,
            handler: { _, viewController in
                guard let routeDetailViewController = viewController as? RouteDetailViewController,
                      // swiftlint:disable:next line_length
                      let contentViewController = routeDetailViewController.primaryContentViewController as? RouteDetailContentViewController else {
                    return
                }

                contentViewController.shareRoute()
            }
        )

        return [shareAction]

    }

    // MARK: - Initializers

    required init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
