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
    
    // Constants
    let polyline = Polyline()
    var waypoints: [Waypoint] = []
    
    // Variables
    var mapView: GMSMapView!

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
        waypoints = [Waypoint(lat: 42.444738, long: -76.489383),
                     Waypoint(lat: 42.445173, long: -76.485027),
                     Waypoint(lat: 42.445221, long: -76.481615)]
        
        drawMapRoute()
        drawStops()
    }
    
    // MARK: Map and Route Methods
    
    func drawRoute() {
        let path = GMSMutablePath(fromEncodedPath: polyline.overviewPolyline)
        let routePolyline = GMSPolyline(path: path)
        
        routePolyline.strokeColor = .tcatBlue
        routePolyline.strokeWidth = 5
        routePolyline.map = mapView
    }
    
    func drawMapRoute() {
        polyline.getPolyline(waypoints: waypoints)
        drawRoute()
    }
    
    func drawStops() {
        for waypoint in waypoints {
            let coords = CLLocationCoordinate2DMake(CLLocationDegrees(waypoint.lat), CLLocationDegrees(waypoint.long))
            let marker = GMSMarker(position: coords)
            
            // FIX: Placeholder stop icon
            let iconView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
            iconView.backgroundColor = .white
            iconView.layer.cornerRadius = iconView.frame.width / 2.0
            iconView.layer.masksToBounds = true
            iconView.layer.borderWidth = 2
            iconView.layer.borderColor = UIColor.black.cgColor
            
            marker.iconView = iconView
            marker.userData = waypoint
            marker.map = mapView
        }
    }
    
}
