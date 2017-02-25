//
//  Path.swift
//  TCAT
//
//  Created by Annie Cheng on 2/24/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation
import SwiftyJSON

enum DirectionsStatus: String {
    case OK
    case ZERO_RESULTS
    case OVER_QUERY_LIMIT
    case REQUEST_DENIED
    case INVALID_REQUEST
    case UNKNOWN_ERROR
}

class Path: NSObject {
    
    var waypoints: [Waypoint] = []
    var overviewPolyline: String = ""
    var color: UIColor = UIColor.black
    
    init(waypoints: [Waypoint], color: UIColor) {
        super.init()
        self.waypoints = waypoints
        self.overviewPolyline = getPolyline()
        self.color = color
        
        for waypoint in waypoints {
            waypoint.setColor(color: color)
        }
    }
    
    func getPolyline() -> String {
        if waypoints.count < 2 { return "" }
        
        let origin = waypoints.first!
        let destination = waypoints.last!
        
        let baseDirectionsURL = "https://maps.googleapis.com/maps/api/directions/json?"
        let originQuery = "origin=\(origin.lat),\(origin.long)"
        let destinationQuery = "destination=\(destination.lat),\(destination.long)"
        let waypointsQuery = "waypoints=optimize:false"
        
        var directionsURLString = "\(baseDirectionsURL)\(originQuery)&\(destinationQuery)"
        
        if waypoints.count > 2 {
            let coords = waypoints.map { "|\($0.lat),\($0.long)" }
            directionsURLString += "&\(waypointsQuery)\(coords.joined())"
        }
        
        directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        if let directionsURL = URL(string: directionsURLString) {
            if let data = try? Data(contentsOf: directionsURL) {
                let json = JSON(data: data)
                let directionsStatus = DirectionsStatus(rawValue: json["status"].stringValue)!
                
                switch directionsStatus {
                case .OK:
                    return json["routes"][0]["overview_polyline"]["points"].stringValue
                case .ZERO_RESULTS:
                    print("Zero Results: Can't draw polyline")
                case .OVER_QUERY_LIMIT:
                    print("Over Query Limit: Can't draw polyline")
                case .REQUEST_DENIED:
                    print("Request Denied: Can't draw polyline")
                case .INVALID_REQUEST:
                    print("Invalid Request: Can't draw polyline")
                case .UNKNOWN_ERROR:
                    print("Unknown Error: Can't draw polyline")
                }
            }
        }
        
        return ""
    }
    
}
