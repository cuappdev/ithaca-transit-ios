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
import Pulley

class RouteDetailContentViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var loadingView: UIView!
    var drawerDisplayController: RouteDetailDrawerViewController?
    
    var isLoading: Bool = true
    var justLoaded: Bool = true
    
    var locationManager = CLLocationManager()

    var mapView: GMSMapView!
    var currentLocation: CLLocationCoordinate2D?
    var bounds = GMSCoordinateBounds()

    var networkTimer: Timer? = nil
    /// Number of seconds to wait before auto-refreshing network call, timed with live indicator
    var refreshRate: Double = LiveIndicator.INTERVAL * 3.0
    var buses = [GMSMarker]()
    var banner: StatusBarNotificationBanner? = nil

    var route: Route!
    var directions: [Direction] = []

    let main = UIScreen.main.bounds

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
                route.totalDuration = route.totalDuration + Int(time)
                
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
                route.paths.append(walkingPath)
                
                // Update rest of app with on walking direction load completion
                if walkingPaths.count == walkingDirections.count {
                    self.isLoading = false
                    self.drawerDisplayController?.update(with: route)
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
            route.paths.append(path)

        }
        
        drawerDisplayController = RouteDetailDrawerViewController(route: route)

    }

    required convenience init(coder aDecoder: NSCoder) {
        let route = aDecoder.decodeObject(forKey: "route") as! Route
        self.init(route: route)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        createLoadingScreen()
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        networkTimer?.invalidate()
        networkTimer = nil
        banner = nil
        dismissLoadingScreen()
    }

    override func loadView() {

        // set mapView with settings
        let camera = GMSCameraPosition.camera(withLatitude: 42.446179, longitude: -76.485070, zoom: defaultZoom)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: drawerDisplayController?.summaryViewHeight ?? 0, right: 0)
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
        
        if justLoaded { drawMapRoute(); justLoaded = false }
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
            for route in route.paths {
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

        let paths = newPaths ?? route.paths
        
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

}
