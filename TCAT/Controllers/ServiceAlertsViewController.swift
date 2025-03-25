//
//  ServiceAlertsViewController.swift
//  TCAT
//
//  Created by Omar Rasheed on 10/23/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import Combine
import DZNEmptyDataSet
import SnapKit
import UIKit

class ServiceAlertsViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .grouped)

    private var cancellables = Set<AnyCancellable>()
    private var isLoading: Bool { return loadingIndicator != nil }
    private var loadingIndicator: LoadingIndicator?
    private var networkError: Bool = false
    private var priorities = [Int]()

    private var alerts = [Int: [ServiceAlert]]() {
        didSet {
            removeLoadingIndicator()
            tableView.reloadData()
            if !alerts.isEmpty {
                let tableHeaderView = UIImageView(image: UIImage(named: "TCAT-transparent"))
                let containerView = UIView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
                containerView.addSubview(tableHeaderView)
                tableHeaderView.snp.makeConstraints { (make) in
                    make.top.centerX.equalToSuperview()
                    make.width.equalTo(140)
                    make.bottom.equalToSuperview().inset(25)
                }
                tableView.tableHeaderView = containerView
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Constants.Titles.serviceAlerts

        // Temporary change for settings page (make nav title prefer large to fit settings page theme)
        navigationController?.navigationBar.prefersLargeTitles = true

        view.backgroundColor = Colors.backgroundWash
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

        setupConstraints()

        getServiceAlerts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let payload = ServiceAlertsPayload()
        TransitAnalytics.shared.log(payload)
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }

    private func setUpLoadingIndicator() {
        loadingIndicator = LoadingIndicator()
        if let loadingIndicator = loadingIndicator {
            view.addSubview(loadingIndicator)
            loadingIndicator.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.height.equalTo(40)
            }
        }
    }

    private func removeLoadingIndicator() {
        if isLoading {
            loadingIndicator?.removeFromSuperview()
            loadingIndicator = nil
        }
    }

    /// Fetches service alerts using TransitService and updates the table view.
    private func getServiceAlerts() {
        setUpLoadingIndicator()

        TransitService.shared.getAlerts()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }

                switch completion {
                case .failure(let error):
                    self.removeLoadingIndicator()
                    self.networkError = true
                    self.alerts = [:]
                    self.printClass(context: "\(#function) error", message: error.localizedDescription)
                    let payload = NetworkErrorPayload(
                        location: "\(self) Get Alerts",
                        type: "\((error as NSError).domain)",
                        description: error.localizedDescription
                    )
                    TransitAnalytics.shared.log(payload)

                case .finished:
                    break
                }
            } receiveValue: { [weak self] alerts in
                self?.removeLoadingIndicator()
                self?.networkError = false
                self?.alerts = self?.sortedAlerts(alertsList: alerts) ?? [:]
            }
            .store(in: &cancellables)
    }

    private func sortedAlerts(alertsList: [ServiceAlert]) -> [Int: [ServiceAlert]] {
        var sortedAlerts = [Int: [ServiceAlert]]()
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

    private func combineAlertsByTimeSpan(alertsList: [ServiceAlert]) -> [ServiceAlert] {
        var combinedAlerts = [ServiceAlert]()
        var mappedByTimeSpan: [String: ServiceAlert] = [:]
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
        switch priorities[section] {
        case 0:
            return HeaderView(labelText: Constants.TableHeaders.highPriority)

        case 1:
            return HeaderView(labelText: Constants.TableHeaders.mediumPriority)

        case 2:
            return HeaderView(labelText: Constants.TableHeaders.lowPriority)

        default:
            return HeaderView(labelText: Constants.TableHeaders.noPriority)
        }
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
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ServiceAlertTableViewCell.identifier
        ) as? ServiceAlertTableViewCell else { return UITableViewCell() }

        if let alertList = alerts[priorities[indexPath.section]] {
            cell.configure(for: alertList[indexPath.row], isNotFirstRow: indexPath.row > 0)
            cell.setNeedsUpdateConstraints()
        }

        return cell
    }

}

extension ServiceAlertsViewController: DZNEmptyDataSetSource {

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        // If loading indicator is being shown, don't display description
        if isLoading { return nil }
        let title = networkError
            ? Constants.EmptyStateMessages.noNetworkConnection
            : Constants.EmptyStateMessages.noActiveAlerts
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
