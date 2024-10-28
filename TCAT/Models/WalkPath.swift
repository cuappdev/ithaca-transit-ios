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
    var dashLengths: [NSNumber] = [30, 40]
    var polylineWidth: CGFloat = 0
    var traveledPath: GMSMutablePath?
    var untraveledPath: GMSMutablePath?
    var circles: [(coordinate: CLLocationCoordinate2D, radius: Double)] = []

    init(_ waypoints: [Waypoint]) {
        super.init(waypoints: waypoints)
        self.color = Colors.metadataIcon

        self.untraveledPath = createPathFromWaypoints(waypoints: waypoints)
        self.traveledPath = untraveledPath

        self.path = untraveledPath
        self.strokeColor = color
        self.strokeWidth = polylineWidth
        
        guard let path = self.path else { return }
        let intervalDistanceIncrement: CGFloat = 20
        var previousCircle: (coordinate: CLLocationCoordinate2D, radius: Double)?
        // Maps circles in incremental distance
        for coordinateIndex in 0 ..< path.count() - 1 {
            let startCoordinate = path.coordinate(at: coordinateIndex)
            let endCoordinate = path.coordinate(at: coordinateIndex + 1)
            let startLocation = CLLocation(latitude: startCoordinate.latitude, longitude: startCoordinate.longitude)
            let endLocation = CLLocation(latitude: endCoordinate.latitude, longitude: endCoordinate.longitude)
            let pathDistance = endLocation.distance(from: startLocation)
            let intervalLatIncrement = (endLocation.coordinate.latitude - startLocation.coordinate.latitude) / pathDistance
            let intervalLngIncrement = (endLocation.coordinate.longitude - startLocation.coordinate.longitude) / pathDistance

            for intervalDistance in 0 ..< Int(pathDistance) {
                let intervalLat = startLocation.coordinate.latitude + (intervalLatIncrement * Double(intervalDistance))
                let intervalLng = startLocation.coordinate.longitude + (intervalLngIncrement * Double(intervalDistance))
                let circleCoordinate = CLLocationCoordinate2D(latitude: intervalLat, longitude: intervalLng)

                if let previousCircle = previousCircle {
                    let circleLocation = CLLocation(latitude: circleCoordinate.latitude, longitude: circleCoordinate.longitude)
                    let previousCircleLocation = CLLocation(latitude: previousCircle.coordinate.latitude, longitude: previousCircle.coordinate.longitude)

                    if circleLocation.distance(from: previousCircleLocation) < intervalDistanceIncrement {
                        continue
                    }
                }

                let isFinalDestination = (coordinateIndex == path.count() - 1)
                circles.append((coordinate: circleCoordinate, radius: 5.0))
                previousCircle = (coordinate: circleCoordinate, radius: 5.0)
            }
        }
    }

    func createPathFromWaypoints(waypoints: [Waypoint]) -> GMSMutablePath {
        let path = GMSMutablePath()
        for waypoint in waypoints {
            path.add(waypoint.coordinate)
        }
        return path
    }
} 
