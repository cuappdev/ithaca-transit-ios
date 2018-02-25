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

/// Caluclate walking directions for a Direction. Returns (path: [CLLocationCoordinate2D], time: TimeInterval), with time in minutes.
func calculateWalkingDirections(_ direction: Direction, _ completion: @escaping (_ path: [CLLocationCoordinate2D], _ time: TimeInterval) -> Void) {
    let request = MKDirectionsRequest()
    request.source = MKMapItem(placemark: MKPlacemark(coordinate: direction.startLocation, addressDictionary: [:]))
    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: direction.endLocation, addressDictionary: [:]))
    request.transportType = .walking
    request.requestsAlternateRoutes = false
    MKDirections(request: request).calculate { (response, error) in
        guard let route = response?.routes.first
            else { completion([], 0); return }
        completion(route.polyline.coordinates, round(route.expectedTravelTime / 60))
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

func == (_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D) -> Bool {
    
    func rnd(_ number: Double, to place: Int = 6) -> Double {
        return round(number * pow(10.0, Double(place))) / pow(10.0, Double(place))
    }
    
    let result = rnd(rhs.latitude) == rnd(lhs.latitude) && rnd(rhs.longitude) == rnd(lhs.longitude)
    return result
    
}
