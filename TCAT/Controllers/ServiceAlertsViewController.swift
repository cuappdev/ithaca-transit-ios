//
//  ServiceAlertsViewController.swift
//  TCAT
//
//  Created by Omar Rasheed on 10/23/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit
import SnapKit
import DZNEmptyDataSet

class ServiceAlertsViewController: UIViewController {
    
    var tableView: UITableView!
    var alerts = [Alert]()
    var prioritySections: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .tableBackgroundColor

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        tableView.separatorColor = .lineDotColor
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
        
        updateConstraints()
    }
    
    func updateConstraints() {
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func getServiceAlerts() {
        Network.getAlerts().perform(withSuccess: { (request) in
            if (request.success) {
                for alert in request.data {
                    self.alerts.append(alert)
                }
                
            }
        }) { (error) in
            print(error)
        }
    }
    
    func filterAlertPriorities() {
        
    }
}

extension ServiceAlertsViewController: DZNEmptyDataSetSource {
    
}

extension ServiceAlertsViewController: DZNEmptyDataSetDelegate {
    
}

extension ServiceAlertsViewController: UITableViewDelegate {
    
}

extension ServiceAlertsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return prioritySections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
