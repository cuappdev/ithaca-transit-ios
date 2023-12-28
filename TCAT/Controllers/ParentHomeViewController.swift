//
//  ParentHomeViewController.swift
//  TCAT
//
//  Created by Lucy Xu on 11/4/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import AppDevAnnouncements
import Pulley
import UIKit

class ParentHomeMapViewController: PulleyViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Present announcement if there are any new ones to present
        presentAnnouncement { presented in
            if presented {
                TransitAnalytics.shared.log(AnnouncementPresentedPayload())
            }
        }
    }

    required init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
