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

enum DirectionsStatus: String {
    case OK
    case ZERO_RESULTS
    case OVER_QUERY_LIMIT
    case REQUEST_DENIED
    case INVALID_REQUEST
    case UNKNOWN_ERROR
}

enum PathType: String {
    case Driving
    case Walking
}

class Path: GMSPolyline {
    
    let polylineWidth: CGFloat = 6
    let dashLengths: [NSNumber] = [14, 10]
    
    var waypoints: [Waypoint] = []
    var traveledPolyline: GMSPolyline = GMSPolyline()
    var traveledPath: GMSMutablePath? = nil
    var untraveledPath: GMSMutablePath? = nil
    var pathType: PathType = .Driving
    var color: UIColor = .black
    
    init(waypoints: [Waypoint], pathType: PathType, color: UIColor) {
        super.init()
        self.waypoints = waypoints
        self.pathType = pathType
        self.color = color
        
        for waypoint in waypoints {
            waypoint.setColor(color: color)
        }
        
        self.untraveledPath = GMSMutablePath(fromEncodedPath: getPolyline())
        self.traveledPath = untraveledPath
        
        self.path = untraveledPath
        self.strokeColor = color
        self.strokeWidth = polylineWidth
        self.traveledPolyline.path = traveledPath
        self.traveledPolyline.strokeColor = .gray
        self.traveledPolyline.strokeWidth = polylineWidth
        
        if pathType == .Walking {
            let untraveledDashStyles: [GMSStrokeStyle] = [.solidColor(color), .solidColor(.clear)]
            self.spans = GMSStyleSpans(untraveledPath!, untraveledDashStyles, dashLengths, kGMSLengthRhumb)
            self.strokeWidth -= 2
            
            let traveledDashStyles: [GMSStrokeStyle] = [.solidColor(.gray), .solidColor(.clear)]
            self.traveledPolyline.spans = GMSStyleSpans(traveledPath!, traveledDashStyles, dashLengths, kGMSLengthRhumb)
            self.traveledPolyline.strokeWidth -= 2
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
