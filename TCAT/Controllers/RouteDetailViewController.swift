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
import NotificationBannerSwift

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
    var summaryBottomLabel = UILabel()
    
    var loadingView: UIView!
    var isLoading: Bool = true
    var withinMiddle: Bool = true
    
    var locationManager = CLLocationManager()

    var mapView: GMSMapView!
    var routePaths: [Path] = []
    var currentLocation: CLLocationCoordinate2D?
    var bounds = GMSCoordinateBounds()

    var networkTimer: Timer? = nil
    /// Number of seconds to wait before auto-refreshing network call, timed with live indicator
    var refreshRate: Double = LiveIndicator.INTERVAL * 3.0
    var buses = [GMSMarker]()
    var banner: StatusBarNotificationBanner? = nil

    var route: Route!
    var directions: [Direction] = []
    var totalDuration: Int = 0

    let main = UIScreen.main.bounds
    // to be initialized programmatically
    var summaryViewHeight: CGFloat = 0
    var largeDetailHeight: CGFloat = 0
    var mediumDetailHeight: CGFloat = 0
    var smallDetailHeight: CGFloat = 0

    var contentOffset: CGFloat = 0

    let markerRadius: CGFloat = 8
    let mapPadding: CGFloat = 40
    let minZoom: Float = 12
    let defaultZoom: Float = 15.5
    let maxZoom: Float = 25

    /** Initalize RouteDetailViewController. Be sure to send a valid route, otherwise
     * dummy data will be used. The directions parameter have logical assumptions,
     * such as ArriveDirection always comes after DepartDirection. */
    init (route: Route? = nil) {
        super.init(nibName: nil, bundle: nil)
        if route == nil {
            let json = try! JSON(data: Data(contentsOf: Bundle.main.url(forResource: "testNew", withExtension: "json")!))
            initializeRoute(route: try! Route(json: json))
        } else {
            initializeRoute(route: route!)
        }
    }

    /** Construct Directions based on Route and parse Waypoint / Path data */
    func initializeRoute(route: Route) {

        self.route = route
        self.directions = route.directions
        
        /// Calculate walking directions
        
        let walkingDirections = self.directions.filter { $0.type == .walk }
        var walkingPaths: [Path] = []
        for direction in walkingDirections {
            calculateWalkingDirections(direction) { (path, time) in
                
                direction.path = path
                self.totalDuration += Int(time)
                
                var waypoints: [Waypoint] = []
                for point in path {
                    var type: WaypointType = .walking
                    if direction == self.directions.first && point == path.first! {
                        type = .origin
                    }
                    else if direction == self.directions.last && point == path.last! {
                        type = .destination
                    }
//                    else if point == path.first! || point == path.last! {
//                        type = .walk
//                    }
                    let waypoint = Waypoint(lat: point.latitude, long: point.longitude, wpType: type)
                    waypoints.append(waypoint)
                }
                
                let walkingPath = WalkPath(waypoints)
                walkingPaths.append(walkingPath)
                self.routePaths.append(walkingPath)
                
                // Update rest of app with on walking direction load completion
                if walkingPaths.count == walkingDirections.count {
                    self.isLoading = false
                    self.summaryBottomLabel.text = "Trip Duration: \(self.totalDuration) minute\(self.totalDuration == 1 ? "" : "s")"
                    self.summaryBottomLabel.sizeToFit()
                    self.drawMapRoute(walkingPaths)
                    self.dismissLoadingScreen()
                }
                
            }
        }
        
        // Print Route Information
        
//        print("\n\n--- Route ---\n")
//        print(route.debugDescription)
//        print("\ndirections:")
//        for (index, object) in route.directions.enumerated() {
//            print("--- Direction[\(index)] ---")
//            print(object.debugDescription)
//            // print("path:", object.path)
//        }
//        print("\n-------\n")
        
        // Plot the paths of all directions
        for (arrayIndex, direction) in directions.enumerated() {

            var waypoints: [Waypoint] = []

            for (pathIndex, point) in direction.path.enumerated() {

                var type: WaypointType = .none

                if direction.type == .depart {
                    
                    type = .bussing

                    if pathIndex == 0 {
                        type = arrayIndex == 0 ? .origin : .bus
                    }
                        
                    else if pathIndex == direction.path.count - 1 {
                        type = arrayIndex == directions.count - 1 ? .destination : .bus
                    }
                        
                    else if pointWithinLocation(point: point, location: direction.startLocation.coordinate, exact: true) ||
                        pointWithinLocation(point: point, location: direction.endLocation.coordinate, exact: true) {
                        
                        // type = .stop
                        
                    }

                }

                let waypoint = Waypoint(lat: point.latitude, long: point.longitude, wpType: type)
                waypoints.append(waypoint)

            }

            let path = direction.type == .walk ? WalkPath(waypoints) : BusPath(waypoints)
            routePaths.append(path)

        }

    }

    required convenience init(coder aDecoder: NSCoder) {
        let route = aDecoder.decodeObject(forKey: "route") as! Route
        self.init(route: route)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setHeights()
        formatNavigationController()
        createLoadingScreen()
        initializeDetailView()
        
        // Set up Location Manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let timer = networkTimer {
            timer.invalidate()
        }

        networkTimer = Timer.scheduledTimer(timeInterval: refreshRate, target: self, selector: #selector(getBusLocations),
                                            userInfo: nil, repeats: true)
        networkTimer!.fire()

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        networkTimer?.invalidate()
        networkTimer = nil
        banner = nil
    }

    override func loadView() {

        // set mapView with settings
        let camera = GMSCameraPosition.camera(withLatitude: 42.446179, longitude: -76.485070, zoom: defaultZoom)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: summaryViewHeight, right: 0)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.setMinZoom(minZoom, maxZoom: maxZoom)

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
        if isLoading { view.alpha = 0 }
        
    }
    
    // MARK: Loading Screen Functions
    
    func createLoadingScreen() {
        
        loadingView = UIView(frame: navigationController?.view.frame ?? CGRect())
        loadingView.frame.origin.y += statusNavHeight()
        loadingView.frame.size.height -= statusNavHeight()
        loadingView.backgroundColor = .tableBackgroundColor
        
        let circularProgress = LoadingIndicator()
        loadingView.addSubview(circularProgress)
        
        circularProgress.snp.makeConstraints{ (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }

        navigationController?.view.addSubview(self.loadingView)
        
    }
    
    func dismissLoadingScreen() {
        view.alpha = 1
        loadingView.removeFromSuperview()
    }
    
    // MARK: Programmatic Layout Constants
    
    /** Set proper layout constraints based on version (iOS 11 & safeArea support) */
    func setHeights() {
        
        summaryViewHeight = 80
        
        if #available(iOS 11.0, *) {
            let topPadding = navigationController?.view.safeAreaInsets.top ?? 0
            let bottomPadding = navigationController?.view.safeAreaInsets.bottom ?? 0

            largeDetailHeight = topPadding
            mediumDetailHeight = (main.height / 2) - statusNavHeight()
            smallDetailHeight = main.height - summaryViewHeight - bottomPadding*2 - topPadding

        } else {

            largeDetailHeight = summaryViewHeight
            mediumDetailHeight = main.height / 2 - statusNavHeight()
            smallDetailHeight = main.height - summaryViewHeight
            
            smallDetailHeight -= statusNavHeight()
            largeDetailHeight -= statusNavHeight()
            
        }
        
    }
    
    /** Return height of status bar and possible navigation controller */
    func statusNavHeight(includingShadow: Bool = false) -> CGFloat {
        
        if #available(iOS 11.0, *) {
            
            return (navigationController?.view.safeAreaInsets.top ?? 0) +
                (navigationController?.navigationBar.frame.height ?? 0) +
                (includingShadow ? 4 : 0)
            
        } else {
            
            return UIApplication.shared.statusBarFrame.height +
                (navigationController?.navigationBar.frame.height ?? 0) +
                (includingShadow ? 4 : 0)
            
        }

    }
    
    // MARK: Location Manager Functions
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let newCoord = locations.last?.coordinate {
            currentLocation = newCoord
        }
        
        if isInitialView() { drawMapRoute() }
        centerMap(topHalfCentered: true)
        
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("RouteDetailVC CLLocationManager didFailWithError: \(error)")
    }
    
    // MARK: Live Tracking Functions

    /** Fetch live-tracking information for the first direction's bus route. Handles connection issues with banners. */
    @objc func getBusLocations() {

 // /* debugging
        
        guard let firstRoute = route.directions.first(where: {
            return $0.routeNumber > 0
        })
        else {
            print("[RouteDetailViewController] getBusLocations: Couldn't find valid routes")
            return
        }
// */ // debugging
        
        // Network.getBusLocations(routeID: "90").perform( // debugging
        
        Network.getBusLocations(routeID: String(firstRoute.routeNumber)).perform(

            withSuccess: { (result) in

                self.banner?.dismiss()
                self.banner = nil
                self.updateBusLocations(busLocations: result.allBusLocations)

        }) { (error) in

            print("RouteDetailVC getBusLocations Error:", error)
            if self.banner == nil {
                let title = "Cannot connect to live tracking"
                self.banner = StatusBarNotificationBanner(title: title, style: .warning)
                self.banner!.autoDismiss = false
                self.banner!.show(queuePosition: .front, on: self)
            }

        }

    }

    /** Update the map with new busLocations, adding or replacing based on vehicleID */
    func updateBusLocations(busLocations: [BusLocation]) {

        for bus in busLocations {

            let busCoords = CLLocationCoordinate2DMake(bus.latitude, bus.longitude)
            let existingBus = buses.first(where: {
                return ($0.userData as? BusLocation)?.vehicleID == bus.vehicleID
            })

            // If bus is already on map, update and animate change
            if let newBus = existingBus {

                UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
                    newBus.userData = bus
                    // (newBus.iconView as? BusLocationView)?.setBearing(bus.heading, start: existingBus!.position, end: busCoords)
                    (newBus.iconView as? BusLocationView)?.setBetterBearing(start: existingBus!.position, end: busCoords, debugDegrees: bus.heading)
                    newBus.position = busCoords
                })
                
            }
            // Otherwise, add bus to map
            else {
                let marker = GMSMarker(position: busCoords)
                // (bus.iconView as? BusLocationView)?.setBearing(bus.heading)
                marker.iconView = bus.iconView

                marker.userData = bus
                marker.map = mapView
                buses.append(marker)
            }

        }

    }
    
    // MARK: Map Functions

    /** Centers map around all waypoints in routePaths, and animates the map */
    func centerMap(topHalfCentered: Bool = false) {

        if topHalfCentered {
            let constant: CGFloat = 20
            let bottom = (main.height / 2) - (statusNavHeight(includingShadow: false) - constant)
            let edgeInsets = UIEdgeInsets(top: mapPadding / 2 , left: constant, bottom: bottom, right: constant)
            let update = GMSCameraUpdate.fit(bounds, with: edgeInsets)
            mapView.animate(with: update)
        }

        else {
            bounds = GMSCoordinateBounds()
            for route in routePaths {
                for waypoint in route.waypoints {
                    bounds = bounds.includingCoordinate(waypoint.coordinate)
                }
            }
            let update = GMSCameraUpdate.fit(bounds, withPadding: mapPadding)
            mapView.animate(with: update)
        }

    }
    
    func setIndex(of marker: GMSMarker, with waypoint: Waypoint) {
        marker.zIndex = {
            switch waypoint.wpType {
            case .bus: return 1
            case .walk: return 1
            case .origin: return 3
            case .destination: return 3
            case .stop: return 1
            case .walking: return 0
            case .bussing: return 999 // large constant to place above other elements
            default: return 0
            }
        }()
    }

    /** Draw all waypoints initially for all paths in [Path] or [[CLLocationCoordinate2D]], plus fill bounds */
    func drawMapRoute(_ newPaths: [Path]? = nil) {

        let paths = newPaths ?? routePaths
        
        for path in paths {
            
            path.traveledPolyline.map = mapView
            path.map = mapView
            
            for waypoint in path.waypoints {
                
//                 if routePath is WalkPath {
//                    (routePath as! WalkPath).circles.forEach { (circle) in
//                        circle.map = mapView
//                    }
//                 } else {
                
                    let marker = GMSMarker(position: waypoint.coordinate)
                    marker.iconView = waypoint.iconView
                    marker.userData = waypoint
                    marker.map = mapView
                    setIndex(of: marker, with: waypoint)
                
//                }
                
                bounds = bounds.includingCoordinate(waypoint.coordinate)
                
            }
            
        }
        
        if newPaths != nil {
            centerMap(topHalfCentered: true)
        }

    }

    /** Set title, buttons, and style of navigation controller */
    func formatNavigationController() {

        let otherAttributes = [NSAttributedStringKey.font: UIFont(name :".SFUIText", size: 14)!]
        let titleAttributes: [NSAttributedStringKey: Any] = [.font : UIFont(name :".SFUIText", size: 18)!,
                                                             .foregroundColor : UIColor.black]

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
        attributedString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0.3, range: NSMakeRange(0, attributedString.length))
        backButton.setAttributedTitle(attributedString, for: .normal)
        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        let barButtonBackItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.setLeftBarButton(barButtonBackItem, animated: true)

    }

    /** Check if screen is in inital view of half map, half detailView */
    func isInitialView() -> Bool {
        return mediumDetailHeight == detailView.frame.minY
    }

    /** Return app to home page */
    @objc func exitAction() {
        navigationController?.popToRootViewController(animated: true)
    }

    /** Move back one view controller in navigationController stack */
    @objc func backAction() {
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
        if let totalTime = Time.dateComponents(from: route.departureTime, to: route.arrivalTime).minute {
            totalDuration = totalTime >= 0 ? totalTime : 0
            summaryBottomLabel.text = "Trip Duration: \(totalDuration) minute\(totalDuration == 1 ? "" : "s")"
        } else { summaryBottomLabel.text = "Summary Bottom Label" }
        summaryBottomLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        summaryBottomLabel.textColor = .mediumGrayColor
        summaryBottomLabel.sizeToFit()
        summaryBottomLabel.frame.origin.x = icon_maxY + textLabelPadding
        summaryBottomLabel.center.y = (summaryView.bounds.height / 2) + pullerHeight + (summaryBottomLabel.frame.height / 2)
        summaryView.addSubview(summaryBottomLabel)

        // Create Detail Table View
        detailTableView = UITableView()
        detailTableView.frame.origin = CGPoint(x: 0, y: summaryViewHeight)
        detailTableView.frame.size = CGSize(width: main.width, height: smallDetailHeight)
        detailTableView.bounces = false
        detailTableView.estimatedRowHeight = RouteDetailCellSize.smallHeight
        detailTableView.rowHeight = UITableViewAutomaticDimension
        detailTableView.register(SmallDetailTableViewCell.self, forCellReuseIdentifier: "smallCell")
        detailTableView.register(LargeDetailTableViewCell.self, forCellReuseIdentifier: "largeCell")
        detailTableView.register(BusStopTableViewCell.self, forCellReuseIdentifier: "busStopCell")
        detailTableView.dataSource = self
        detailTableView.delegate = self
        detailTableView.tableFooterView = UIView()
        detailView.addSubview(detailTableView)
        view.addSubview(detailView)

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

        }

    }
    
    // MARK: Gesture Recognizers and Interaction-Related Functions

    /** Animate detailTableView depending on context, centering map */
    @objc func summaryTapped(_ sender: UITapGestureRecognizer? = nil) {

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

    @objc func panGesture(recognizer: UIPanGestureRecognizer) {

        if contentOffset != 0 { return }

        let translation = recognizer.translation(in: self.detailView)
        let velocity = recognizer.velocity(in: self.detailView)
        let y = self.detailView.frame.minY

        if y + translation.y >= largeDetailHeight && y + translation.y <= smallDetailHeight {
            self.detailView.frame = CGRect(x: 0, y: y + translation.y, width: detailView.frame.width, height: detailView.frame.height)
            recognizer.setTranslation(.zero, in: self.detailView)
        }

        if recognizer.state == .ended {

            // to make sure call bar doesn't mess up view
            let statusHeight: CGFloat = 20 // UIApplication.shared.statusBarFrame.height
            let visibleScreen = self.main.height - statusHeight - self.navigationController!.navigationBar.frame.height

            var duration = Double(abs(visibleScreen - y)) / Double(abs(velocity.y))
            duration = duration > 0.5 ? 0.5 : duration

            UIView.animate(withDuration: duration) {
                let point = CGPoint(x: 0, y: velocity.y > 0 ? self.smallDetailHeight : self.largeDetailHeight)
                self.detailView.frame = CGRect(origin: point, size: self.view.frame.size)
            }
            
        }

    }

}
