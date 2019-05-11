//
//  Waypoint.swift
//  TCAT
//
//  Created by Annie Cheng on 2/24/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import CoreLocation
import UIKit

enum WaypointType: String, Codable {
    case bus
    case bussing

    /// The endLocation destination point of the trip
    case destination

    /// The startLocation origin point of the trip
    case origin

    case none

    /// Used for bus stops
    case stop

    case walk
    case walking
}

class Waypoint: NSObject {

    let smallDiameter: CGFloat = 12
    let largeDiameter: CGFloat = 24

    var busNumber: Int = 0
    var iconView: UIView = UIView()
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var wpType: WaypointType = .origin

    init(lat: CLLocationDegrees, long: CLLocationDegrees, wpType: WaypointType, busNumber: Int = 0, isStop: Bool = false) {
        super.init()
        self.latitude = lat
        self.longitude = long
        self.wpType = wpType
        self.busNumber = busNumber

        switch wpType {
        case .origin:
            self.iconView = Circle(size: .large, style: .solid, color: isStop ? Colors.tcatBlue : Colors.metadataIcon)
        case .destination:
            self.iconView = Circle(size: .large, style: .bordered, color: isStop ? Colors.tcatBlue : Colors.metadataIcon)
        case .bus:
            self.iconView = Circle(size: .small, style: .solid, color: Colors.tcatBlue)
        case .walk:
            self.iconView = Circle(size: .small, style: .solid, color: Colors.metadataIcon)
        case .none, .stop, .walking, .bussing:
            self.iconView = UIView()
        }
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func drawOriginIcon() -> UIView {
        return drawCircle(radius: largeDiameter / 2, innerColor: Colors.metadataIcon, borderColor: Colors.white)
    }

    func drawDestinationIcon() -> UIView {
        return drawCircle(radius: largeDiameter / 2, innerColor: Colors.tcatBlue, borderColor: Colors.white)
    }

    func drawStopIcon() -> UIView {
        return drawCircle(radius: smallDiameter / 2, innerColor: Colors.white)
    }

    func drawBusPointIcon() -> UIView {
        return drawCircle(radius: smallDiameter / 2, innerColor: Colors.tcatBlue)
    }

    func drawWalkPointIcon() -> UIView {
        return drawCircle(radius: smallDiameter / 2, innerColor: Colors.metadataIcon)
    }

    // Draw waypoint meant to be placed as an iconView on map
    func drawCircle(radius: CGFloat, innerColor: UIColor, borderColor: UIColor? = nil) -> UIView {

        let constant: CGFloat = 1
        let dim = (radius * 2) + 4
        let base = UIView(frame: CGRect(x: 0, y: 0, width: dim, height: dim))

        let circleView = UIView(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
        circleView.center = base.center

        circleView.layer.cornerRadius = circleView.frame.width / 2.0
        circleView.layer.masksToBounds = false
        circleView.layer.shadowColor = Colors.black.cgColor
        circleView.layer.shadowOffset = CGSize(width: 0, height: constant)
        circleView.layer.shadowOpacity = 0.25
        circleView.layer.shadowRadius = 1

        circleView.backgroundColor = innerColor
        if let borderColor = borderColor {
            circleView.layer.borderWidth = 4
            circleView.layer.borderColor = borderColor.cgColor
        }

        base.addSubview(circleView)
        return base

    }

    func setColor(color: UIColor) {
        switch wpType {
        case .destination:
            iconView.layer.borderColor = color.cgColor
        case .origin, .stop, .bus, .walk, .bussing, .walking:
            iconView.backgroundColor = color
        case .none:
            break
        }
    }

}
