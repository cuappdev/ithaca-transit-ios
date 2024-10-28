//
//  Path.swift
//  TCAT
//
//  Created by Annie Cheng on 2/24/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation
import GoogleMaps
import SwiftyJSON

enum PathType: String {
    case driving
    case walking
}

class Path: GMSPolyline {

    var color: UIColor = .clear
    var traveledPolyline: GMSPolyline = GMSPolyline()
    var waypoints: [Waypoint] = []

    init(waypoints: [Waypoint]) {
        self.waypoints = waypoints
        super.init()
    }

}

class BusPath: Path {

    /// To be initialized with dash colors
    var dashColors = [UIColor]()
    /// Length of dash corresponding to position in dashColors
    var dashLengths: [NSNumber] = [6, 4]

    var polylineWidth: CGFloat!
    var traveledPath: GMSMutablePath?
    var untraveledPath: GMSMutablePath?

    init(_ waypoints: [Waypoint]) {
        super.init(waypoints: waypoints)
        self.color = Colors.tcatBlue

        dashColors = [color, .clear]

        self.polylineWidth = 5
        self.untraveledPath = createPathFromWaypoints(waypoints: waypoints)
        self.traveledPath = untraveledPath

        self.path = untraveledPath
        self.strokeColor = color
        self.strokeWidth = polylineWidth
    }

    func createPathFromWaypoints(waypoints: [Waypoint]) -> GMSMutablePath {
        let path = GMSMutablePath()
        for waypoint in waypoints {
            path.add(waypoint.coordinate)
        }
        return path
    }

}
