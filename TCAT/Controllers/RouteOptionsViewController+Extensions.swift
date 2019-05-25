//
//  RouteOptionsViewController+Extensions.swift
//  TCAT
//
//  Created by Omar Rasheed on 5/25/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation
import DZNEmptyDataSet

// MARK: Previewing Delegate
extension RouteOptionsViewController: UIViewControllerPreviewingDelegate {

    @objc func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: routeResults)
            if let indexPath = routeResults.indexPathForRow(at: point), let cell = routeResults.cellForRow(at: indexPath) {
                let route = routes[indexPath.section][indexPath.row]
                presentShareSheet(from: view, for: route, with: cell.getImage())
            }
        }
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let point = view.convert(location, to: routeResults)

        guard
            let indexPath = routeResults.indexPathForRow(at: point),
            let cell = routeResults.cellForRow(at: indexPath) as? RouteTableViewCell,
            let routeDetailViewController = createRouteDetailViewController(from: indexPath)
            else {
                return nil
        }

        routeDetailViewController.preferredContentSize = .zero
        routeDetailViewController.isPeeking = true
        cell.transform = .identity
        previewingContext.sourceRect = routeResults.convert(cell.frame, to: view)

        let payload = RouteResultsCellPeekedPayload()
        Analytics.shared.log(payload)

        return routeDetailViewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        (viewControllerToCommit as? RouteDetailViewController)?.isPeeking = false
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

// MARK: SearchBarCancelDelegate
extension RouteOptionsViewController: SearchBarCancelDelegate {
    func didCancel() {
        hideSearchBar()
    }
}

// MARK: Destination Delegate
extension RouteOptionsViewController: DestinationDelegate {
    func didSelectPlace(place: Place) {

        switch searchType {
        case .from:
            searchFrom = place
        case .to:
            searchTo = place
        }

        if place.name != Constants.General.currentLocation && place.name != Constants.General.firstFavorite {
            SearchTableViewManager.shared.insertPlace(for: Constants.UserDefaults.recentSearch, place: place)
        }

        hideSearchBar()
        dismissSearchBar()
        searchForRoutes()

        let payload: Payload = PlaceSelectedPayload(name: place.name, type: place.type)
        Analytics.shared.log(payload)
    }
}

// MARK: Location Manager Delegate
extension RouteOptionsViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("\(fileName) \(#function): \(error.localizedDescription)")

        if error._code == CLError.denied.rawValue {
            locationManager.stopUpdatingLocation()

            let alertController = UIAlertController(title: Constants.Alerts.LocationPermissions.title, message: Constants.Alerts.LocationPermissions.message, preferredStyle: .alert)

            let settingsAction = UIAlertAction(title: Constants.Alerts.GeneralActions.settings, style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }

            guard let showReminder = userDefaults.value(forKey: Constants.UserDefaults.showLocationAuthReminder) as? Bool else {

                userDefaults.set(true, forKey: Constants.UserDefaults.showLocationAuthReminder)

                let cancelAction = UIAlertAction(title: Constants.Alerts.GeneralActions.cancel, style: .default, handler: nil)
                alertController.addAction(cancelAction)

                alertController.addAction(settingsAction)
                alertController.preferredAction = settingsAction

                present(alertController, animated: true)

                return
            }

            if !showReminder {
                return
            }

            let dontRemindAgainAction = UIAlertAction(title: Constants.Alerts.GeneralActions.dontRemind, style: .default) { (_) in
                userDefaults.set(false, forKey: Constants.UserDefaults.showLocationAuthReminder)
            }
            alertController.addAction(dontRemindAgainAction)

            alertController.addAction(settingsAction)
            alertController.preferredAction = settingsAction

            present(alertController, animated: true)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didReceiveCurrentLocation(manager.location)
    }

    func didReceiveCurrentLocation(_ location: CLLocation?) {
        currentLocation = location?.coordinate

        searchBarView?.resultsViewController?.currentLocation?.latitude = currentLocation?.latitude
        searchBarView?.resultsViewController?.currentLocation?.longitude = currentLocation?.longitude

        if searchFrom?.name == Constants.General.currentLocation {
            searchFrom?.latitude = currentLocation?.latitude
            searchFrom?.longitude = currentLocation?.longitude
        }

        if searchTo?.name == Constants.General.currentLocation {
            searchTo?.latitude = currentLocation?.latitude
            searchTo?.longitude = currentLocation?.longitude
        }

        // If haven't selected start location, set to current location
        if let coordinates = currentLocation, searchFrom == nil {
            let currentLocation = Place(name: Constants.General.currentLocation,
                                        latitude: coordinates.latitude,
                                        longitude: coordinates.longitude)
            searchFrom = currentLocation
            searchBarView?.resultsViewController?.currentLocation = currentLocation
            routeSelection.fromSearchbar.setTitle(currentLocation.name, for: .normal)
            searchForRoutes()
        }
    }

}

