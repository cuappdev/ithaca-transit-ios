//
//  Location+Utilities.swift
//  TCAT
//
//  Created by Matt Barker on 11/4/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

/// Caluclate walking directions for a Direction
func calculateWalkingDirections(_ direction: Direction, _ completion: @escaping ([CLLocationCoordinate2D]) -> Void) {
    let request = MKDirectionsRequest()
    request.source = MKMapItem(placemark: MKPlacemark(coordinate: direction.startLocation.coordinate, addressDictionary: [:]))
    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: direction.endLocation.coordinate, addressDictionary: [:]))
    request.transportType = .walking
    request.requestsAlternateRoutes = false
    let directions = MKDirections(request: request)
    directions.calculate { (response, error) in
        completion(response?.routes.first?.polyline.coordinates ?? [])
    }
}

/// Distance between two coordinates using coordinates
func calculateDistanceCoordinates(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
    let latDelta = to.latitude - from.latitude
    let longDelta = to.longitude - from.longitude
    return pow(pow(latDelta, 2) + pow(longDelta, 2), 0.5)
}

/// Distance in meters between two coordinates
func calculateDistanceMeters(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
    
    let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
    let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
    return fromLocation.distance(from: toLocation)
    
}

/// Calculate midpoint between two coordinates using average.
func calculateMidpoint(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    
    let averageLat = (to.latitude + from.latitude) / 2
    let averageLong = (to.longitude + from.longitude) / 2
    let midpoint = CLLocationCoordinate2D(latitude: averageLat, longitude: averageLong)
    print("midpoint:", midpoint)
    return midpoint
    
}

/// Determine if a point is close enough to the bus stop to start drawing the path
func pointWithinLocation(point: CLLocationCoordinate2D, location: CLLocationCoordinate2D, exact: Bool = false) -> Bool {
    
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
func calculateBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Bearing {
    
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

/// Return the most common bearing between all points
func generalBearing(of points: [CLLocationCoordinate2D]) -> Bearing {
    
    var topBearing: Bearing = .north
    
    var bearings: [Bearing : Int] = [
        .north : 0,
        .east : 0,
        .south : 0,
        .west : 0
    ]
    
    for i in 0..<points.count - 1 {
        
        let instance = calculateBearing(from: points[i], to: points[i+1])
        bearings[instance]! += 1
        
        if bearings[instance]! > bearings[topBearing]! {
            topBearing = instance
        }
        
    }
    
    return topBearing
    
}

func == (_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D) -> Bool {
    
    func rnd(_ number: Double, to place: Int = 6) -> Double {
        return round(number * pow(10.0, Double(place))) / pow(10.0, Double(place))
    }
    
    let result = rnd(rhs.latitude) == rnd(lhs.latitude) && rnd(rhs.longitude) == rnd(lhs.longitude)
    return result
    
}
