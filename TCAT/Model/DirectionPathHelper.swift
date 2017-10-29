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

class PathHelper {
    
    init() {
        
    }
    
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
            
            let nearStartPoints = path.filter { PathHelper.pointWithinLocation(point: $0, location: start) }
            let nearStartBearing = generalBearing(of: nearStartPoints)
            
            var closestDistance: Double = .infinity
            var busPathStartIndex = 0
            
            // Find the closest point to the start that matches the general bearing
            // a.k.a the first point after the start
            
            if nearStartPoints.count > 1 {
                for i in 1..<nearStartPoints.count {
                    let distance = self.distance(from: start, to: nearStartPoints[i])
                    let bearing = self.bearing(from: start, to: nearStartPoints[i])
                    if distance < closestDistance && bearing == nearStartBearing {
                        closestDistance = distance
                        busPathStartIndex = path.index(where: { Direction.coordsEqual($0, nearStartPoints[i]) })!
                    }
                }
            } else {
                if let index = path.index(where: { Direction.coordsEqual($0, nearStartPoints.first ?? CLLocationCoordinate2D()) }) {
                    busPathStartIndex = index
                }
            }
            
            // Find end of path
            
            let nearEndPoints = path.filter { PathHelper.pointWithinLocation(point: $0, location: end) }
            let nearEndBearing = generalBearing(of: nearEndPoints)
            
            closestDistance = .infinity
            var busPathEndIndex = 0
            
            // Find the cloest point to the end that matches the general bearing
            // a.k.a. the last point before the end
            
            if nearEndPoints.count > 1 {
                for i in 1..<nearEndPoints.count {
                    let distance = self.distance(from: nearEndPoints[i], to: end)
                    let bearing = self.bearing(from: nearEndPoints[i], to: end)
                    if distance < closestDistance && bearing == nearEndBearing {
                        closestDistance = distance
                        busPathEndIndex = path.index(where: { Direction.coordsEqual($0, nearEndPoints[i]) })!
                    }
                }
            } else {
                if let index = path.index(where: { Direction.coordsEqual($0, nearEndPoints.first ?? CLLocationCoordinate2D()) }) {
                    busPathEndIndex = index
                }
            }
            
            if busPathStartIndex > busPathEndIndex {
                print("\n\n============\n[DirectionPathHelper] PATH FILTER FAILED\n==============\n\n")
                // print("startIndex:", busPathStartIndex)
                // print("endIndex:", busPathEndIndex)
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
                return PathHelper.pointWithinLocation(point: point, location: stopCoordinates, exact: true)
            }) {
                if !filteredStops.contains(stop.name) {
                    filteredStops.append(stop.name)
                }
            }
            
        }
        
        // print("[PathHelper] filtered stops size:", filteredStops.count)
        
        return filteredStops
        
    }
    
    private func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let latDelta = to.latitude - from.latitude
        let longDelta = to.longitude - from.longitude
        return pow(pow(latDelta, 2) + pow(longDelta, 2), 0.5)
    }
    
    /// Determine if a point is close enough to the bus stop to start drawing the path
    class func pointWithinLocation(point: CLLocationCoordinate2D, location: CLLocationCoordinate2D, exact: Bool = false) -> Bool {
        
        /// The amount of "error" or size of the acceptable region near the bus location to
        let radius: Double = exact ? 0.00025 : 0.003
        
        let minLatitude = location.latitude - radius
        let maxLatitude = location.latitude + radius
        let minLongitude = location.longitude - radius
        let maxLongitude = location.longitude + radius
        
        let latitudeInRange = minLatitude <= point.latitude && point.latitude <= maxLatitude
        let longitudeInRange = minLongitude <= point.longitude && point.longitude <= maxLongitude
        return latitudeInRange && longitudeInRange
        
    }
    
    /// Return bearing from one location to another
    private func bearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Bearing {
        
        let latDelta = to.latitude - from.latitude
        let longDelta = to.longitude - from.longitude
        
        // North / South dominant
        if latDelta >= longDelta {
            return latDelta > 0  ? .north : .south
        }
            
        // East / West dominant
        else {
            return longDelta > 0 ? .east : .west
        }
        
    }
    
    private func generalBearing(of points: [CLLocationCoordinate2D]) -> Bearing {
        
        var topBearing: Bearing = .north
        
        var bearings: [Bearing : Int] = [
            .north : 0,
            .east : 0,
            .south : 0,
            .west : 0
        ]
        
        for i in 0..<points.count - 1 {
            
            let instance = bearing(from: points[i], to: points[i+1])
            bearings[instance]! += 1
            
            if bearings[instance]! > bearings[topBearing]! {
                topBearing = instance
            }
            
        }
        
        return topBearing
        
    }

}

