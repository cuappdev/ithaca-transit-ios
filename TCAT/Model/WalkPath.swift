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

class WalkPath: Path {
    
    var polylineWidth: CGFloat = 8
    var dashLengths: [NSNumber] = [6, 4]
    var traveledPath: GMSMutablePath? = nil
    var untraveledPath: GMSMutablePath? = nil
    
    init(_ waypoints: [Waypoint]) {
        
        super.init(waypoints: waypoints)
        self.color = .mediumGrayColor
    
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

class WalkPathInProgress: Path {
    
    var circles: [GMSCircle] = []
    
    init(_ waypoints: [Waypoint]) {
        
        super.init(waypoints: waypoints)
        self.color = .mediumGrayColor
        
        print("\nTESTING ===")
        test()
        print("============\n")
        // self.waypoints = addMore(points: waypoints)
        
        self.circles += waypointsToCircles(self.waypoints)
        
    }
    
    func waypointsToCircles(_ points: [Waypoint]) -> [GMSCircle] {
        
        var circleArray = [GMSCircle]()
        
        for point in points {
            
            let circle = GMSCircle(position: point.coordinate, radius: 8)
            circle.fillColor = self.color
            circle.strokeWidth = 0
            circleArray.append(circle)
            
        }
        
        return circleArray
        
    }
    
    func test() {
        
        let waypoints: [Waypoint] = [
            
            Waypoint(lat: 42.443784, long:  -76.494034, wpType: .none),
            Waypoint(lat: 42.442682, long:  -76.495797, wpType: .none),
            Waypoint(lat: 42.441417, long:  -76.495751, wpType: .none),
            Waypoint(lat: 42.440507, long:  -76.495688, wpType: .none),
        
        ]
        
        let new = addMore(points: waypoints)
        print("New:")
        new.forEach {
            print($0.coordinate)
        }
        
    }
    
    func addMore(points: [Waypoint]) -> [Waypoint] {
        
        // Maximum greater than double the minimum
        let distanceMinimum: Double = 10 // meters
        let distanceMaximum: Double = 30 // meters
        
        let ogPoints = points
        var points = points
        var newPoints: [Waypoint] = []
        var skip: Bool = false
        // var index = 0
        
        for index in points.startIndex...points.endIndex {
            
            print("POINTS")
            points.forEach {
                print($0.coordinate)
            }
            print("=====")
            
            if skip { skip = false; continue }
            else if index+1 == points.count { return newPoints }
            
            let a = points[index]
            let b = points[index+1]
            let distanceBetweenPoints = calculateDistanceMeters(from: a.coordinate, to: b.coordinate)
            
            print("distance between points:", distanceBetweenPoints)
            
            // If points are too far, add a point in-between.
            if distanceBetweenPoints > distanceMaximum {
                
                newPoints.append(a)
                
                let midCoord = calculateMidpoint(from: a.coordinate, to: b.coordinate)
                let midpoint = Waypoint(lat: midCoord.latitude, long: midCoord.longitude, wpType: .none)
                points.append(midpoint)

            }
            
            else {
                // If points are too close, remove the latter one.
                if distanceBetweenPoints < distanceMinimum {
                    skip = true
                } else {
                    newPoints.append(a)
                }
            }
            
        }
        
        print("OG points count:", ogPoints.count)
        print("new points count:", points.count)
        print("NEW points counts:", newPoints.count)
        
        let new = waypointsToCircles(points)
        self.circles += new
        
        return newPoints
        
    }
    
}
