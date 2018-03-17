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
import SwiftRegister

class RouteDetailContentViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var isBannerShown: Bool = false
    var loadingView: UIView!
    var drawerDisplayController: RouteDetailDrawerViewController?
    
    var locationManager = CLLocationManager()
    
    var mapView: GMSMapView!
    var currentLocation: CLLocationCoordinate2D?
    var bounds = GMSCoordinateBounds()

    var networkTimer: Timer? = nil
    
    /// Number of seconds to wait before auto-refreshing network call, timed with live indicator
    var networkRefreshRate: Double = LiveIndicator.INTERVAL * 1.0
    
    var buses = [GMSMarker]()
    var banner: StatusBarNotificationBanner? = nil

    var route: Route!
    var directions: [Direction] = []
    var paths: [Path] = []

    let main = UIScreen.main.bounds

    let markerRadius: CGFloat = 8
    let mapPadding: CGFloat = 80
    
    let minZoom: Float = 12
    let defaultZoom: Float = 15.5
    let maxZoom: Float = 25

    /** Initalize RouteDetailViewController. Be sure to send a valid route, otherwise
     * dummy data will be used. The directions parameter have logical assumptions,
     * such as ArriveDirection always comes after DepartDirection. */
    init (route: Route) {
        super.init(nibName: nil, bundle: nil)
        initializeRoute(route: route)
    }

    /** Construct Directions based on Route and parse Waypoint / Path data */
    func initializeRoute(route: Route) {

        self.route = route
        self.directions = route.directions
        
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

                }

                let waypoint = Waypoint(lat: point.latitude, long: point.longitude, wpType: type)
                waypoints.append(waypoint)

            }

            let path = direction.type == .walk ? WalkPath(waypoints) : BusPath(waypoints)
            paths.append(path)

        }
        
        drawerDisplayController = RouteDetailDrawerViewController(route: route)

    }

    required convenience init(coder aDecoder: NSCoder) {
        let route = aDecoder.decodeObject(forKey: "route") as! Route
        self.init(route: route)
    }
    
    // MARK: View-Related Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Location Manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Set up Share button
        let shareButton = UIBarButtonItem(image: #imageLiteral(resourceName: "share"), style: .plain, target: self, action: #selector(shareRoute))
        shareButton.tintColor = .primaryTextColor
        guard let routeDetailViewController = self.parent as? RouteDetailViewController else { return }
        routeDetailViewController.navigationItem.setRightBarButton(shareButton, animated: true)
        
        // Fake Bus
        let bus = BusLocation(dataType: .validData, destination: "", deviation: 0, delay: 0, direction: "", displayStatus: "", gpsStatus: 0, heading: 0, lastStop: "", lastUpdated: Date(), latitude: 42.4491411, longitude: -76.4836815, name: 16, opStatus: "", routeID: "", runID: 0, speed: 0, tripID: "", vehicleID: 0)
        let coords = CLLocationCoordinate2D(latitude: 42.4491411, longitude: -76.4836815)
        let marker = GMSMarker(position: coords)
        (bus.iconView as? BusLocationView)?.updateBus(to: coords, with: Double(bus.heading))
        marker.iconView = bus.iconView
        marker.appearAnimation = .pop
        setIndex(of: marker, with: .bussing)
        marker.userData = bus
        marker.map = mapView
        buses.append(marker)
        
        // Fake Marker
//        let marker2 = GMSMarker(position: coords)
//        marker2.appearAnimation = .pop
//        marker2.zIndex = 10000
//        marker2.map = mapView

    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            let top = view.safeAreaInsets.top
            let bottom = drawerDisplayController?.summaryView.frame.height ?? 0
            mapView.padding = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
        } else {
            print("Setting Padding pre-iOS 11")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let timer = networkTimer {
            timer.invalidate()
        }

        networkTimer = Timer.scheduledTimer(timeInterval: networkRefreshRate, target: self, selector: #selector(getBusLocations),
                                            userInfo: nil, repeats: true)
        networkTimer!.fire()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        networkTimer?.invalidate()
        networkTimer = nil
        UIApplication.shared.statusBarStyle = .default
        banner?.dismiss()
        banner = nil
    }

    override func loadView() {

        // Set mapView with settings
        let camera = GMSCameraPosition.camera(withLatitude: 42.446179, longitude: -76.485070, zoom: defaultZoom)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.setMinZoom(minZoom, maxZoom: maxZoom)
        mapView.settings.tiltGestures = false
        mapView.settings.indoorPicker = false
        mapView.isBuildingsEnabled = false
        mapView.isIndoorEnabled = false
        
        // Pre-iOS 11 padding. See viewDidLoad for iOS 11 version
        let top = (navigationController?.navigationBar.frame.height ?? 44) + UIApplication.shared.statusBarFrame.height
        let bottom = drawerDisplayController?.summaryView.frame.height ?? 0
        mapView.padding = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)

        // Most extreme points on TCAT Route map
        let north = 42.61321283145329
        let east = -76.28125469914926
        let south = 42.32796328578829
        let west = -76.67690943302259

        let northEast = CLLocationCoordinate2D(latitude: north, longitude: east)
        let southWest = CLLocationCoordinate2D(latitude: south, longitude: west)
        let panBounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        mapView.cameraTargetBounds = panBounds

        self.mapView = mapView
        view = mapView
        
    }

    // MARK: Status Bar Functions
    
    /// Show banner if no other status banner exists; turns status bar light
    func showBanner(_ message: String, status: BannerStyle) {
        if self.banner == nil {
            self.banner = StatusBarNotificationBanner(title: message, style: status)
            self.banner!.autoDismiss = false
            self.banner!.dismissOnTap = true
            self.banner!.show(queuePosition: .front, on: navigationController)
            self.isBannerShown = true
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    /// Dismisses and removes banner; turns status bar back to default
    func hideBanner() {
        self.banner?.dismiss()
        self.isBannerShown = false
        self.banner = nil
        UIApplication.shared.statusBarStyle = .default
    }
    
    // MARK: Programmatic Layout Constants
    
    /** Return height of status bar and possible navigation controller */
    func statusNavHeight() -> CGFloat {
        
        let navBarHeight = navigationController?.navigationBar.frame.height ?? 0
        
        if #available(iOS 11.0, *) {
            return navBarHeight + (navigationController?.view.safeAreaInsets.top ?? 0)
        } else {
            return navBarHeight + UIApplication.shared.statusBarFrame.height
        }

    }
    
    // MARK: Location Manager Functions
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newCoord = locations.last?.coordinate {
            bounds = bounds.includingCoordinate(newCoord)
            currentLocation = newCoord
        }
        didUpdateLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("RouteDetailVC CLLocationManager didFailWithError: \(error)")
        didUpdateLocation()
    }
    
    /// Completion after locationManager functions return
    func didUpdateLocation() {
        drawMapRoute()
        centerMap(topHalfCentered: true)
        // (self.parent as? PulleyViewController)?.bounceDrawer()
    }
    
    // MARK: Live Tracking Functions
    
    // Kepp track of statuses of bus routes throughout view life cycle
    var noDataRouteList: [Int] = []

    /** Fetch live-tracking information for the first direction's bus route. Handles connection issues with banners. */
    @objc func getBusLocations() {
        
        let directionsAreValid = route.directions.reduce(true) { (result, direction) in
            if direction.type == .depart {
                return result && direction.routeNumber > 0 && direction.tripIdentifiers != nil
            } else {
                return true
            }
        }
        
        if !directionsAreValid {
            print("getBusLocations - Directions are not valid")
            return
        }
        
        Network.getBusLocations(route.directions).perform(withSuccess: { (result) in
            
            var results: [BusDataType] = []
            
            for busLocation in result.busLocations {
                
                results.append(busLocation.dataType)
                
                switch busLocation.dataType {
                    
                case .noData:
                    // print("No Data for", direction.routeNumber)
                    
                    if !self.noDataRouteList.contains(busLocation.routeNumber) {
                        self.noDataRouteList.append(busLocation.routeNumber)
                    }
                    
                    var message = ""
                    if self.noDataRouteList.count > 1 {
                        message = "No live tracking available for routes"
                    } else {
                        message = "No live tracking available for Route \(busLocation.routeNumber)"
                    }
                    
                    self.showBanner(message, status: .info)
                    
                case .invalidData:
                    // print("Invalid Data for", direction.routeNumber)
                    
                    if let previouslyUnavailableRoute = self.noDataRouteList.index(of: busLocation.routeNumber) {
                        self.noDataRouteList.remove(at: previouslyUnavailableRoute)
                    }
                    
                    if self.noDataRouteList.isEmpty {
                        self.hideBanner()
                    }
                    
                    self.showBanner("Tracking available near departure time", status: .info)
                    
                case .validData:
                    // print("Valid Data for", direction.routeNumber)
                    
                    if let previouslyUnavailableRoute = self.noDataRouteList.index(of: busLocation.routeNumber) {
                        self.noDataRouteList.remove(at: previouslyUnavailableRoute)
                    }
                    
                    if self.noDataRouteList.isEmpty {
                        self.hideBanner()
                    }
                    
                    self.setBusLocation(busLocation)
                    
                } // switch end
                
            } // busLocations for loop end
            
        }) { (error) in
            
            print("RouteDetailVC getBusLocations Error:", error)
            self.showBanner("Cannot connect to live tracking", status: .danger)
            
        } // network completion handler end
        
    }

    /** Update the map with new busLocations, adding or replacing based on vehicleID.
        If `validTripIDs` is passed in, only buses that match the tripID will be drawn.
        The input includes every bus associated with a certain line.
     */
    func setBusLocation(_ bus: BusLocation) {
        
        let busCoords = CLLocationCoordinate2D(latitude: bus.latitude, longitude: bus.longitude)
        let existingBus = buses.first(where: {
            return ($0.userData as? BusLocation)?.vehicleID == bus.vehicleID
        })
        
        // If bus is already on map, update and animate change
        if let newBus = existingBus {
            
            /// Allow time to receive new live bus request
            let latencyConstant = 0.25
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(networkRefreshRate + latencyConstant)
            newBus.appearAnimation = .none
            newBus.userData = bus
            (newBus.iconView as? BusLocationView)?.updateBus(from: existingBus!.position, to: busCoords)
            newBus.position = busCoords
            CATransaction.commit()
            
        }
            
        // Otherwise, add bus to map
        else {
            
            let marker = GMSMarker(position: busCoords)
            (bus.iconView as? BusLocationView)?.updateBus(to: busCoords, with: Double(bus.heading))
            marker.iconView = bus.iconView
            marker.appearAnimation = .pop
            setIndex(of: marker, with: .bussing)
            marker.userData = bus
            marker.map = mapView
            buses.append(marker)
            
        }
        
    }
    
    // MARK: Share Function
    
    @objc func shareRoute() {
        presentShareSheet(for: route)
    }
    
    // MARK: Google Map View Delegate Functions
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        // print("didChange to", position)
        
        for bus in buses {
            
            guard let busLocationView = bus.iconView as? BusLocationView else { continue }
            let actualLocation = busLocationView.position!
            
            // Update
            if let placement = calculatePlacement(position: actualLocation, view: busLocationView) {
                bus.position = placement
                print("calculated position:", placement)
                let bearing = calculateBearing(from: placement, to: actualLocation)
                print("bearing:", bearing)
                // busLocationView.updateBus(with: bearing)
                busLocationView.setCircle(isVisible: false)
            } else {
                // No placement needed
                bus.position = actualLocation
                busLocationView.setCircle(isVisible: true)
            }
            
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("idle")
        for bus in buses {
            guard let busLocationView = bus.iconView as? BusLocationView else { continue }
            let actualLocation = busLocationView.position!
            let bearing = calculateBearing(from: bus.position, to: actualLocation)
            print("bearing:", bearing)
            busLocationView.updateBus(with: bearing)
        }
    }
    
    func calculatePlacement(position: CLLocationCoordinate2D, view: BusLocationView) -> CLLocationCoordinate2D? {
        
        let padding: CGFloat = 16
        let bounds = mapView.projection.visibleRegion()
        
        var topOffset: Double {
            let origin = mapView.projection.coordinate(for: CGPoint(x: 0, y: 0)).latitude
            let withHeight = mapView.projection.coordinate(for: CGPoint(x: 0, y: view.frame.height)).latitude
            return origin - withHeight
        }
        var sideOffset: Double {
            let origin = mapView.projection.coordinate(for: CGPoint(x: 0, y: 0)).latitude
            let withHeight = mapView.projection.coordinate(for: CGPoint(x: view.frame.width / 2, y: 0)).latitude
            return abs(origin - withHeight)
        }
        
        let top = bounds.farLeft.latitude - topOffset
        let bottom = bounds.nearRight.latitude
        let left = bounds.nearLeft.longitude - sideOffset
        let right = bounds.nearRight.longitude + sideOffset
        
        let pastTopEdge = position.latitude > top
        let pastBottomEdge = position.latitude < bottom
        let pastLeftEdge = position.longitude < left
        let pastRightEdge = position.longitude > right
        
        //        GMSVisibleRegion(
        //            nearLeft: __C.CLLocationCoordinate2D(latitude: 42.442794190761489, longitude: -76.489242129027843),
        //            nearRight: __C.CLLocationCoordinate2D(latitude: 42.442794190761489, longitude: -76.479822881519794),
        //            farLeft: __C.CLLocationCoordinate2D(latitude: 42.456138223033271, longitude: -76.489242129027843),
        //            farRight: __C.CLLocationCoordinate2D(latitude: 42.456138223033271, longitude: -76.479822881519794)
        //        )
        
        // Set coordinate to most extreme on-screen map point if off screen
        var newPosition = position
        if pastRightEdge {
            newPosition.longitude = right
        }
        if pastLeftEdge {
            newPosition.longitude = left
        }
        if pastBottomEdge {
            newPosition.latitude = bottom
        }
        if pastTopEdge {
            newPosition.latitude = top
        }
        
        // Convert coordinate to point and adjust based on frame and padding
        // The actual point is at the maxY and centerX of the view
        var point = mapView.projection.point(for: newPosition)
        if pastRightEdge {
            point.x -= (view.frame.width / 2) + padding
        }
        if pastLeftEdge {
            point.x += (view.frame.width / 2) + padding
        }
        if pastTopEdge {
            point.y += padding
        }
        if pastBottomEdge {
            var inset: CGFloat = 0
            if #available(iOS 11.0, *) {
                inset = view.safeAreaInsets.bottom
            }
            point.y -= padding + inset
        }
        
        // If no change needed, return nil.
        if pastRightEdge || pastLeftEdge || pastTopEdge || pastBottomEdge {
            return mapView.projection.coordinate(for: point)
        } else {
            return nil
        }
        
    }
    
    func calculateBearing(from marker: CLLocationCoordinate2D, to location: CLLocationCoordinate2D) -> Double {
        
        func getBearingBetween(_ point1: CLLocationCoordinate2D, _ point2: CLLocationCoordinate2D) -> Double {
            
            func degreesToRadians(_ degrees: Any) -> Double {
                let value = degrees as? Double ?? Double(degrees as! Int)
                return value * .pi / 180
            }
            
            func radiansToDegrees(_ radians: Any) -> Double {
                let value = radians as? Double ?? Double(radians as! Int)
                return value * 180 / .pi
            }
            
            let lat1 = degreesToRadians(point1.latitude)
            let lon1 = degreesToRadians(point1.longitude)
            let lat2 = degreesToRadians(point2.latitude)
            let lon2 = degreesToRadians(point2.longitude)
            
            let dLon = lon2 - lon1
            
            let y = sin(dLon) * cos(lat2)
            let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
            let radiansBearing = atan2(y, x)
            
            return radiansToDegrees(radiansBearing)
            
        }
        
        return (getBearingBetween(location, marker) + 360).truncatingRemainder(dividingBy: 360)
        
    }
    
    // MARK: Map Functions

    /** Centers map around all waypoints in routePaths, and animates the map */
    func centerMap(topHalfCentered: Bool = false) {
        
        // Note: Can use mapView.move(with: GMSCameraUpdate) instead of mapView.animate

        if topHalfCentered {
            let bottom = (main.height / 2) - (mapPadding / 2)
            let edgeInsets = UIEdgeInsets(top: mapPadding, left: mapPadding / 2, bottom: bottom, right: mapPadding / 2)
            let update = GMSCameraUpdate.fit(bounds, with: edgeInsets)
            mapView.animate(with: update)
        }

        else {
            let update = GMSCameraUpdate.fit(bounds, withPadding: mapPadding)
            mapView.animate(with: update)
        }

    }
    
    func setIndex(of marker: GMSMarker, with waypointType: WaypointType) {
        marker.zIndex = {
            switch waypointType {
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

        let paths = newPaths ?? self.paths
        
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
                    setIndex(of: marker, with: waypoint.wpType)
                
//                }
                
                bounds = bounds.includingCoordinate(waypoint.coordinate)
                
            }
            
        }
        
        if newPaths != nil {
            centerMap(topHalfCentered: true)
        }

    }

}
