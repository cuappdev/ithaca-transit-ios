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
    
    var alerts = [Int: [Alert]]()
    var priorities = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Service Alerts"
        
        view.backgroundColor = Colors.backgroundWash
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = view.backgroundColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ServiceAlertTableViewCell.self, forCellReuseIdentifier: ServiceAlertTableViewCell.identifier)
        tableView.allowsSelection = false
        
        tableView.separatorColor = Colors.dividerTextField
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
        
        updateConstraints()
        
        createDummyData()
    }
    
    func updateConstraints() {
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview().offset(view.layoutMargins.top)
            }
        }
    }
    
    func getServiceAlerts() {
        Network.getAlerts().perform(withSuccess: { (request) in
            if (request.success) {
                self.alerts = self.sortedAlerts(alertsList: request.data)
                self.tableView.reloadData()
            }
        }) { (error) in
            print(error)
        }
    }
    
    func sortedAlerts(alertsList: [Alert]) -> [Int: [Alert]] {
        var sortedAlerts = [Int: [Alert]]()
        for alert in alertsList {
            if var alertsAtPriority = sortedAlerts[alert.priority] {
                alertsAtPriority.append(alert)
                sortedAlerts[alert.priority] = alertsAtPriority
            } else {
                priorities.append(alert.priority)
                sortedAlerts[alert.priority] = [alert]
            }
        }
        priorities.sort()
        priorities.reverse()
        
        return sortedAlerts
    }
    
    func createDummyData() {
        
        let fileUrl = Bundle.main.url(forResource: "alertResponse", withExtension: "json")
        let data = try! Data(contentsOf: fileUrl!, options: [])
        
        
        let jsonDecoder = JSONDecoder()
        let alertsResponse = try! jsonDecoder.decode(AlertRequest.self, from: data)
        
        var alertData = alertsResponse.data
        
        let p0Alert = Alert(id: -1, message: "Come to our community dinner event on April 3 to give us feedback and meet our drivers!", fromDate: alertsResponse.data[0].fromDate, toDate: alertsResponse.data[0].toDate, fromTime: alertsResponse.data[0].fromTime, toTime: alertsResponse.data[0].toTime, priority: 0, daysOfWeek: "Every Day", routes: [], signs: [], channelMessages: [])
        
        let p3Alert = Alert(id: -2, message: "Due to construction the RT 90 will be on a detour. This will move the stop from Robert Purcell Community Center to Jessup and Northcross. This is the only change.", fromDate: alertsResponse.data[0].fromDate, toDate: alertsResponse.data[0].toDate, fromTime: alertsResponse.data[0].fromTime, toTime: alertsResponse.data[0].toTime, priority: 3, daysOfWeek: "Every Day", routes: [10, 20, 30, 40, 50, 60, 70, 80, 90], signs: [], channelMessages: [])
        
        alertData.append(p0Alert)
        alertData.append(p3Alert)
        
        alerts = sortedAlerts(alertsList: alertData)
        
        //tableView.contentInset = .init(top: 18, left: 0, bottom: 0, right: 0)
        tableView.reloadData(
        )
    
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("hi")
    }
}

extension ServiceAlertsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView()
        
        switch priorities[section] {
        case 3: headerView.setupView(labelText: Constants.TableHeaders.highPriority)
        case 2: headerView.setupView(labelText: Constants.TableHeaders.mediumPriority)
        case 1: headerView.setupView(labelText: Constants.TableHeaders.lowPriority)
        default: headerView.setupView(labelText: Constants.TableHeaders.noPriority)
        }
        
        return headerView
    }
}

extension ServiceAlertsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return priorities.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let alerts = alerts[priorities[section]] {
            return alerts.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ServiceAlertTableViewCell.identifier, for: indexPath) as? ServiceAlertTableViewCell
        
        if let alertList = alerts[priorities[indexPath.section]] {
            cell?.alert = alertList[indexPath.row]
            cell?.setData()
            cell?.setNeedsUpdateConstraints()
        }
        
        return cell!
    }
}
