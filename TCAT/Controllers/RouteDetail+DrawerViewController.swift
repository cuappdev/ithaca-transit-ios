//
//  RouteDetailViewController.swift
//  TCAT
//
//  Created by Matthew Barker on 2/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import SwiftyJSON
import Pulley

struct RouteDetailCellSize {
    static let smallHeight: CGFloat = 60
    static let largeHeight: CGFloat = 80
    static let regularWidth: CGFloat = 120
    static let indentedWidth: CGFloat = 140
}

class RouteDetailDrawerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
                                        UIGestureRecognizerDelegate, PulleyDrawerViewControllerDelegate {
    
    // MARK: Variables
    
    var summaryView = UIView()
    var tableView: UITableView!
    var safeAreaCover: UIView? = nil
    
    var route: Route!
    var directions: [Direction] = []
    
    let main = UIScreen.main.bounds
    var justLoaded: Bool = true
    
    /// Height of summary view
    var summaryViewHeight: CGFloat = 80
    
    // MARK: Initalization

    init(route: Route) {
        super.init(nibName: nil, bundle: nil)
        self.route = route
        self.directions = route.directions
    }
    
    func update(with route: Route) {
        self.route = route
        self.directions = route.directions
        tableView.reloadData()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let route = aDecoder.decodeObject(forKey: "route") as! Route
        self.init(route: route)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeDetailView()
        initializeCover()
        if let drawer = self.parent as? RouteDetailViewController {
            drawer.initialDrawerPosition = .partiallyRevealed
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeCover()
    }
    
    // MARK: UIView Functions

    /** Create and configure detailView, summaryView, tableView */
    func initializeDetailView() {

        view.backgroundColor = .white
        
        // Create summary tap gesture
        let summaryTapGesture = UITapGestureRecognizer(target: self, action: #selector(summaryTapped))
        summaryTapGesture.delegate = self

        // Place and format the summary view
        summaryView.backgroundColor = .summaryBackgroundColor
        summaryView.frame = CGRect(x: 0, y: 0, width: main.width, height: summaryViewHeight)
        summaryView.roundCorners(corners: [.topLeft, .topRight], radius: 16)
        summaryView.addGestureRecognizer(summaryTapGesture)
        view.addSubview(summaryView)

        // Create and place all bus routes in Directions (account for small screens)
        var icon_maxY: CGFloat = 24; var first = true
        let pullerHeight: CGFloat = 12 / 2 // based on position and height defined elsewhere, halved for "center" calc.
        let mainStopCount = route.numberOfBusRoutes()
        var center = CGPoint(x: icon_maxY, y: (summaryView.frame.height / 2) + pullerHeight)
        for direction in directions {
            if direction.type == .depart {
                // use smaller icons for small phones or multiple icons
                let busType: BusIconType = mainStopCount > 1 ? .directionSmall : .directionLarge
                let busIcon = BusIcon(type: busType, number: direction.routeNumber)
                if first { center.x += busIcon.frame.width / 2; first = false }
                busIcon.center = center
                summaryView.addSubview(busIcon)
                center.x += busIcon.frame.width + 12
                icon_maxY += busIcon.frame.width + 12
            }
        }

        // Place and format top summary label
        let textLabelPadding: CGFloat = 16
        let summaryTopLabel = UILabel()
        if let departDirection = (directions.filter { $0.type == .depart }).first {
            summaryTopLabel.text = "Depart at \(departDirection.startTimeDescription) from \(departDirection.locationName)"
        } else {
            summaryTopLabel.text = directions.first?.locationNameDescription ?? "Route Directions"
        }
        summaryTopLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        summaryTopLabel.textColor = .primaryTextColor
        summaryTopLabel.sizeToFit()
        summaryTopLabel.frame.origin.x = icon_maxY + textLabelPadding
        summaryTopLabel.frame.size.width = summaryView.frame.maxX - summaryTopLabel.frame.origin.x - textLabelPadding
        summaryTopLabel.center.y = (summaryView.bounds.height / 2) + pullerHeight - (summaryTopLabel.frame.height / 2)
        summaryTopLabel.allowsDefaultTighteningForTruncation = true
        summaryTopLabel.lineBreakMode = .byTruncatingTail
        summaryView.addSubview(summaryTopLabel)

        // Place and format bottom summary label
        let summaryBottomLabel = UILabel()
        summaryBottomLabel.text = "Trip Duration: \(route.totalDuration) minute\(route.totalDuration == 1 ? "" : "s")"
        summaryBottomLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        summaryBottomLabel.textColor = .mediumGrayColor
        summaryBottomLabel.sizeToFit()
        summaryBottomLabel.frame.origin.x = icon_maxY + textLabelPadding
        summaryBottomLabel.center.y = (summaryView.bounds.height / 2) + pullerHeight + (summaryBottomLabel.frame.height / 2)
        summaryView.addSubview(summaryBottomLabel)

        // Create Detail Table View
        tableView = UITableView()
        tableView.frame.origin = CGPoint(x: 0, y: summaryViewHeight)
        tableView.frame.size = CGSize(width: main.width, height: main.height - summaryViewHeight)
        tableView.bounces = false
        tableView.estimatedRowHeight = RouteDetailCellSize.smallHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(SmallDetailTableViewCell.self, forCellReuseIdentifier: "smallCell")
        tableView.register(LargeDetailTableViewCell.self, forCellReuseIdentifier: "largeCell")
        tableView.register(BusStopTableViewCell.self, forCellReuseIdentifier: "busStopCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.addGestureRecognizer(summaryTapGesture)
        view.addSubview(tableView)

    }
    
    /// Creates a temporary view to cover the drawer contents when collapsed. Hidden by default.
    func initializeCover() {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets.bottom ?? 34
            safeAreaCover = UIView(frame: CGRect(x: 0, y: summaryViewHeight, width: main.width, height: bottom))
            safeAreaCover!.backgroundColor = .summaryBackgroundColor
            safeAreaCover!.alpha = 0
            view.addSubview(safeAreaCover!)
        }
    }
    
    /// Remove cover view
    func removeCover() {
        safeAreaCover?.removeFromSuperview()
        safeAreaCover = nil
    }
    
    // MARK: Pulley Delegate
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return bottomSafeArea + summaryViewHeight
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return main.height / 2
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        if drawer.drawerPosition != .partiallyRevealed {
            justLoaded = false
        }
    }
    
    private var visible: Bool = false
    private var ongoing: Bool = false
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        
        // Manage cover view hiding drawer when collapsed
        if distance - bottomSafeArea == summaryViewHeight {
            safeAreaCover?.alpha = 1.0
            visible = true
        } else {
            if !ongoing && visible {
                UIView.animate(withDuration: 0.25, animations: {
                    self.safeAreaCover?.alpha = 0.0
                    self.visible = false
                }, completion: { (_) in
                    self.ongoing = false
                })
            }
        }
        
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return justLoaded ? [.collapsed, .partiallyRevealed, .open] : [.collapsed, .open]
    }
    
    // MARK: TableView Data Source and Delegate Functions

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directions.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let direction = directions[indexPath.row]

        if direction.type == .depart {
            let cell = tableView.dequeueReusableCell(withIdentifier: "largeCell")! as! LargeDetailTableViewCell
            cell.setCell(direction, firstStep: indexPath.row == 0)
            return cell.height()
        } else {
            return RouteDetailCellSize.smallHeight
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let direction = directions[indexPath.row]
        let isBusStopCell = direction.type == .arrive && direction.startLocation.coordinate.latitude == 0.0
        let cellWidth: CGFloat = RouteDetailCellSize.regularWidth

        /// Formatting, including selectionStyle, and seperator line fixes
        func format(_ cell: UITableViewCell) -> UITableViewCell {
            cell.selectionStyle = .none
            if indexPath.row == directions.count - 1 {
                cell.layoutMargins = UIEdgeInsets(top: 0, left: main.width, bottom: 0, right: 0)
            }
            return cell
        }

        if isBusStopCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "busStopCell") as! BusStopTableViewCell
            cell.setCell(direction.locationName)
            cell.layoutMargins = UIEdgeInsets(top: 0, left: cellWidth + 20, bottom: 0, right: 0)
            return format(cell)
        }

        else if direction.type == .walk || direction.type == .arrive {
            let cell = tableView.dequeueReusableCell(withIdentifier: "smallCell") as! SmallDetailTableViewCell
            cell.setCell(direction, busEnd: direction.type == .arrive,
                         firstStep: indexPath.row == 0,
                         lastStep: indexPath.row == directions.count - 1)
            cell.layoutMargins = UIEdgeInsets(top: 0, left: cellWidth, bottom: 0, right: 0)
            return format(cell)
        }

        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "largeCell") as! LargeDetailTableViewCell
            cell.setCell(direction, firstStep: indexPath.row == 0)
            cell.layoutMargins = UIEdgeInsets(top: 0, left: cellWidth, bottom: 0, right: 0)
            return format(cell)
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let direction = directions[indexPath.row]

        // Check if cell starts a bus direction, and should be expandable
        if direction.type == .depart {

            if justLoaded { summaryTapped() }

            let cell = tableView.cellForRow(at: indexPath) as! LargeDetailTableViewCell
            cell.isExpanded = !cell.isExpanded

            // Flip arrow
            cell.chevron.layer.removeAllAnimations()

            let transitionOptionsOne: UIViewAnimationOptions = [.transitionFlipFromTop, .showHideTransitionViews]
            UIView.transition(with: cell.chevron, duration: 0.25, options: transitionOptionsOne, animations: {
                cell.chevron.isHidden = true
            })

            cell.chevron.transform = cell.chevron.transform.rotated(by: CGFloat.pi)

            let transitionOptionsTwo: UIViewAnimationOptions = [.transitionFlipFromBottom, .showHideTransitionViews]
            UIView.transition(with: cell.chevron, duration: 0.25, options: transitionOptionsTwo, animations: {
                cell.chevron.isHidden = false
            })

            // Prepare bus stop data to be inserted / deleted into Directions array
            var busStops = [Direction]()
            for stop in direction.busStops {
                let stopAsDirection = Direction(locationName: stop)
                busStops.append(stopAsDirection)
            }
            var indexPathArray: [IndexPath] = []
            let busStopRange = (indexPath.row + 1)..<(indexPath.row + 1) + busStops.count
            for i in busStopRange {
                indexPathArray.append(IndexPath(row: i, section: 0))
            }

            tableView.beginUpdates()

            // Insert or remove bus stop data based on selection

            if cell.isExpanded {
                directions.insert(contentsOf: busStops, at: indexPath.row + 1)
                tableView.insertRows(at: indexPathArray, with: .middle)
            } else {
                directions.replaceSubrange(busStopRange, with: [])
                tableView.deleteRows(at: indexPathArray, with: .bottom)
            }

            tableView.endUpdates()
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)

        } else {
            
            summaryTapped()
            
        }

    }
    
    // MARK: Gesture Recognizers and Interaction-Related Functions

    /** Animate detailTableView depending on context, centering map */
    @objc func summaryTapped(_ sender: UITapGestureRecognizer? = nil) {
        
        print("tapped!")
        
        if let drawer = self.parent as? RouteDetailViewController {
            print("drawer found")
            switch drawer.drawerPosition {
            
            case .collapsed:
                drawer.setDrawerPosition(position: .open, animated: true)
            
            case .open:
                drawer.setDrawerPosition(position: .collapsed, animated: true)
            
            default: break
                
            }
            
        }

    }

}