// MARK: TableView DataSource
extension RouteOptionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return routes.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.routeOptionsCellIdentifier, for: indexPath) as! RouteTableViewCell

        cell.configure(for: routes[indexPath.section][indexPath.row], delegate: self)

        // Activate timers
        let timerDoesNotExist = (timers[indexPath.row] == nil)
        if timerDoesNotExist {
            timers[indexPath.row] = Timer.scheduledTimer(timeInterval: 5.0, target: cell, selector: #selector(RouteTableViewCell.updateLiveElementsWithDelay(for:)), userInfo: ["route": routes[indexPath.section][indexPath.row]], repeats: true)
        }

        // Add share action for long press gestures on non 3D Touch devices
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        cell.addGestureRecognizer(longPressGestureRecognizer)

        setCellUserInteraction(cell, to: cellUserInteraction)

        return cell
    }

}

// MARK: TableView Delegate
extension RouteOptionsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        locationManager.stopUpdatingLocation()
        if let routeDetailViewController = createRouteDetailViewController(from: indexPath) {
            let payload = RouteResultsCellTappedEventPayload()
            Analytics.shared.log(payload)
            let routeId = routes[indexPath.section][indexPath.row].routeId
            routeSelected(routeId: routeId)
            navigationController?.pushViewController(routeDetailViewController, animated: true)
        }
    }

    /// Different header text based on variable data results (see designs)
    func headerTitles(section: Int) -> String? {
        if routes.count == 3 {
            switch section {
            case 1:
                if (routes.first?.isEmpty ?? false) {
                    return Constants.TableHeaders.boardingSoon
                } else {
                    return Constants.TableHeaders.boardingSoonFromNearby
                }
            case 2: return Constants.TableHeaders.walking
            default: return nil
            }
        } else {
            switch section {
            case 1: return Constants.TableHeaders.walking
            default: return nil
            }
        }
    }

    func isEmptyHeaderView(section: Int) -> Bool {
        return section == 0 && searchFrom?.type == .busStop && routes.first?.isEmpty ?? false
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let containerView = UIView()
        let label = UILabel()

        // Special centered message alerting no fromStop routes (first in 2D routes array)
        if isEmptyHeaderView(section: section) {
            label.text = Constants.TableHeaders.noAvailableRoutes + " from \(searchFrom?.name ?? "Starting Bus Stop")."
            label.font = .getFont(.regular, size: 14)
            label.textAlignment = .center
            label.textColor = Colors.secondaryText

            containerView.addSubview(label)

            label.snp.makeConstraints { (make) in
                make.centerX.centerY.equalToSuperview()
            }
        } else {
            label.text = headerTitles(section: section)
            label.font = .getFont(.regular, size: 12)
            label.textColor = Colors.secondaryText

            containerView.addSubview(label)

            label.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(12)
                make.bottom.equalToSuperview().offset(-12)
            }
        }

        return containerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isEmptyHeaderView(section: section) {
            return 60
        } else {
            return UIFont.getFont(.regular, size: 12).lineHeight
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let tableViewPadding: CGFloat = 12
        return UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: tableViewPadding))
    }

}

// MARK: DZNEmptyDataSet
extension RouteOptionsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {

        let customView = UIView()
        var symbolView = UIView()

        if showRouteSearchingLoader {
            symbolView = LoadingIndicator()
        } else {
            let imageView = UIImageView(image: #imageLiteral(resourceName: "noRoutes"))
            imageView.contentMode = .scaleAspectFit
            symbolView = imageView
        }

        let retryButton = UIButton()
        retryButton.setTitle(Constants.Buttons.retry, for: .normal)
        retryButton.setTitleColor(Colors.tcatBlue, for: .normal)
        retryButton.titleLabel?.font = .getFont(.regular, size: 16.0)
        retryButton.addTarget(self, action: #selector(tappedRetryButton), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.font = .getFont(.regular, size: 18.0)
        titleLabel.textColor = Colors.metadataIcon
        titleLabel.text = showRouteSearchingLoader ? Constants.EmptyStateMessages.lookingForRoutes : Constants.EmptyStateMessages.noRoutesFound
        titleLabel.sizeToFit()

        customView.addSubview(symbolView)
        customView.addSubview(titleLabel)
        if !showRouteSearchingLoader {
            customView.addSubview(retryButton)
        }

        symbolView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            let offset = navigationController?.navigationBar.frame.height ?? 0 + routeSelection.frame.height
            make.centerY.equalToSuperview().offset((showRouteSearchingLoader ? -20 : -60)+(-offset/2))
            make.width.height.equalTo(showRouteSearchingLoader ? 40 : 180)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(symbolView.snp.bottom).offset(10)
            make.centerX.equalTo(symbolView.snp.centerX)
        }

        if !showRouteSearchingLoader {
            retryButton.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.centerX.equalTo(titleLabel.snp.centerX)
                make.height.equalTo(16)
            }
        }

        return customView
    }

    @objc func tappedRetryButton(button: UIButton) {
        showRouteSearchingLoader = true
        routeResults.reloadData()
        let delay = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
            self.searchForRoutes()
        }
    }

    // Don't allow pull to refresh in empty state -- want users to use the retry button
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return false
    }

    // Allow for touch in empty state
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool {
        return true
    }

}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

extension RouteOptionsViewController: RouteTableViewCellDelegate {

    func getRowNum(for cell: RouteTableViewCell) -> Int? {
        return routeResults.indexPath(for: cell)?.row
    }

    func updateLiveElements(fun: () -> Void) {
        routeResults.beginUpdates()
        fun()
        routeResults.endUpdates()
    }
}