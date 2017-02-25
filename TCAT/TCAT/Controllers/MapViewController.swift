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
    var path: GMSMutablePath!
    var polyline: GMSPolyline!
    var routePath: Path!
    var waypoints: [Waypoint] = []

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
        routePath = Path(waypoints: waypoints, color: .tcatBlue)
        
        drawMapRoute()
        drawStops()
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
        path = GMSMutablePath(fromEncodedPath: routePath.overviewPolyline)
        polyline = GMSPolyline(path: path)
        polyline.strokeColor = routePath.color
        polyline.strokeWidth = 5
        polyline.map = mapView
        updateMapDrawing()
    }
    
    func updateMapDrawing() {
        polyline.path = path
        path.removeCoordinate(at: 0)
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
