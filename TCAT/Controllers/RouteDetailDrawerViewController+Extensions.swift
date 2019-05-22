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
    func collapseCells(on cell: LargeDetailTableViewCell) {
        toggleCellExpansion(for: cell)
    }

    func expandCells(on cell: LargeDetailTableViewCell) {
        toggleCellExpansion(for: cell)

        tableView.layoutIfNeeded()
        tableView.layoutSubviews()
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
        let isCollapsed = distance - bottomSafeArea == summaryView.frame.height
        if isCollapsed {
            safeAreaCover?.alpha = 1.0
            visible = true
        } else {
            if visible {
                UIView.animate(withDuration: 0.25, animations: {
                    self.safeAreaCover?.alpha = 0.0
                    self.visible = false
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
            if indexPath.row == directionsAndVisibleStops.count - 1 {
                // Remove seperator at end of table
                cell.layoutMargins = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
            }
            return cell
        }

        let cellWidth: CGFloat = RouteDetailCellSize.regularWidth

        switch directionsAndVisibleStops[indexPath.row] {
        case .busStop(let busStop):
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.busStopDetailCellIdentifier) as! BusStopTableViewCell
            cell.configure(for: busStop.name)
            cell.layoutMargins = UIEdgeInsets(top: 0, left: cellWidth + 20, bottom: 0, right: 0)
            return format(cell)
        case .direction(let direction):
            if direction.type == .walk || direction.type == .arrive {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.smallDetailCellIdentifier, for: indexPath) as! SmallDetailTableViewCell
                cell.configure(for: direction,
                               isFirstStep: indexPath.row == 0,
                               isLastStep: indexPath.row == directionsAndVisibleStops.count - 1)
                cell.layoutMargins = UIEdgeInsets(top: 0, left: cellWidth, bottom: 0, right: 0)
                return format(cell)
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.largeDetailCellIdentifier) as! LargeDetailTableViewCell
                cell.configure(for: direction, isFirstStep: indexPath.row == 0)
                cell.delegate = self
                cell.layoutMargins = UIEdgeInsets(top: 0, left: cellWidth, bottom: 0, right: 0)
                return format(cell)
            }
        }
    }
}

extension RouteDetailDrawerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let direction = directionsAndVisibleStops[indexPath.row].getDirection(),
            direction.type == .depart || direction.type == .transfer {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.largeDetailCellIdentifier) as? LargeDetailTableViewCell
            cell?.configure(for: direction, isFirstStep: indexPath.row == 0)
            return cell?.height() ?? RouteDetailCellSize.largeHeight
        }
        return RouteDetailCellSize.smallHeight
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Empty Footer
        let emptyFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Footers.emptyFooterView) ??
            UITableViewHeaderFooterView(reuseIdentifier: Constants.Footers.emptyFooterView)

        let lastCellIndexPath = IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0)
        var screenBottom = UIScreen.main.bounds.height
        if #available(iOS 11.0, *) {
            screenBottom -= view.safeAreaInsets.bottom
        }

        // Calculate height of space between last cell and the bottom of the screen, also accounting for summary
        var footerHeight = screenBottom - (tableView.cellForRow(at: lastCellIndexPath)?.frame.maxY ?? screenBottom) - summaryView.frame.height
        footerHeight = expandedCell != nil ? 0 : footerHeight

        emptyFooterView.frame.size = CGSize(width: view.frame.width, height: footerHeight)
        emptyFooterView.contentView.backgroundColor = Colors.white
        emptyFooterView.layoutIfNeeded()

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
            phraseLabelFooterView.setView(with: message)
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
