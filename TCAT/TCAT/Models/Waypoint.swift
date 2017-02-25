//
//  Waypoint.swift
//  TCAT
//
//  Created by Annie Cheng on 2/24/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation
import UIKit

enum WaypointType: String {
    case Origin
    case Destination
    case Stop
}

class Waypoint: NSObject {
    
    var lat: CGFloat = 0
    var long: CGFloat = 0
    var wpType: WaypointType = .Origin
    var iconView: UIView = UIView()
    var busNumber: Int = 0
    
    init(lat: CGFloat, long: CGFloat, wpType: WaypointType, busNumber: Int = 0) {
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
        }
    }
    
    func drawOriginIcon() -> UIView {
        let iconView = drawCircle(radius: 9, innerColor: .black, borderColor: .white)

        return iconView
    }
    
    func drawDestinationIcon() -> UIView {
        let radius: CGFloat = 9
        let iconView = drawCircle(radius: radius, innerColor: .white, borderColor: .black)
        
        let innerView = UIView(frame: CGRect(x: 0, y: 0, width: radius/2.0, height: radius/2.0))
        innerView.center = iconView.center
        innerView.layer.cornerRadius = innerView.frame.width / 2.0
        innerView.layer.masksToBounds = true
        innerView.backgroundColor = .black
        iconView.addSubview(innerView)
        
        return iconView
    }
    
    func drawStopIcon() -> UIView {
        let radius: CGFloat = 15
        let iconView = drawCircle(radius: radius, innerColor: .black)
        
        let busNumLabel = UILabel(frame: CGRect(x: 0, y: 0, width: radius*2, height: radius*2))
        busNumLabel.text = "\(self.busNumber)"
        busNumLabel.font = .systemFont(ofSize: 14)
        busNumLabel.textColor = .white
        busNumLabel.textAlignment = .center
        busNumLabel.center = iconView.center
        iconView.addSubview(busNumLabel)
        
        return iconView
    }
    
    func drawCircle(radius: CGFloat, innerColor: UIColor, borderColor: UIColor? = nil) -> UIView {
        let circleView = UIView(frame: CGRect(x: 0, y: 0, width: radius*2, height: radius*2))
        circleView.layer.cornerRadius = circleView.frame.width / 2.0
        circleView.layer.masksToBounds = true
        circleView.backgroundColor = innerColor
        
        if let borderColor = borderColor {
            circleView.layer.borderWidth = 2
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
        }
    }
    
}

