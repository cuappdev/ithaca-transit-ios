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
    case origin
    case destination
    case stop
    case busStart
    case busEnd
    case none
}

class Waypoint: NSObject {
    
    let smallDiameter: CGFloat = 12
    let largeDiameter: CGFloat = 16
    
    var lat: CLLocationDegrees = 0
    var long: CLLocationDegrees = 0
    var wpType: WaypointType = .origin
    var iconView: UIView = UIView()
    var busNumber: Int = 0
    
    init(lat: CLLocationDegrees, long: CLLocationDegrees, wpType: WaypointType, busNumber: Int = 0) {
        super.init()
        self.lat = lat
        self.long = long
        self.wpType = wpType
        self.busNumber = busNumber
        
        switch wpType {
        case .origin:
            self.iconView = drawOriginIcon()
        case .destination:
            self.iconView = drawDestinationIcon()
        case .stop:
            self.iconView = drawStopIcon()
        case .busStart:
            self.iconView = drawBusPointIcon()
        case .busEnd:
            self.iconView = drawBusPointIcon()
        case .none:
            self.iconView = UIView()
        }
    }
    
    func drawOriginIcon() -> UIView {
        return drawCircle(radius: largeDiameter / 2, innerColor: .mediumGrayColor)
    }
    
    func drawDestinationIcon() -> UIView {
        return drawCircle(radius: largeDiameter / 2, innerColor: .tcatBlueColor, borderColor: .white)
    }
    
    func drawStopIcon() -> UIView {
        return drawCircle(radius: smallDiameter / 2, innerColor: .white)
    }

    func drawBusPointIcon() -> UIView {
        return drawCircle(radius: smallDiameter / 2, innerColor: .tcatBlueColor)
    }
    
    // Draw waypoint meant to be placed as an iconView on map
    func drawCircle(radius: CGFloat, innerColor: UIColor, borderColor: UIColor? = nil) -> UIView {
        let circleView = UIView(frame: CGRect(x: 0, y: -radius, width: radius * 2, height: radius * 2))
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
        case .destination:
            iconView.layer.borderColor = color.cgColor
        case .origin, .stop, .busStart, .busEnd:
            iconView.backgroundColor = color
        case .none:
            break
        }
    }
    
}

