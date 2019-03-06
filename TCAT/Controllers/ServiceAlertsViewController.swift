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
    var loadingIndicator: LoadingIndicator?
    var isLoading: Bool { return loadingIndicator != nil }
    var networkError: Bool = false
    
    var alerts = [Int: [Alert]]() {
        didSet {
            removeLoadingIndicator()
            tableView.reloadData()
            if !alerts.isEmpty {
                tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: false)
            }
        }
    }
    var priorities = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Constants.Titles.serviceAlerts
        
        view.backgroundColor = Colors.backgroundWash
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = view.backgroundColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.register(ServiceAlertTableViewCell.self, forCellReuseIdentifier: ServiceAlertTableViewCell.identifier)
        tableView.allowsSelection = false
        
        tableView.contentInset = .init(top: 18, left: 0, bottom: -18, right: 0)
        
        tableView.separatorColor = Colors.dividerTextField
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
        
        updateConstraints()
        
        // getServiceAlerts()
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
    
    func setUpLoadingIndicator() {
        loadingIndicator = LoadingIndicator()
        if let loadingIndicator = loadingIndicator {
            view.addSubview(loadingIndicator)
            loadingIndicator.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.height.equalTo(40)
            }
        }
    }
    
    func removeLoadingIndicator() {
        if isLoading {
            loadingIndicator?.removeFromSuperview()
            loadingIndicator = nil
        }
    }
    
    func getServiceAlerts() {
        Network.getAlerts().perform(withSuccess: { (request) in
            if (request.success) {
                self.removeLoadingIndicator()
                self.networkError = false
                self.alerts = self.sortedAlerts(alertsList: request.data)
            }
        }) { (error) in
            self.removeLoadingIndicator()
            self.networkError = true
            self.alerts = [:]
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
        for key in sortedAlerts.keys {
            if let newAlerts = sortedAlerts[key] {
                sortedAlerts[key] = combineAlertsByTimeSpan(alertsList: newAlerts)
            }
        }
        
        return sortedAlerts
    }
    
    func combineAlertsByTimeSpan(alertsList: [Alert]) -> [Alert] {
        var combinedAlerts = [Alert]()
        var mappedByTimeSpan: [String: Alert] = [:]
        for alert in alertsList {
            let timeSpan = formatTimeString(alert.fromDate, toDate: alert.toDate)
            if var prevAlert = mappedByTimeSpan[timeSpan] {
                prevAlert.routes.append(contentsOf: alert.routes)
                prevAlert.message += "\n\n\(alert.message)"
                mappedByTimeSpan[timeSpan] = prevAlert
            } else {
                mappedByTimeSpan[timeSpan] = alert
            }
        }
        for key in mappedByTimeSpan.keys {
            if var alert = mappedByTimeSpan[key] {
                alert.routes = Array(Set(alert.routes))
                combinedAlerts.append(alert)
            }
        }
        
        return combinedAlerts
    }
    
    private func formatTimeString(_ fromDate: String, toDate: String) -> String {
        
        let newformatter = DateFormatter()
        newformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sZZZZ"
        newformatter.locale = Locale(identifier: "en_US_POSIX")
        
        let fromDate = newformatter.date(from: fromDate)
        let toDate = newformatter.date(from: toDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE M/d"
        
        if let unWrappedFromDate = fromDate, let unWrappedToDate = toDate {
            let formattedFromDate = formatter.string(from: unWrappedFromDate)
            let formattedToDate = formatter.string(from: unWrappedToDate)
            
            return "\(formattedFromDate) - \(formattedToDate)"
        }
        
        return "Time: Unknown"
    }
}

extension ServiceAlertsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView()
        
        switch priorities[section] {
        case 0:
            headerView.setupView(labelText: Constants.TableHeaders.highPriority)
        case 1:
            headerView.setupView(labelText: Constants.TableHeaders.mediumPriority)
        case 2:
            headerView.setupView(labelText: Constants.TableHeaders.lowPriority)
        default:
            headerView.setupView(labelText: Constants.TableHeaders.noPriority)
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
        return alerts[priorities[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServiceAlertTableViewCell.identifier) as? ServiceAlertTableViewCell
            else { return UITableViewCell() }
        
        if let alertList = alerts[priorities[indexPath.section]] {
            cell.alert = alertList[indexPath.row]
            cell.rowNum = indexPath.row
            cell.setData()
            cell.setNeedsUpdateConstraints()
        }
        
        return cell
    }
}

extension ServiceAlertsViewController: DZNEmptyDataSetSource {
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        // If loading indicator is being shown, don't display description
        if isLoading { return nil }
        let title = networkError ? Constants.EmptyStateMessages.noNetworkConnection : Constants.EmptyStateMessages.noActiveAlerts
        return NSAttributedString(string: title, attributes: [.foregroundColor: Colors.metadataIcon])
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        // If loading indicator is being shown, don't display button
        if isLoading || !networkError { return nil }
        let title = Constants.Buttons.retry
        return NSAttributedString(string: title, attributes: [.foregroundColor: Colors.tcatBlue])
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return networkError ? -80 : -60
    }
}

