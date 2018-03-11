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

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        networkTimer = Timer.scheduledTimer(timeInterval: networkRefreshRate, target: self, selector: #selector(getBusLocations),
                                            userInfo: nil, repeats: true)
        networkTimer!.fire()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        networkTimer?.invalidate()
        networkTimer = nil
        banner = nil
    }

    override func loadView() {

        // set mapView with settings
        let camera = GMSCameraPosition.camera(withLatitude: 42.446179, longitude: -76.485070, zoom: defaultZoom)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: drawerDisplayController?.summaryView.frame.height ?? 0, right: 0)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.setMinZoom(minZoom, maxZoom: maxZoom)
        mapView.settings.tiltGestures = false

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
        
        drawMapRoute()
        centerMap(topHalfCentered: true)
        
        // (self.parent as? PulleyViewController)?.bounceDrawer()
        
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("RouteDetailVC CLLocationManager didFailWithError: \(error)")
    }
    
    // MARK: Live Tracking Functions
    
    // Kepp track of statuses of bus routes throughout view life cycle
    var noDataRouteList: [Int] = []

    /** Fetch live-tracking information for the first direction's bus route. Handles connection issues with banners. */
    @objc func getBusLocations() {
        
        for direction in route.directions {
            
            if direction.type == .depart && direction.routeNumber > 0 {
                guard let tripId = direction.tripIDs?.first else {
                    continue
                }
                Network.getBusLocations(routeID: String(direction.routeNumber),
                                        tripID: tripId,
                                        stopID: direction.startLocation.id)
                    
                .perform(withSuccess: { (result) in
                    
                    var results: [BusDataType] = []
                    
                        if let busLocation = result.busLocation {
                            
                            results.append(busLocation.dataType)
                            
                            switch busLocation.dataType {
                            
                            case .noData:
                                // print("No Data for", direction.routeNumber)
                                
                                if !self.noDataRouteList.contains(direction.routeNumber) {
                                    self.noDataRouteList.append(direction.routeNumber)
                                }
                                
                                var message = ""
                                if self.noDataRouteList.count > 1 {
                                    message = "No live tracking available for routes"
                                } else {
                                    message = "No live tracking available for Route \(direction.routeNumber)"
                                }
                                
                                self.showBanner(message, status: .info)
                                
                            case .invalidData:
                                // print("Invalid Data for", direction.routeNumber)
                                
                                if let previouslyUnavailableRoute = self.noDataRouteList.index(of: direction.routeNumber) {
                                    self.noDataRouteList.remove(at: previouslyUnavailableRoute)
                                }
                                
                                if self.noDataRouteList.isEmpty {
                                    self.hideBanner()
                                }
                                
                                self.showBanner("Tracking available near departure time", status: .info)
                                
                            case .validData:
                                 // print("Valid Data for", direction.routeNumber)
                                
                                 if let previouslyUnavailableRoute = self.noDataRouteList.index(of: direction.routeNumber) {
                                    self.noDataRouteList.remove(at: previouslyUnavailableRoute)
                                 }
                                 
                                 if self.noDataRouteList.isEmpty {
                                    self.hideBanner()
                                 }
                                 
                                 self.setBusLocation(busLocation)
                                
                            } // switch end
                            
                        } else {
                            print("Error: Successful response, but no content. Likely client-side issue")
                        }
                        
                }) { (error) in
                    
                    print("RouteDetailVC getBusLocations Error:", error)
                    self.showBanner("Cannot connect to live tracking", status: .danger)
                    
                } // network completion handler end
                
            } // depart conditional end
            
        } // for loop end

    }

    /** Update the map with new busLocations, adding or replacing based on vehicleID.
        If `validTripIDs` is passed in, only buses that match the tripID will be drawn.
        The input includes every bus associated with a certain line.
     */
    func setBusLocation(_ bus: BusLocation) {
        
        let busCoords = CLLocationCoordinate2DMake(bus.latitude, bus.longitude)
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
            (newBus.iconView as? BusLocationView)?.setBearing(bus.heading, start: existingBus!.position, end: busCoords)
            newBus.position = busCoords
            CATransaction.commit()
            
        }
            
        // Otherwise, add bus to map
        else {
            
            let marker = GMSMarker(position: busCoords)
            (bus.iconView as? BusLocationView)?.setBearing(bus.heading)
            marker.iconView = bus.iconView
            marker.appearAnimation = .pop
            setIndex(of: marker, with: .bussing)
            marker.userData = bus
            marker.map = mapView
            buses.append(marker)
            
        }
        
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
