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
    
    // Length of dash corresponding to position in dashColors
    let dashLengths: [NSNumber] = [6, 4]
    // To be initialized with dash colors
    var dashColors = [UIColor]()
    
    var polylineWidth: CGFloat!
    var waypoints: [Waypoint] = []
    var traveledPolyline: GMSPolyline = GMSPolyline()
    var traveledPath: GMSMutablePath? = nil
    var untraveledPath: GMSMutablePath? = nil
    var pathType: PathType = .driving
    var color: UIColor = .black
    
    init(waypoints: [Waypoint], pathType: PathType) {
        
        super.init()
        self.waypoints = waypoints
        self.pathType = pathType
        
        self.color = {
            switch pathType {
                case .driving: return .tcatBlueColor
                case .walking: return .mediumGrayColor
            }
        }()
        
        dashColors = [color, .clear]
        
        self.polylineWidth = pathType == .driving ? 4 : 6
        self.untraveledPath = createPathFromWaypoints(waypoints: waypoints)
        self.traveledPath = untraveledPath
        
        self.path = untraveledPath
        self.strokeColor = color
        self.strokeWidth = polylineWidth
        
        if pathType == .walking {
            let untraveledDashStyles = dashColors.flatMap { (color) -> GMSStrokeStyle in
                return .solidColor(color)
            }
            self.spans = GMSStyleSpans(untraveledPath!, untraveledDashStyles, dashLengths, .geodesic)
            // self.strokeWidth -= 2
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
