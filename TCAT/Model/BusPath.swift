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
    
    var waypoints: [Waypoint] = []
    var traveledPolyline: GMSPolyline = GMSPolyline()
    var color: UIColor = .clear
    
    init(waypoints: [Waypoint]) {
        
        self.waypoints = waypoints
        super.init()
        
    }
    
}

class BusPath: Path {
    
    // Length of dash corresponding to position in dashColors
    var dashLengths: [NSNumber] = [6, 4]
    // To be initialized with dash colors
    var dashColors = [UIColor]()
    
    var polylineWidth: CGFloat!
    var traveledPath: GMSMutablePath? = nil
    var untraveledPath: GMSMutablePath? = nil
    
    init(_ waypoints: [Waypoint]) {
        
        super.init(waypoints: waypoints)
        self.color = .tcatBlueColor
        
        dashColors = [color, .clear]
        
        self.polylineWidth = 8
        self.untraveledPath = createPathFromWaypoints(waypoints: waypoints)
        self.traveledPath = untraveledPath
        
        self.path = untraveledPath
        self.strokeColor = color
        self.strokeWidth = polylineWidth
        
//        if pathType == .walking {
//
//            let untraveledDashStyles = dashColors.flatMap { (color) -> GMSStrokeStyle in
//                return .solidColor(color)
//            }
//
//            self.spans = GMSStyleSpans(untraveledPath!, untraveledDashStyles, dashLengths, .projected)
//
//            self.geodesic = false
//
//            self.dashLengths = [NSNumber(value: self.untraveledPath!.length(of: .geodesic) / 100.0)]
//            setupStyle(with: color)
//            tick(untraveledDashStyles)
//
//        }
    
    }
    
    func createPathFromWaypoints(waypoints: [Waypoint]) -> GMSMutablePath {
        let path = GMSMutablePath()
        for waypoint in waypoints {
            path.add(waypoint.coordinate)
        }
        return path
    }
    
}
