//
//  RouteDetailViewController.swift
//  TCAT
//
//  Created by Matthew Barker on 2/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import CoreLocation
import FutureNova
import GoogleMaps
import MapKit
import NotificationBannerSwift
import Pulley
import SwiftyJSON
import UIKit

class RouteDetailContentViewController: UIViewController {

    private var drawerDisplayController: RouteDetailDrawerViewController?

    // Keep track of statuses of bus routes throughout view life cycle
    var noDataRouteList: [Int] = []

    private var bounds = GMSCoordinateBounds()
    private var busIndicators = [GMSMarker]()
    private var buses = [GMSMarker]()
    private var currentLocation: CLLocationCoordinate2D?
    private var directions: [Direction] = []
    private var initalUpdate: Bool = true
    /// Number of seconds to wait before auto-refreshing live tracking network call call, timed with live indicator
    private var liveTrackingNetworkRefreshRate: Double = LiveIndicator.INTERVAL * 1.0
    private var liveTrackingNetworkTimer: Timer?
    private var locationManager = CLLocationManager()
    private var mapView: GMSMapView!
    private let networking: Networking = URLSession.shared.request
    private var paths: [Path] = []
    private var route: Route!
    private var routeOptionsCell: RouteTableViewCell?

    private var banner: StatusBarNotificationBanner? {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    private let mapPadding: CGFloat = 80
    private let markerRadius: CGFloat = 8

    /** Initalize RouteDetailViewController. Be sure to send a valid route, otherwise
     * dummy data will be used. The directions parameter have logical assumptions,
     * such as ArriveDirection always comes after DepartDirection. */
    init(route: Route, currentLocation: CLLocationCoordinate2D?, routeOptionsCell: RouteTableViewCell?) {
        super.init(nibName: nil, bundle: nil)
        self.routeOptionsCell = routeOptionsCell
        initializeRoute(route, currentLocation)
    }

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
        shareButton.tintColor = Colors.primaryText
        guard let routeDetailViewController = self.parent as? RouteDetailViewController else { return }
        routeDetailViewController.navigationItem.setRightBarButton(shareButton, animated: true)

        // Debug Function
//        createDebugBusIcon()
    }

    /** Construct Directions based on Route and parse Waypoint / Path data */
    func initializeRoute(_ route: Route, _ currentLocation: CLLocationCoordinate2D?) {
        self.route = route
        self.directions = route.directions
        self.currentLocation = currentLocation

        let isWalkingRoute = directions.reduce(true) { $0 && $1.type == .walk }
        // Plot the paths of all directions
        for (arrayIndex, direction) in directions.enumerated() {
            var waypoints: [Waypoint] = []
            for (pathIndex, point) in direction.path.enumerated() {
                let isStop: Bool = direction.type != .walk
                var typeNotSet = true
                var type: WaypointType = .none {
                    didSet {
                        typeNotSet = false
                    }
                }

                // First Direction
                if arrayIndex == 0 {
                    // First Waypoint
                    if pathIndex == 0 {
                        if currentLocation == nil || isWalkingRoute {
                            type = .origin
                        }
                    }
                    // Last Waypoint
                    else if pathIndex == direction.path.count - 1 {
                        // Handle when first == last
                        if directions.count == 1 {
                            type = .destination
                        } else {
                            type = isStop ? .bus : .none
                        }
                    }
                }

                // Last Direction
                if typeNotSet && arrayIndex == directions.count - 1 {
                    // First Waypoint
                    if pathIndex == 0 {
                        type = isStop ? .bus : .none
                    }
                    // Last Waypoint
                    else if pathIndex == direction.path.count - 1 {
                        type = .destination
                    }
                }

                // First & Last Bus Segments
                if typeNotSet && direction.type == .depart && (pathIndex == 0 || pathIndex == direction.path.count - 1) {
                    type = .bus
                }

                let waypoint = Waypoint(lat: point.latitude, long: point.longitude, wpType: type, isStop: isStop)
                waypoints.append(waypoint)
            }

            let path = direction.type == .walk ? WalkPath(waypoints) : BusPath(waypoints)
            paths.append(path)
        }

        drawerDisplayController = RouteDetailDrawerViewController(route: route)
    }

