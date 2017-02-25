//
//  MapViewController.swift
//  TCAT
//
//  Created by Annie Cheng on 2/24/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate {

    // Variables
    var mapView: GMSMapView!
    var route: [Path] = []
    var waypointsA: [Waypoint] = []
    var waypointsB: [Waypoint] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: 42.446179, longitude: -76.485070, zoom: 15.5)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.delegate = self
        self.mapView = mapView
        view = mapView
        
        // FIX: Placeholder waypoints for testing
        waypointsA = [Waypoint(lat: 42.444738, long: -76.489383, wpType: .Origin),
                     Waypoint(lat: 42.445173, long: -76.485027, wpType: .Stop),
                     Waypoint(lat: 42.445221, long: -76.481615, wpType: .None)]
        waypointsB = [Waypoint(lat: 42.445221, long: -76.481615, wpType: .Origin),
                     Waypoint(lat: 42.443147, long: -76.479534, wpType: .Destination)]
    
        let routePathA = Path(waypoints: waypointsA, color: .tcatBlue)
        let routePathB = Path(waypoints: waypointsB, color: .orange)
        route = [routePathA, routePathB]
        
        drawMapRoute()
        testDrawing()
    }
    
    // MARK: Map and Route Methods
    
    // Call this function to simulate travelling on route
    func testDrawing() {
        Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(self.updateMapDrawing),
                             userInfo: nil,
                             repeats: true)
    }
    
    func drawMapRoute() {
        for routePath in route {
            routePath.dottedPolyline.map = mapView
            routePath.map = mapView
            drawWaypoints(waypoints: routePath.waypoints)
        }
    }
    
    func updateMapDrawing() {
        for routePath in route {
            if let mutablePath = routePath.mutablePath {
                if mutablePath.count() > 0 {
                    routePath.path = mutablePath
                    routePath.mutablePath?.removeCoordinate(at: 0)
                    break
                }
            }
        }
    }
    
    func drawWaypoints(waypoints: [Waypoint]) {
        for waypoint in waypoints {
            let coords = CLLocationCoordinate2DMake(CLLocationDegrees(waypoint.lat), CLLocationDegrees(waypoint.long))
            let marker = GMSMarker(position: coords)
            marker.iconView = waypoint.iconView
            marker.userData = waypoint
            marker.map = mapView
        }
    }
    
}
