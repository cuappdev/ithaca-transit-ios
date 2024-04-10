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

class WalkPath: Path {

    var dashLengths: [NSNumber] = [6, 4]
    var polylineWidth: CGFloat = 8
    var traveledPath: GMSMutablePath?
    var untraveledPath: GMSMutablePath?

    init(_ waypoints: [Waypoint]) {

        super.init(waypoints: waypoints)
        self.color = Colors.metadataIcon

        self.untraveledPath = createPathFromWaypoints(waypoints: waypoints)
        self.traveledPath = untraveledPath

        self.path = untraveledPath
        self.strokeColor = color
        self.strokeWidth = polylineWidth

        self.spans = GMSStyleSpans(untraveledPath!, [.solidColor(self.color)], dashLengths, .projected)
        self.geodesic = false

    }

    func createPathFromWaypoints(waypoints: [Waypoint]) -> GMSMutablePath {
        let path = GMSMutablePath()
        for waypoint in waypoints {
            path.add(waypoint.coordinate)
        }
        return path
    }

}