    // MARK: Status Bar Functions

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return banner != nil ? .lightContent : .default
    }

    /// Show banner if no other status banner exists; turns status bar light
    private func showBanner(_ message: String, status: BannerStyle) {
        hideBanner()
        self.banner = StatusBarNotificationBanner(title: message, style: status)

        // Change default colors for specific banners
        if status == .info {
            self.banner?.backgroundColor = Colors.dividerTextField
        }

        self.banner?.autoDismiss = false
        self.banner?.dismissOnTap = true
        self.banner?.show(queuePosition: .front, on: navigationController)
    }

    /// Dismisses and removes banner; turns status bar back to default
    private func hideBanner() {
        self.banner?.dismiss()
        self.banner = nil
    }

    // MARK: Network Calls

    private func busLocations(_ directions: [Direction]) -> Future<Response<[BusLocation]>> {
        return networking(Endpoint.getBusLocations(directions)).decode()
    }

    /** Fetch live-tracking information for the first direction's bus route.
     Handles connection issues with banners. Animated indicators */
    @objc private func getBusLocations() {

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

        busLocations(route.directions).observe { [weak self] result in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .value(let response):
                    var results = [BusDataType]()
                    if response.data.isEmpty {
                        // Reset banner in case transitioned from Error to Online - No Bus Locations
                        self.hideBanner()
                    }

                    for busLocation in response.data {
                        results.append(busLocation.dataType)
                        switch busLocation.dataType {
                        case .noData:
                            if !self.noDataRouteList.contains(busLocation.routeNumber) {
                                self.noDataRouteList.append(busLocation.routeNumber)
                            }
                        case .invalidData:
                            if let previouslyUnavailableRoute = self.noDataRouteList.firstIndex(of: busLocation.routeNumber) {
                                self.noDataRouteList.remove(at: previouslyUnavailableRoute)
                            }
                            if self.noDataRouteList.isEmpty {
                                self.hideBanner()
                            }
                            self.showBanner(Constants.Banner.trackingLater, status: .info)

                        case .validData:
                            if let previouslyUnavailableRoute = self.noDataRouteList.firstIndex(of: busLocation.routeNumber) {
                                self.noDataRouteList.remove(at: previouslyUnavailableRoute)
                            }
                            if self.noDataRouteList.isEmpty {
                                self.hideBanner()
                            }
                            self.setBusLocation(busLocation)
                        }
                }
                case .error(let error):
                    print("RouteDetailVC getBusLocations Error:", error.localizedDescription)
                    if let banner = self.banner, !banner.isDisplaying {
                        self.showBanner(Constants.Banner.cannotConnectLive, status: .danger)
                    }
                }
            }
        }
        // Bounce any visible indicators
        bounceIndicators()
    }

    /** Update the map with new busLocations, adding or replacing based on vehicleID.
     If `validTripIDs` is passed in, only buses that match the tripID will be drawn.
     The input includes every bus associated with a certain line. Any visible indicators
     are also animated
     */
    private func setBusLocation(_ bus: BusLocation) {

        /// New bus coordinates
        let busCoords = CLLocationCoordinate2D(latitude: bus.latitude, longitude: bus.longitude)
        let existingBus = buses.first(where: {
            return getUserData(for: $0, key: Constants.BusUserData.vehicleID) as? Int == bus.vehicleID
        })

        // If bus is already on map, update and animate change
        if let newBus = existingBus {

            /// Allow time to receive new live bus request
            let latencyConstant = 0.25

            CATransaction.begin()
            CATransaction.setAnimationDuration(liveTrackingNetworkRefreshRate + latencyConstant)

            newBus.appearAnimation = .none

            updateUserData(for: newBus, with: [
                Constants.BusUserData.actualCoordinates: busCoords,
                Constants.BusUserData.vehicleID: bus.vehicleID
                ])

            // Position
            newBus.position = busCoords

            CATransaction.commit()

        }

            // Otherwise, add bus to map
        else {

            guard let iconView = bus.iconView as? BusLocationView else { return }
            let marker = GMSMarker(position: busCoords)
            marker.appearAnimation = .pop
            marker.iconView = iconView

            updateUserData(for: marker, with: [
                Constants.BusUserData.actualCoordinates: busCoords,
                Constants.BusUserData.vehicleID: bus.vehicleID
                ])

            setIndex(of: marker, with: .bussing)
            marker.map = mapView
            buses.append(marker)

        }

        // Update bus indicators (if map not moved)
        mapView.delegate?.mapView?(mapView, didChange: mapView.camera)

    }

    /// Animate any visible indicators
    private func bounceIndicators() {
        for indicator in busIndicators {
            guard let originalFrame = indicator.iconView?.frame else { continue }
            guard let originalTransform = indicator.iconView?.transform else { continue }
            let insetValue = originalFrame.size.width / 24
            indicator.iconView?.transform = CGAffineTransform(scaleX: insetValue, y: insetValue)
            UIView.animate(withDuration: LiveIndicator.DURATION * 2, delay: 0, usingSpringWithDamping: 1,
                           initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                            indicator.iconView?.transform = originalTransform
            })
        }
    }

    // MARK: Share Function
    @objc func shareRoute() {
        presentShareSheet(from: view, for: route, with: routeOptionsCell?.getImage())
    }

    private func calculatePlacement(position: CLLocationCoordinate2D, view: UIView) -> CLLocationCoordinate2D? {

        let padding: CGFloat = 16
        let bounds = mapView.projection.visibleRegion()
        let isPartiallyRevealed = (parent as? RouteDetailViewController)?.drawerPosition == .partiallyRevealed

        var topOffset: Double {
            let origin = mapView.projection.coordinate(for: CGPoint(x: 0, y: 0)).latitude
            let withHeight = mapView.projection.coordinate(for: CGPoint(x: 0, y: view.frame.size.height)).latitude
            return origin - withHeight
        }
        var sideOffset: Double {
            let origin = mapView.projection.coordinate(for: CGPoint(x: 0, y: 0)).latitude
            let withHeight = mapView.projection.coordinate(for: CGPoint(x: view.frame.size.width, y: 0)).latitude
            return abs(origin - withHeight)
        }
        var bottomOffset: Double {
            let constant = isPartiallyRevealed ? UIScreen.main.bounds.height / 2 - mapView.padding.bottom : 0
            let origin = mapView.projection.coordinate(for: CGPoint(x: 0, y: 0)).latitude
            let withHeight = mapView.projection.coordinate(for: CGPoint(x: 0, y: constant + view.frame.size.height)).latitude
            return origin - withHeight
        }

        let top = bounds.farLeft.latitude - topOffset
        let bottom = bounds.nearRight.latitude + bottomOffset
        let left = bounds.nearLeft.longitude - sideOffset
        let right = bounds.nearRight.longitude + sideOffset

        let pastTopEdge = position.latitude > top
        let pastBottomEdge = position.latitude < bottom
        let pastLeftEdge = position.longitude < left
        let pastRightEdge = position.longitude > right

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
            point.x -= (view.frame.size.width / 2) + padding
        }
        if pastLeftEdge {
            point.x += (view.frame.size.width / 2) + padding
        }
        if pastTopEdge {
            point.y += padding - (view.frame.size.height / 2)
        }
        if pastBottomEdge {
            let constant = isPartiallyRevealed ? 0 : view.frame.size.height
            point.y -= padding + constant
        }

        // If no change needed, return nil.
        if pastRightEdge || pastLeftEdge || pastTopEdge || pastBottomEdge {
            return mapView.projection.coordinate(for: point)
        } else {
            return nil
        }

    }

    private func calculateBearing(from marker: CLLocationCoordinate2D, to location: CLLocationCoordinate2D) -> Double {
        func degreesToRadians(_ degrees: Any) -> Double {
            let value = degrees as? Double ?? Double(degrees as! Int)
            return value * .pi / 180
        }

        func radiansToDegrees(_ radians: Any) -> Double {
            let value = radians as? Double ?? Double(radians as! Int)
            return value * 180 / .pi
        }

        let lat1 = degreesToRadians(location.latitude)
        let lon1 = degreesToRadians(location.longitude)
        let lat2 = degreesToRadians(marker.latitude)
        let lon2 = degreesToRadians(marker.longitude)

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        return (radiansToDegrees(radiansBearing) + 360).truncatingRemainder(dividingBy: 360)

    }

    // MARK: Map Functions

    /** Centers map around all waypoints in routePaths, and animates the map */
    func centerMapOnOverview(drawerPreviewing: Bool = false) {

        var bottomOffset: CGFloat = (UIScreen.main.bounds.height / 2) - (mapPadding / 2)

        bottomOffset -= view.safeAreaInsets.bottom

        if drawerPreviewing {
            let edgeInsets = UIEdgeInsets(top: mapPadding / 2, left: mapPadding / 2, bottom: bottomOffset, right: mapPadding / 2)
            let update = GMSCameraUpdate.fit(bounds, with: edgeInsets)
            mapView.animate(with: update)
        } else {
            let update = GMSCameraUpdate.fit(bounds, withPadding: mapPadding)
            mapView.animate(with: update)
        }

    }

    func centerMap(on direction: Direction, isOverviewOfPath: Bool = false, drawerPreviewing: Bool = false) {

        let path = GMSMutablePath()
        if isOverviewOfPath {
            direction.path.forEach { loc in path.add(loc) }
        } else {
            path.add(direction.startLocation)
        }
        let bounds = GMSCoordinateBounds(path: path)
        let update = GMSCameraUpdate.fit(bounds, withPadding: mapPadding)
        mapView.animate(with: update)
        if !isOverviewOfPath {
            mapView.animate(toZoom: Constants.Map.directionZoom)
        }
    }

    private func setIndex(of marker: GMSMarker, with waypointType: WaypointType) {
        marker.zIndex = {
            switch waypointType {
            case .bus: return 1
            case .walk: return 1
            case .origin: return 3
            case .destination: return 3
            case .stop: return 1
            case .walking: return 0
            // For live bus icon / indicators
            case .bussing: return 999 // large constant to place above other elements
            default: return 0
            }
        }()
    }

    /** Draw all waypoints initially for all paths in [Path] or [[CLLocationCoordinate2D]], plus fill bounds */
    private func drawMapRoute() {
        for path in paths {
            path.traveledPolyline.map = mapView
            path.map = mapView
            for waypoint in path.waypoints {
                let marker = GMSMarker(position: waypoint.coordinate)
                marker.iconView = waypoint.iconView
                marker.map = mapView
                setIndex(of: marker, with: waypoint.wpType)
                bounds = bounds.includingCoordinate(waypoint.coordinate)
            }
        }
    }

    /// Completion after locationManager functions return
    private func didUpdateLocation() {
        // TODO #267: Find better way to cut down on didUpdateLocation calls
        if initalUpdate {
            initalUpdate = false
            drawMapRoute()
            centerMapOnOverview(drawerPreviewing: true)
        }
    }

    func getDrawerDisplayController() -> RouteDetailDrawerViewController? {
        return drawerDisplayController
    }

    required convenience init(coder aDecoder: NSCoder) {
        let route = aDecoder.decodeObject(forKey: "route") as! Route
        self.init(route: route, currentLocation: nil, routeOptionsCell: nil)
    }
}

