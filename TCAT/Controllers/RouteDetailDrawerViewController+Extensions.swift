//
//  RouteDetailDrawerViewController+Extensions.swift
//  TCAT
//
//  Created by Omar Rasheed on 5/14/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import Pulley
import UIKit

// MARK: Gesture Recognizers and Interaction-Related Functions
extension RouteDetailDrawerViewController: UIGestureRecognizerDelegate {
    /** Animate detailTableView depending on context, centering map */
    @objc func summaryTapped(_ sender: UITapGestureRecognizer? = nil) {

        if let drawer = self.parent as? RouteDetailViewController {
            switch drawer.drawerPosition {
            case .collapsed, .partiallyRevealed:
                if selectedDirection != nil {
                    drawer.setDrawerPosition(position: .collapsed, animated: true)
                } else {
                    drawer.setDrawerPosition(position: .open, animated: true)
                }
            case .open:
                drawer.setDrawerPosition(position: .collapsed, animated: true)
            default: break
            }
        }
    }
}

extension RouteDetailDrawerViewController: LargeDetailTableViewDelegate {
    func toggleCellExpansion(on cell: LargeDetailTableViewCell) {
        toggleCellExpansion(for: cell)
    }
}

extension RouteDetailDrawerViewController: PulleyDrawerViewControllerDelegate {
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return bottomSafeArea + summaryView.frame.height
    }

    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return UIScreen.main.bounds.height / 2
    }

    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        // Center map on drawer change
        switch drawer.drawerPosition {
        case .collapsed, .partiallyRevealed:
            guard let contentViewController = drawer.primaryContentViewController as? RouteDetailContentViewController
                else { return }
            if let direction = selectedDirection {
                if direction.type == .walk {
                    contentViewController.centerMap(on: direction, isOverviewOfPath: true)
                } else {
                    contentViewController.centerMap(on: direction)
                }
                selectedDirection = nil
            } else {
                contentViewController.centerMapOnOverview(drawerPreviewing: drawer.drawerPosition == .partiallyRevealed)
            }
        default: break
        }
    }

    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        // Manage cover view hiding drawer when collapsed
        if distance == collapsedDrawerHeight(bottomSafeArea: bottomSafeArea) {
            safeAreaCover.alpha = 1.0
        } else {
            if safeAreaCover.alpha == 1 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.safeAreaCover.alpha = 0.0
                })
            }
        }
    }

    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.collapsed, .partiallyRevealed, .open]
    }
}

extension RouteDetailDrawerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directionsAndVisibleStops.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        /// Formatting, including selectionStyle, and seperator line fixes
        func format(_ cell: UITableViewCell) -> UITableViewCell {
            cell.selectionStyle = .none
            return cell
        }

        switch directionsAndVisibleStops[indexPath.row] {
        case .busStop(let busStop):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.busStopDetailCellIdentifier) as? BusStopTableViewCell
                else { return UITableViewCell ()}
            cell.configure(for: busStop.name)
            return format(cell)
        case .direction(let direction):
            if direction.type == .walk || direction.type == .arrive {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.smallDetailCellIdentifier, for: indexPath) as? SmallDetailTableViewCell
                    else { return UITableViewCell() }
                cell.configure(for: direction,
                               isFirstStep: indexPath.row == 0,
                               isLastStep: indexPath.row == directionsAndVisibleStops.count - 1)
                return format(cell)
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.largeDetailCellIdentifier) as! LargeDetailTableViewCell
                cell.configure(for: direction,
                               isFirstStep: indexPath.row == 0,
                               isExpanded: expandedDirections.contains(direction),
                               delegate: self)
                return format(cell)
            }
        }
    }
}

extension RouteDetailDrawerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let direction = directionsAndVisibleStops[indexPath.row].getDirection(),
                direction.type == .depart || direction.type == .transfer {
            return UITableView.automaticDimension
        } else {
            return RouteDetailCellSize.smallHeight
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Empty Footer
        let emptyFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Footers.emptyFooterView) ??
            UITableViewHeaderFooterView(reuseIdentifier: Constants.Footers.emptyFooterView)

        emptyFooterView.contentView.backgroundColor = Colors.white

        // Create Footer for No Data from Live Tracking Footer, if needed
        guard
            let drawer = self.parent as? RouteDetailViewController,
            let contentViewController = drawer.primaryContentViewController as? RouteDetailContentViewController
            else {
                return emptyFooterView
        }

        var message: String?

        if !contentViewController.noDataRouteList.isEmpty {
            if contentViewController.noDataRouteList.count > 1 {
                message = Constants.Banner.noLiveTrackingForRoutes
            } else {
                let routeNumber = contentViewController.noDataRouteList.first!
                message = Constants.Banner.noLiveTrackingForRoute + " " + "\(routeNumber)."
            }
        } else {
            message = nil
        }

        if let message = message {
            let phraseLabelFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Footers.phraseLabelFooterView)
                as? PhraseLabelFooterView ?? PhraseLabelFooterView(reuseIdentifier: Constants.Footers.phraseLabelFooterView)
            phraseLabelFooterView.configure(with: message)
            return phraseLabelFooterView
        }

        return emptyFooterView

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let direction = directionsAndVisibleStops[indexPath.row].getDirection()

        selectedDirection = direction

        if let drawer = self.parent as? RouteDetailViewController {
            drawer.setDrawerPosition(position: .collapsed, animated: true)
        }
    }
}
