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

protocol Direction {
    var time: Date {get set}
    var place: String {get set}
    var location: CLLocation {get set} //START location for direction
    var placeDescription: String {get} //e.g. "Walk to Statler", "Board at Statler", "Debark at Ithaca Commons"
    var timeDescription: String {get} // "e.g. 7:21 PM"
}

/* To get string version of Bound
 * let inbound: String = Bound.inbound.rawValue  //"inbound"
 * let outbound: String = Bound.inbound.rawValue //"outbound"
 */
enum Bound: String {
    case inbound, outbound
}

class DepartDirection: Direction {
    
    var time: Date
    var place: String
    var placeDescription: String {
        return "at \(place)"
    }
    var timeDescription: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    var location: CLLocation
    var path: [CLLocationCoordinate2D]
    
    var routeNumber: Int
    var bound: Bound
    var stops: [String]
    var arrivalTime: Date
    
    /*To extract travelTime's times in day, hour, and minute units:
     * let days: Int = travelTime.day
     * let hours: Int = travelTime.hour
     * let minutes: Int = travelTime.minute
     */
    var travelTime: DateComponents {
        return Time.dateComponents(from: time, to: arrivalTime)
    }
    
    init(time: Date, place: String, location: CLLocation, path: [CLLocationCoordinate2D] = [], 
         routeNumber: Int, bound: Bound, stops: [String] = [],  arrivalTime: Date) {
        self.time = time
        self.place = place
        self.location = location
        self.path = path
        self.routeNumber = routeNumber
        self.bound = bound
        self.stops = stops
        self.arrivalTime = arrivalTime
    }
    
}

class ArriveDirection: Direction {
    
    var time: Date
    var place: String
    var placeDescription: String {
        return "Debark at \(place)"
    }
    var timeDescription: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    var location: CLLocation
    
    init(time: Date, place: String, location: CLLocation) {
        self.time = time
        self.place = place
        self.location = location
    }
    
}

class WalkDirection: Direction {
    
    var time: Date
    var place: String
    var placeDescription: String {
        return "Walk to \(place)"
    }
    var timeDescription: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    var location: CLLocation
    var path: [CLLocationCoordinate2D]
    
    var travelDistance: Double
    var destinationLocation: CLLocation
    
    init(time: Date, place: String, location: CLLocation, travelDistance: Double, 
         destination: CLLocation, path: [CLLocationCoordinate2D] = []) {
        self.time = time
        self.place = place
        self.location = location
        self.travelDistance = travelDistance
        self.destinationLocation = destination
        self.path = path
    }
    
    /** Return a WalkDirectionResult (see spec) between two points. Also calulcates CLLocationCoordinate2D path to
     walk between points and updates path variable automatically
    Completion hanldre returns distance (meters) and expectedTravelTime (seconds) of a walking route */
    func calculateWalkingDirections(_ completionHandler: @escaping (CLLocationDistance, TimeInterval) -> Void) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate, addressDictionary: [:]))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationLocation.coordinate, addressDictionary: [:]))
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let route = response?.routes.first {
                self.path = route.polyline.coordinates
                self.travelDistance = route.distance
                completionHandler((route.distance, route.expectedTravelTime))
            }
        }
    }
    
}