// MARK: View Life Cycle
extension RouteDetailContentViewController {

    override func viewSafeAreaInsetsDidChange() {
        let top = view.safeAreaInsets.top
        let bottom = view.safeAreaInsets.bottom + (drawerDisplayController?.summaryView.frame.height ?? 92)
        mapView.padding = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Live Tracking Network Timer
        liveTrackingNetworkTimer?.invalidate()
        if directions.contains(where: { $0.type != .walk }) {
            liveTrackingNetworkTimer = Timer.scheduledTimer(timeInterval: liveTrackingNetworkRefreshRate,
                                                            target: self,
                                                            selector: #selector(getBusLocations),
                                                            userInfo: nil,
                                                            repeats: true)
            liveTrackingNetworkTimer?.fire()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        liveTrackingNetworkTimer?.invalidate()
        hideBanner()
    }

    override func loadView() {
        // Set mapView with settings
        let camera = GMSCameraPosition.camera(withLatitude: Constants.Map.startingLat, longitude: Constants.Map.startingLong, zoom: Constants.Map.defaultZoom)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.paddingAdjustmentBehavior = .never // handled by code
        mapView.setMinZoom(Constants.Map.minZoom, maxZoom: Constants.Map.maxZoom)
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.settings.tiltGestures = false
        mapView.settings.indoorPicker = false
        mapView.isBuildingsEnabled = false
        mapView.isIndoorEnabled = false

        // Pre-iOS 11 padding. See viewDidLoad for iOS 11 version
        let top = (navigationController?.navigationBar.frame.height ?? 44) + UIApplication.shared.statusBarFrame.height
        let bottom = drawerDisplayController?.summaryView.frame.height ?? 0
        mapView.padding = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)

        let northEast = CLLocationCoordinate2D(latitude: Constants.Values.RouteMaxima.north, longitude: Constants.Values.RouteMaxima.east)
        let southWest = CLLocationCoordinate2D(latitude: Constants.Values.RouteMaxima.south, longitude: Constants.Values.RouteMaxima.west)
        let panBounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        mapView.cameraTargetBounds = panBounds

        self.mapView = mapView
        view = mapView
    }
}

