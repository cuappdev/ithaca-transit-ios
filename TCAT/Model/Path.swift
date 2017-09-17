//
//  Path.swift
//  TCAT
//
//  Created by Annie Cheng on 2/24/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation
import SwiftyJSON
import GoogleMaps

enum PathType: String {
    case driving
    case walking
}

class Path: GMSPolyline {
    
    let dashLengths: [NSNumber] = [10, 10]
    
    var polylineWidth: CGFloat!
    var waypoints: [Waypoint] = []
    var traveledPolyline: GMSPolyline = GMSPolyline()
    var traveledPath: GMSMutablePath? = nil
    var untraveledPath: GMSMutablePath? = nil
    var pathType: PathType = .driving
    var color: UIColor = .black
    
    init(waypoints: [Waypoint], pathType: PathType, color: UIColor) {
        super.init()
        self.waypoints = waypoints
        self.pathType = pathType
        self.color = color
        
        self.polylineWidth = pathType == .driving ? 4 : 6
        self.untraveledPath = createPathFromWaypoints(waypoints: waypoints)
        self.traveledPath = untraveledPath
        
        self.path = untraveledPath
        self.strokeColor = color
        self.strokeWidth = polylineWidth
        
        if pathType == .walking {
            let untraveledDashStyles: [GMSStrokeStyle] = [.solidColor(color), .solidColor(.clear)]
            self.spans = GMSStyleSpans(untraveledPath!, untraveledDashStyles, dashLengths, .rhumb)
            self.strokeWidth -= 2
        }
        
    }
    
    func createPathFromWaypoints(waypoints: [Waypoint]) -> GMSMutablePath {
        let path = GMSMutablePath()
        for waypoint in waypoints {
            path.add(CLLocationCoordinate2D(latitude: waypoint.lat, longitude: waypoint.long))
        }
        return path
    }
    
}
