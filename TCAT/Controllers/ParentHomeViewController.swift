//
//  ParentHomeViewController.swift
//  TCAT
//
//  Created by Lucy Xu on 11/4/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit
import Pulley

class ParentHomeMapViewController: PulleyViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    required init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
