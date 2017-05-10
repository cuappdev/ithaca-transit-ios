//
//  RouteDetailViewController.swift
//  TCAT
//
//  Created by Matthew Barker on 2/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import MapKit
import SwiftyJSON

struct RouteDetailCellSize {
    static let smallHeight: CGFloat = 60
    static let largeHeight: CGFloat = 80
    static let regularWidth: CGFloat = 120
    static let indentedWidth: CGFloat = 140
}

class RouteDetailViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    var detailView = UIView()
    var detailTableView: UITableView!
    var summaryView = UIView()
    var locationManager = CLLocationManager()
    
    var mapView: GMSMapView!
    var routePaths: [Path] = []
    var currentLocation: CLLocationCoordinate2D?
    var bounds = GMSCoordinateBounds()
    
    var route: Route!
    var directions: [Direction] = []
    
    let main = UIScreen.main.bounds
    let summaryViewHeight: CGFloat = 80
    var largeDetailHeight: CGFloat = 80
    var mediumDetailHeight: CGFloat = UIScreen.main.bounds.height / 2
    var smallDetailHeight: CGFloat = UIScreen.main.bounds.height - 80
    
    var contentOffset: CGFloat = 0
    
    let markerRadius: CGFloat = 8
    let mapPadding: CGFloat = 40
    
    /** Initalize RouteDetailViewController. Be sure to send a valid route, otherwise
     * dummy data will be used. The directions parameter have logical assumptions,
     * such as ArriveDirection always comes after DepartDirection. */
    init (route: Route? = nil) {
        super.init(nibName: nil, bundle: nil)
        if route == nil {
            // let json = try! JSON(data: Data(contentsOf: Bundle.main.url(forResource: "routeTestingJSON", withExtension: "json")!))
            // initializeRoute(route: try! Route(json: json.first!.1))
        } else {
            initializeRoute(route: route!)
        }
    }
    
    /** Construct Directions based on Route and parse Waypoint / Path data */
    func initializeRoute(route: Route) {
        
        self.route = route
        self.directions = route.directions
        
        print("\nROUTE\n")
        print("departureTime \(route.departureTime)")
        print("arrivalTime \(route.arrivalTime)")
        print("allStops \(route.allStops)")
        print("timeUntilDeparture \(route.timeUntilDeparture)")
        print("lastStopTime \(route.lastStopTime)")
        print("mainStops \(route.mainStops)")
        print("mainStopNums \(route.mainStopsNums)")
        for direction in directions {
            let _ = direction
            // print("\(route.directions)")
        }
        
        // Construct paths in routePaths based on directions
        var skipDirection: Bool = false
        
        if directions.count == 0 { print("Directions array is empty!") }

        for index in 0..<directions.count {
            
            // skip parsing of current direction
            // e.g. all path info is in DepartDirection, don't need ArriveDirection
            if skipDirection { skipDirection = false; continue }
            
            let direction = directions[index]
            
            if let walkDirection = direction as? WalkDirection {
                
                var walkWaypoints: [Waypoint] = []
                if !walkDirection.path.isEmpty {
                    let type: WaypointType = (index == directions.count - 1) ? .destination : .none
                    for walkWaypoint in walkDirection.path {
                        let waypoint = Waypoint(lat: walkWaypoint.latitude, long: walkWaypoint.longitude, wpType: type)
                        walkWaypoints.append(waypoint)
                    }
                } else {
                    print("error: walkDirection.path is empty")
                }
                
                let walkPath = Path(waypoints: walkWaypoints, pathType: .walking, color: .tcatBlueColor)
                routePaths.append(walkPath)
                
            }
            
            if let busDirection = direction as? DepartDirection {
                
                var routeWaypoints: [Waypoint] = []
                for index in 0..<busDirection.path.count {
                    let coord = busDirection.path[index]
                    let type: WaypointType = {
                        switch index {
                        case 0 : return .origin
                        case (busDirection.path.count / 2) : return .stop
                        default : return .none
                        } // show stop waypoint in middle of route, origin for start, none otherwise
                    }()
                    let point = Waypoint(lat: coord.latitude, long: coord.longitude,
                                         wpType: type, busNumber: busDirection.routeNumber)
                    routeWaypoints.append(point)
                }
                
                let busPath = Path(waypoints: routeWaypoints, pathType: .driving, color: .tcatBlueColor)
                routePaths.append(busPath)
                skipDirection = true // already accounted for ArriveDirection, should skip over
                
            }
            
        }
        
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let route = aDecoder.decodeObject(forKey: "route") as! Route
        self.init(route: route)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.formatNavigationController()
        self.initializeDetailView()
                
        // Set up Location Manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func loadView() {
        
        // set mapView with settings
        let camera = GMSCameraPosition.camera(withLatitude: 42.446179, longitude: -76.485070, zoom: 15.5)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: summaryViewHeight, right: 0)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.setMinZoom(12, maxZoom: 25)
        
        // most extreme points on TCAT Route map
        let north = 42.61321283145329
        let east = -76.28125469914926
        let south = 42.32796328578829
        let west = -76.67690943302259
        
        let northEast = CLLocationCoordinate2DMake(north, east)
        let southWest = CLLocationCoordinate2DMake(south, west)
        let panBounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        mapView.cameraTargetBounds = panBounds
        
        self.mapView = mapView
        view = mapView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                
        if let newCoord = locations.last?.coordinate {
            currentLocation = newCoord
        }
        
        if isInitialView() { drawMapRoute() }
        let bottom = (main.height / 2) - (statusNavHeight(includingShadow: false) - 16)
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
        let update = GMSCameraUpdate.fit(bounds, with: edgeInsets)
        mapView.animate(with: update)
        
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print(error)
    }
    
    /** Centers map around all waypoints in routePaths, and animates the map */
    func centerMap() {
        bounds = GMSCoordinateBounds()
        for route in routePaths {
            for waypoint in route.waypoints {
                let coords = CLLocationCoordinate2DMake(CLLocationDegrees(waypoint.lat), CLLocationDegrees(waypoint.long))
                bounds = bounds.includingCoordinate(coords)
            }
        }
        let update = GMSCameraUpdate.fit(bounds, withPadding: mapPadding)
        mapView.animate(with: update)
    }
    
    /** Draw all waypoints initially for all routes in routePaths, plus fill bounds */
    func drawMapRoute() {
        
        for routePath in routePaths {
            
            routePath.traveledPolyline.map = mapView
            routePath.map = mapView
            
            for waypoint in routePath.waypoints {
                let coords = CLLocationCoordinate2DMake(CLLocationDegrees(waypoint.lat), CLLocationDegrees(waypoint.long))
                let marker = GMSMarker(position: coords)
                marker.iconView = waypoint.iconView
                marker.userData = waypoint
                marker.map = mapView
                bounds = bounds.includingCoordinate(coords)
            }
        }

    }
    
    /** Set title, buttons, and style of navigation controller */
    func formatNavigationController() {
        
        smallDetailHeight -= statusNavHeight()
        mediumDetailHeight -= statusNavHeight()
        largeDetailHeight -= statusNavHeight()
        
        let otherAttributes = [NSFontAttributeName: UIFont(name :".SFUIText", size: 14)!]
        let titleAttributes: [String : Any] = [NSFontAttributeName : UIFont(name :".SFUIText", size: 18)!,
                                               NSForegroundColorAttributeName : UIColor.black]
        
        // general
        title = "Route Details"
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.backgroundColor = .white
        
        // text and font
        navigationController?.navigationBar.tintColor = .primaryTextColor
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationItem.backBarButtonItem?.setTitleTextAttributes(otherAttributes, for: .normal)
        
        // right button
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(otherAttributes, for: .normal)
        let cancelButton = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(exitAction))
        cancelButton.setTitleTextAttributes(otherAttributes, for: .normal)
        self.navigationItem.setRightBarButton(cancelButton, animated: true)
        
        // back button
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        let attributedString = NSMutableAttributedString(string: "  Back")
        // raise back button text a hair - attention to detail, baby
        attributedString.addAttribute(NSBaselineOffsetAttributeName, value: 0.3, range: NSMakeRange(0, attributedString.length))
        backButton.setAttributedTitle(attributedString, for: .normal)
        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        let barButtonBackItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.setLeftBarButton(barButtonBackItem, animated: true)
        
    }
    
    /** Return height of status bar and possible navigation controller */
    func statusNavHeight(includingShadow: Bool = false) -> CGFloat {
        return UIApplication.shared.statusBarFrame.height +
            (navigationController?.navigationBar.frame.height ?? 0) +
            (includingShadow ? 4 : 0)
    }
    
    /** Check if screen is in inital view of half map, half detailView */
    func isInitialView() -> Bool {
        return mediumDetailHeight == detailView.frame.minY
    }
    
    /** Return app to home page */
    func exitAction() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    /** Move back one view controller in navigationController stack */
    func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    /** Create and configure detailView, summaryView, tableView */
    func initializeDetailView() {
        
        // Format the Detail View (color, shadow, gestures)
        detailView.backgroundColor = .white
        detailView.frame = CGRect(x: 0, y: mediumDetailHeight, width: main.width, height: main.height - largeDetailHeight)
        detailView.layer.cornerRadius = 12
        detailView.layer.shadowColor = UIColor.black.cgColor
        detailView.layer.shadowOpacity = 0.5
        detailView.layer.shadowOffset = .zero
        detailView.layer.shadowRadius = 4
        detailView.layer.shadowPath = UIBezierPath(rect: detailView.bounds).cgPath
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        gesture.delegate = self
        detailView.addGestureRecognizer(gesture)
        
        // Place and format the summary view
        summaryView.backgroundColor = .summaryBackgroundColor
        summaryView.frame = CGRect(x: 0, y: 0, width: main.width, height: summaryViewHeight)
        summaryView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        let summaryTapGesture = UITapGestureRecognizer(target: self, action: #selector(summaryTapped))
        summaryTapGesture.delegate = self
        summaryView.addGestureRecognizer(summaryTapGesture)
        detailView.addSubview(summaryView)
        
        // Create puller tab
        let puller = UIView(frame: CGRect(x: 0, y: 6, width: 32, height: 4))
        // value to help center items below
        let pullerHeight = (puller.frame.origin.y + puller.frame.height) / 2
        puller.center.x = summaryView.center.x
        puller.backgroundColor = .mediumGrayColor
        puller.layer.cornerRadius = puller.frame.height / 2
        summaryView.addSubview(puller)
        
        // Create and place all bus routes in Directions (account for small screens)
        var icon_maxY: CGFloat = 24; var first = true
        let mainStopCount = route.mainStopsNums.filter { $0 != -1 }.count
        var center = CGPoint(x: icon_maxY, y: (summaryView.frame.height / 2) + pullerHeight)
        for direction in directions {
            if direction is DepartDirection {
                let busDirection = direction as! DepartDirection
                // use smaller icons for small phones or multiple icons
                let busSize: BusIconSize = mainStopCount > 1 ? .small : .large
                let busIcon = BusIcon(size: busSize, number: busDirection.routeNumber)
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
        if let firstDirection = (directions.filter { $0 is DepartDirection }).first {
            summaryTopLabel.text = "Departs at \(firstDirection.timeDescription)"
        } else { summaryTopLabel.text = "Summary Top Label" }
        summaryTopLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
        summaryTopLabel.textColor = .primaryTextColor
        summaryTopLabel.sizeToFit()
        summaryTopLabel.frame.origin.x = icon_maxY + textLabelPadding
        summaryTopLabel.center.y = (summaryView.bounds.height / 2) + pullerHeight - (summaryTopLabel.frame.height / 2)
        summaryView.addSubview(summaryTopLabel)
        
        // Place and format bottom summary label
        let summaryBottomLabel = UILabel()
        if let totalTime = Time.dateComponents(from: route.departureTime, to: route.arrivalTime).minute {
            summaryBottomLabel.text = "Trip Duration - \(totalTime) minutes"
        } else { summaryBottomLabel.text = "Summary Bottom Label" }
        summaryBottomLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        summaryBottomLabel.textColor = .mediumGrayColor
        summaryBottomLabel.sizeToFit()
        summaryBottomLabel.frame.origin.x = icon_maxY + textLabelPadding
        summaryBottomLabel.center.y = (summaryView.bounds.height / 2) + pullerHeight + (summaryBottomLabel.frame.height / 2)
        summaryView.addSubview(summaryBottomLabel)
        
        // Create Detail Table View
        detailTableView = UITableView()
        detailTableView.frame.origin = CGPoint(x: 0, y: summaryViewHeight)
        detailTableView.frame.size = CGSize(width: main.width, height: detailView.frame.height - summaryViewHeight)
        detailTableView.bounces = false
        detailTableView.estimatedRowHeight = RouteDetailCellSize.smallHeight
        detailTableView.rowHeight = UITableViewAutomaticDimension
        detailTableView.register(SmallDetailTableViewCell.self, forCellReuseIdentifier: "smallCell")
        detailTableView.register(LargeDetailTableViewCell.self, forCellReuseIdentifier: "largeCell")
        detailTableView.register(BusStopTableViewCell.self, forCellReuseIdentifier: "busStopCell")
        detailTableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
        detailTableView.dataSource = self
        detailTableView.delegate = self
        detailView.addSubview(detailTableView)
        view.addSubview(detailView)
        
    }
    
    func detailTableViewHeight() -> CGFloat {
        var heightOfCells: CGFloat = 0
        for direction in directions {
            if direction is DepartDirection {
                let cell = detailTableView.dequeueReusableCell(withIdentifier: "largeCell")! as! LargeDetailTableViewCell
                cell.setCell(direction, firstStep: false)
                heightOfCells += cell.height()
            } else {
                heightOfCells += RouteDetailCellSize.smallHeight
            }
        }
        return heightOfCells
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        let heightOfCells = detailTableViewHeight()
        return main.height - largeDetailHeight - summaryViewHeight - heightOfCells
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "footer")
        footer?.contentView.backgroundColor = .white
        return footer
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let direction = directions[indexPath.row]
        
        if direction is DepartDirection {
            let cell = tableView.dequeueReusableCell(withIdentifier: "largeCell")! as! LargeDetailTableViewCell
            cell.setCell(direction, firstStep: indexPath.row == 0)
            return cell.height()
        } else {
            return RouteDetailCellSize.smallHeight
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let direction = directions[indexPath.row]
        let isBusStopCell = direction is ArriveDirection && direction.location.coordinate.latitude == 0.0
        let cellWidth: CGFloat = RouteDetailCellSize.regularWidth
        
        for index in 0..<directions.count {
            // print("\(index) • \(directions[index])")
        }
        
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
            cell.setCell(direction.place)
            cell.layoutMargins = UIEdgeInsets(top: 0, left: cellWidth + 20, bottom: 0, right: 0)
            return format(cell)
        }
            
        else if direction is WalkDirection || direction is ArriveDirection {
            let cell = tableView.dequeueReusableCell(withIdentifier: "smallCell") as! SmallDetailTableViewCell
            print("index of below cell: \(indexPath.row)")
            cell.setCell(direction, busEnd: direction is ArriveDirection,
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
        if direction is DepartDirection {
            
            if isInitialView() { summaryTapped() }
            
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
            var busStops: [Direction] = []
            for stop in (direction as! DepartDirection).stops {
                let stopAsDirection = ArriveDirection(time: Date(), place: stop, location: CLLocation())
                busStops.append(stopAsDirection)
            }
            var indexPathArray: [IndexPath] = []
            let busStopRange = (indexPath.row + 1)..<(indexPath.row + 1) + busStops.count
            for i in busStopRange {
                indexPathArray.append(IndexPath(row: i, section: 0))
            }
            
            tableView.beginUpdates()
            
            // Insert or remove bus stop data based on selection
            
            print("directions before")
            for direction in directions { print("direction: \(direction)") }
            
            if cell.isExpanded {
                directions.insert(contentsOf: busStops, at: indexPath.row + 1)
                tableView.insertRows(at: indexPathArray, with: .middle)
            } else {
                directions.replaceSubrange(busStopRange, with: [])
                tableView.deleteRows(at: indexPathArray, with: .bottom)
            }
            
            print("directions after")
            for direction in directions { print("direction: \(direction)") }
            
            tableView.endUpdates()
            
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
            tableView.contentSize.height = detailTableViewHeight()
            tableView.setNeedsLayout()
            tableView.layoutIfNeeded()
            print("tableView.contentSize.height: \(tableView.contentSize.height)")
            
            // let lastIndexPath = IndexPath(row: directions.count - 1, section: 0)
            // tableView.reloadRows(at: [lastIndexPath], with: .none)
            
        }
        
    }
    
    /** Animate detailTableView depending on context, centering map */
    func summaryTapped(_ sender: UITapGestureRecognizer? = nil) {
        
        let isSmall = self.detailView.frame.minY == self.smallDetailHeight
        
        if isInitialView() || !isSmall {
            centerMap() // !isSmall to make centered when going big to small
        }
        
        UIView.animate(withDuration: 0.25) {
            let point = CGPoint(x: 0, y: isSmall || self.isInitialView() ? self.largeDetailHeight : self.smallDetailHeight)
            self.detailView.frame = CGRect(origin: point, size: self.view.frame.size)
            self.detailTableView.layoutIfNeeded()
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == detailTableView {
            contentOffset = scrollView.contentOffset.y
        }
    }
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
        
        if contentOffset != 0 { return }
        
        let translation = recognizer.translation(in: self.detailView)
        let velocity = recognizer.velocity(in: self.detailView)
        let y = self.detailView.frame.minY
        
        if y + translation.y >= largeDetailHeight && y + translation.y <= smallDetailHeight {
            print("y + translation >= large and y + translation <= small")
            print("translation: \(translation), velocity: \(velocity), y: \(y)")
            self.detailView.frame = CGRect(x: 0, y: y + translation.y, width: detailView.frame.width, height: detailView.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.detailView)
        }
        
        if recognizer.state == .ended {
            print("recognizer.state == .ended")
            print("translation: \(translation), velocity: \(velocity), y: \(y)")
            
            let visibleScreen = self.main.height - UIApplication.shared.statusBarFrame.height - self.navigationController!.navigationBar.frame.height
            
            var duration = Double(abs(visibleScreen - y)) / Double(abs(velocity.y))
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration) {
                let point = CGPoint(x: 0, y: velocity.y > 0 ? self.smallDetailHeight : self.largeDetailHeight)
                self.detailView.frame = CGRect(origin: point, size: self.view.frame.size)
            }
        }
        
    }
    
}
