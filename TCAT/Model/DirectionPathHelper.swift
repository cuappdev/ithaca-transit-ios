//
//  Direction.swift
//  TCAT
//
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SwiftyJSON

enum Bearing: String {
    case west, east, north, south
}

struct PathHelper {
    
    static let shared = PathHelper()
    
    // Create subection of path based on start and end
    // of direction if busPath exists (Depart Direction)
    // Return [CLLocationCoordinate2D]
    func filterPath(in json: JSON, from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        
        if json["busPath"] != JSON.null {
            
            // Convert JSON to [CLLocationCoordinate2D]
            
            let busPathShape = json["busPath"]["path"]["shape"].arrayValue
            let path = busPathShape.flatMap { (location) -> CLLocationCoordinate2D? in
                return CLLocationCoordinate2D(latitude: location["latitude"].doubleValue,
                                              longitude: location["longitude"].doubleValue)
            }
            
            // Find start of path
            
            let nearStartPoints = path.filter { pointWithinLocation(point: $0, location: start) }
            // let nearStartBearing = generalBearing(of: nearStartPoints)
            
            var closestDistance: Double = .infinity
            var busPathStartIndex = 0
            
            // Find the closest point to the start that matches the general bearing (removed)
            // a.k.a the first point after the start
            
            for i in 0..<nearStartPoints.count {
                let distance = calculateDistanceCoordinates(from: start, to: nearStartPoints[i])
                // let bearing = calculateBearing(from: start, to: nearStartPoints[i])
                if distance < closestDistance /* && bearing == nearStartBearing */ {
                    closestDistance = distance
                    busPathStartIndex = path.index(where: { $0 == nearStartPoints[i] })!
                }
            }
            
            // Find end of path
            
            let nearEndPoints = path.filter { pointWithinLocation(point: $0, location: end) }
            // let nearEndBearing = generalBearing(of: nearEndPoints)
            
            closestDistance = .infinity
            var busPathEndIndex = 0 // path.endIndex - 1
            
            // Find the cloest point to the end that matches the general bearing (removed)
            // a.k.a. the last point before the end
            
            for i in 0..<nearEndPoints.count {
                let distance = calculateDistanceCoordinates(from: nearEndPoints[i], to: end)
                // let bearing = calculateBearing(from: nearEndPoints[i], to: end)
                if distance < closestDistance /* && bearing == nearEndBearing */ {
                    closestDistance = distance
                    busPathEndIndex = path.index(where: { $0 == nearEndPoints[i] })!
                }
            }
            
            if busPathStartIndex >= busPathEndIndex {
                print("\n\n==============\n[DirectionPathHelper] PATH FILTER FAILED\n==============\n\n")
                return path
            } else {
                let subsection = Array(path[busPathStartIndex...busPathEndIndex])
                return [start] + subsection + [end]
            }
        
        }
        
        return []
        
    }
    
    func filterStops(in stops: [String], along path: [CLLocationCoordinate2D]) -> [String] {
        
        var filteredStops = [String]()
        
        // print("[PathHelper] original stops size:", stops.count)
        
        for point in path {
            
            if let stop = getAllBusStops().first(where: { (stop) -> Bool in
                let stopCoordinates = CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.long)
                return pointWithinLocation(point: point, location: stopCoordinates, exact: true)
            }) {
                if !filteredStops.contains(stop.name) {
                    filteredStops.append(stop.name)
                }
            }
            
        }
        
        // print("[PathHelper] filtered stops size:", filteredStops.count)
        
        return filteredStops
        
    }

}

