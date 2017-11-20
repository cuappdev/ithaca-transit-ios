//
//  BusIcon.swift
//  TCAT
//
//  Created by Matthew Barker on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation

extension UIView {
    
    func addShadow(shadowOffset: CGSize, shadowRadius: CGFloat) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = 0.33
        layer.shadowRadius = shadowRadius
    }
    
}

class BusLocationView: UIView {
    
    var busIcon: BusIcon!
    var bearingIndicator = UIImageView()
    
    /// The current position of the bearing icon
    var currentBearing: Double = 0
    
    init(number: Int, bearing: Int) {
        
        let background = UIImageView(image: #imageLiteral(resourceName: "busBackground"))
        let indicator = UIImageView(image: #imageLiteral(resourceName: "bearing"))
        
        super.init(frame: CGRect(x: 0, y: -1 * indicator.frame.height, width: background.frame.width, height: background.frame.height))
        
        let base = background
        addSubview(base)
        
        busIcon = BusIcon(type: .liveTracking, number: number)
        busIcon.center.x = base.center.x
        busIcon.frame.origin.y = 6
        addSubview(busIcon)
        
        bearingIndicator = indicator
        bearingIndicator.center.x = center.x
        bearingIndicator.frame.origin.y = 44 - (bearingIndicator.frame.width / 2)
        addSubview(bearingIndicator)
        
        // Set initial point to North
        self.bearingIndicator.transform = CGAffineTransform(rotationAngle: .pi)
        // self.setBearing(bearing)
        // currentBearing = Double(bearing)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func degreesToRadians(_ degrees: Any) -> Double {
        let value = degrees as? Double ?? Double(degrees as! Int)
        return value * .pi / 180
    }
    
    private func radiansToDegrees(_ radians: Any) -> Double {
        let value = radians as? Double ?? Double(radians as! Int)
        return value * 180 / .pi
    }
    
    func getBearingBetweenTwoPoints(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D) -> Double {
        
        let lat1 = degreesToRadians(point1.latitude)
        let lon1 = degreesToRadians(point1.longitude)
        let lat2 = degreesToRadians(point2.latitude)
        let lon2 = degreesToRadians(point2.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansToDegrees(radiansBearing)
        
    }
    
    /// Animate a change in bearing of bus
    func setBearing(_ degrees: Int, start: CLLocationCoordinate2D? = nil, end: CLLocationCoordinate2D? = nil) {

        // If bus stays in same location, don't update bearing
        if let start = start, let end = end {
            let latDelta = end.latitude - start.latitude
            let longDelta = end.longitude - start.longitude
            if latDelta == 0 || longDelta == 0 {
                return
            }
        }
        
        UIView.animate(withDuration: 0.2) {
            print("OG Degrees:", degrees)
            let newDegrees = Double(degrees) - self.currentBearing
            print("newDegrees:", newDegrees)
            let currentAngle: CGFloat = CGFloat(-1) * CGFloat(self.degreesToRadians(newDegrees))
            self.bearingIndicator.transform = CGAffineTransform(rotationAngle: currentAngle)
            self.currentBearing = Double(degrees)
        }
        
    }
    
    func setBetterBearing(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, debugDegrees: Int? = nil) {
        
        // Latitude: North / South, Longitude: East / West
        let latDelta = end.latitude - start.latitude
        let longDelta = end.longitude - start.longitude
        
        if latDelta == 0 || longDelta == 0 {
            return
        }
        
        // Calulcate bearing from start and end points
        
        let degrees = getBearingBetweenTwoPoints(point1: start, point2: end)
        
        print("calculated degrees:", degrees)
        print("actual degrees:", 360 + debugDegrees!)
        
        let newDegrees = degrees - self.currentBearing
        let currentAngle = CGFloat(-1) * CGFloat(self.degreesToRadians(newDegrees))
        self.bearingIndicator.transform = CGAffineTransform(rotationAngle: currentAngle)
        self.currentBearing = newDegrees
    
    }
    
}

class TriangleView : UIView {
    
    var color: UIColor!
    
    init(frame: CGRect, color: UIColor = .white) {
        self.color = color
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext()
            else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.maxY))
        context.closePath()
        
        context.setFillColor(color.cgColor)
        context.fillPath()
        
    }
    
}