extension ServiceAlertsViewController: DZNEmptyDataSetDelegate {
    func emptyDataSet(_ scrollView: UIScrollView, didTap didTapButton: UIButton) {
        setUpLoadingIndicator()
        tableView.reloadData()
        
        let delay = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
            self.getServiceAlerts()
        }
    }
}

// MARK: Testing
extension ServiceAlertsViewController {
    /*
     When testing:
        1) Comment out getServiceAlerts at the bottom of viewDidLoad()
        2) Add the line `createDummyData()` below it
        3) Create any custom alerts below to test your specific case
        4) Make sure to append them to alertData before the last line of the function
     */
    func createDummyData() {
        
        let fileUrl = Bundle.main.url(forResource: "alertResponse", withExtension: "json")
        let data = try! Data(contentsOf: fileUrl!, options: [])
        
        
        let jsonDecoder = JSONDecoder()
        let alertsResponse = try! jsonDecoder.decode(AlertRequest.self, from: data)
        
        var alertData = alertsResponse.data
        
        var routes = [Int]()
        for i in 0...100 {
            routes.append(i)
        }
        
        let p0Alert = Alert(id: -1, message: "Come to our community dinner event on April 3 to give us feedback and meet our drivers!", fromDate: alertsResponse.data[0].fromDate, toDate: alertsResponse.data[0].toDate, fromTime: alertsResponse.data[0].fromTime, toTime: alertsResponse.data[0].toTime, priority: 0, daysOfWeek: "Every Day", routes: [], signs: [], channelMessages: [])
        
        let p3Alert = Alert(id: -2, message: "Due to construction the RT 90 will be on a detour. This will move the stop from Robert Purcell Community Center to Jessup and Northcross. This is the only change.", fromDate: alertsResponse.data[0].fromDate, toDate: alertsResponse.data[0].toDate, fromTime: alertsResponse.data[0].fromTime, toTime: alertsResponse.data[0].toTime, priority: 3, daysOfWeek: "Every Day", routes: [10, 20, 30, 40, 50, 60, 70, 80, 90], signs: [], channelMessages: [])
        
        let p3Alert1To100 = Alert(id: -6, message: "Due to construction the RT 90 will be on a detour. This will move the stop from Robert Purcell Community Center to Jessup and Northcross. This is the only change.", fromDate: alertsResponse.data[0].fromDate, toDate: alertsResponse.data[0].toDate, fromTime: alertsResponse.data[0].fromTime, toTime: alertsResponse.data[0].toTime, priority: 3, daysOfWeek: "Every Day", routes: routes, signs: [], channelMessages: [])
        
        alertData.append(p0Alert)
        alertData.append(p3Alert1To100)
        alertData.append(p3Alert)
        
        alerts = sortedAlerts(alertsList: alertData)
    }
}