// MARK: Location Manager Functions
extension RouteDetailContentViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newCoord = locations.last?.coordinate {
            currentLocation = newCoord
        }
        didUpdateLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("RouteDetailVC CLLocationManager didFailWithError: \(error)")
        didUpdateLocation()
    }
}

// MARK: Google Map View Delegate Functions
extension RouteDetailContentViewController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let coordinates = getUserData(for: marker, key: Constants.BusUserData.actualCoordinates) as? CLLocationCoordinate2D
            else { return true }
        let update = GMSCameraUpdate.setTarget(coordinates)
        mapView.animate(with: update)

        return true
    }

    func updateUserData(for marker: GMSMarker, with values: [String: Any]) {
        guard var userData = marker.userData as? [String: Any] else {
            marker.userData = values
            return
        }
        values.forEach { (key, value) in
            userData[key] = value
        }
        marker.userData = userData
    }

    func getUserData(for marker: GMSMarker, key: String) -> Any? {
        guard let userData = marker.userData as? [String: Any] else { return nil }
        return userData[key]
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        buses.forEach { bus in
            let bearingView = UIImageView(image: #imageLiteral(resourceName: "indicator"))
            bearingView.frame.size = CGSize(width: bearingView.frame.width / 2, height: bearingView.frame.height / 2)
            bearingView.tag = increaseTapTargetTag

            if let existingIndicator = busIndicators.first(where: {
                let markerID = getUserData(for: $0, key: Constants.BusUserData.vehicleID) as? Int
                let busID = getUserData(for: bus, key: Constants.BusUserData.vehicleID) as? Int
                return markerID == busID
            }) { // Update Indicator
                if let placement = calculatePlacement(position: bus.position, view: bearingView) {

                    // existingIndicator.map = nil // Uncomment to avoid animation
                    existingIndicator.position = placement
                    existingIndicator.rotation = calculateBearing(from: placement, to: bus.position)

                    updateUserData(for: existingIndicator, with: [
                        Constants.BusUserData.actualCoordinates: bus.position,
                        Constants.BusUserData.indicatorCoordinates: placement
                        ])

                    existingIndicator.appearAnimation = .none
                    // existingIndicator.map = mapView // Uncomment to avoid animation
                } else {
                    existingIndicator.map = nil
                    busIndicators.remove(at: busIndicators.firstIndex(of: existingIndicator)!)
                }
            } else { // Create Indicator
                if let placement = calculatePlacement(position: bus.position, view: bearingView) {

                    let indicator = GMSMarker(position: placement)
                    indicator.appearAnimation = .pop
                    indicator.rotation = calculateBearing(from: placement, to: bus.position)
                    indicator.iconView = bearingView
                    setIndex(of: indicator, with: .bussing)

                    updateUserData(for: indicator, with: [
                        Constants.BusUserData.actualCoordinates: bus.position,
                        Constants.BusUserData.indicatorCoordinates: placement,
                        Constants.BusUserData.vehicleID: getUserData(for: bus, key: Constants.BusUserData.vehicleID) as? Int ?? -1
                        ])

                    indicator.map = mapView
                    busIndicators.append(indicator)
                }
            }
        }
    }
}

// MARK: Debug
extension RouteDetailContentViewController {
    /// Create fake bus for debugging and testing bus indicators
    private func createDebugBusIcon() {
        let bus = BusLocation(dataType: .validData, destination: "", deviation: 0, delay: 0, direction: "", displayStatus: "", gpsStatus: 0, heading: 0, lastStop: "", lastUpdated: Date(), latitude: 42.4491411, longitude: -76.4836815, name: "16", opStatus: "", routeID: 10, runID: 0, speed: 0, tripID: 0, vehicleID: 0)
        let coords = CLLocationCoordinate2D(latitude: 42.4491411, longitude: -76.4836815)
        let marker = GMSMarker(position: coords)
        marker.iconView = bus.iconView
        marker.appearAnimation = .pop
        setIndex(of: marker, with: .bussing)
        updateUserData(for: marker, with: [
            Constants.BusUserData.actualCoordinates: coords,
            Constants.BusUserData.vehicleID: 123456789
            ])
        marker.map = mapView
        buses.append(marker)
    }
}
