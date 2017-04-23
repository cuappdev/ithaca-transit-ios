//
//  Waypoint.swift
//  TCAT
//
//  Created by Annie Cheng on 2/24/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation

enum WaypointType: String {
    case Origin
    case Destination
    case Stop
    case None
}

class Waypoint: NSObject {
    
    let smallDiameter: CGFloat = 12
    let largeDiameter: CGFloat = 16
    
    var lat: CLLocationDegrees = 0
    var long: CLLocationDegrees = 0
    var wpType: WaypointType = .Origin
    var iconView: UIView = UIView()
    var busNumber: Int = 0
    
    init(lat: CLLocationDegrees, long: CLLocationDegrees, wpType: WaypointType, busNumber: Int = 0) {
        super.init()
        self.lat = lat
        self.long = long
        self.wpType = wpType
        self.busNumber = busNumber
        
        switch wpType {
        case .Origin:
            self.iconView = drawOriginIcon()
        case .Destination:
            self.iconView = drawDestinationIcon()
        case .Stop:
            self.iconView = drawStopIcon()
        case .None:
            self.iconView = UIView()
        }
    }
    
    func drawOriginIcon() -> UIView {
        return drawCircle(radius: smallDiameter / 2, innerColor: .tcatBlueColor)
    }
    
    func drawDestinationIcon() -> UIView {
        return drawCircle(radius: largeDiameter / 2, innerColor: .white, borderColor: .tcatBlueColor)
    }
    
    func drawStopIcon() -> UIView {
        return BusIcon(size: .small, number: self.busNumber)
    }
    
    func drawCircle(radius: CGFloat, innerColor: UIColor, borderColor: UIColor? = nil) -> UIView {
        let circleView = UIView(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
        circleView.center = .zero
        circleView.layer.cornerRadius = circleView.frame.width / 2.0
        circleView.layer.masksToBounds = true
        circleView.backgroundColor = innerColor
        
        if let borderColor = borderColor {
            circleView.layer.borderWidth = 4
            circleView.layer.borderColor = borderColor.cgColor
        }
        
        return circleView
    }
    
    func setColor(color: UIColor) {
        switch wpType {
        case .Origin, .Stop:
            iconView.backgroundColor = color
        case .Destination:
            iconView.layer.borderColor = color.cgColor
        case .None:
            break
        }
    }
    
}

