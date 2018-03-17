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
    
    fileprivate var bearingIndicator = UIImageView()
    fileprivate var circle = UIView()
    
    /// The current position of the bearing icon
    var currentBearing: Double = 0
    
    /// The actual coordinates of the bus on a map
    var position: CLLocationCoordinate2D!
    
    init(number: Int, bearing: Int, position: CLLocationCoordinate2D) {
        
        let background = UIImageView(image: #imageLiteral(resourceName: "busBackground"))
        let indicator = UIImageView(image: #imageLiteral(resourceName: "bearing"))
        
        super.init(frame: CGRect(x: 0, y: -1 * indicator.frame.height, width: background.frame.width, height: background.frame.height))
        self.position = position
        
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
        bearingIndicator.transform = CGAffineTransform(rotationAngle: .pi)
        bearingIndicator.isHidden = true
        
        // Bearing too unpredictable. Using static circle for now.
        circle = UIView(frame: CGRect(x: 0, y: 0, width: indicator.frame.height / 2, height: indicator.frame.height / 2))
        circle.center.x = center.x
        circle.frame.origin.y = 44 - (circle.frame.width / 2)
        circle.layer.cornerRadius = circle.frame.width / 2
        circle.backgroundColor = .tcatBlueColor
        addSubview(circle)
        circle.isHidden = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Update the coordinates and bearing of the bus
    func updateBus(from oldCoords: CLLocationCoordinate2D? = nil, to newCoords: CLLocationCoordinate2D? = nil, with heading: Double? = nil) {
        if let newCoords = newCoords { position = newCoords }
        setBearing(start: oldCoords, end: newCoords, heading: heading)
    }
    
    /// Toggle between circle and indicator, or specifically set the circle to one value and bearing the opposite
    func setCircle(isVisible: Bool) {
        circle.isHidden = !isVisible
        bearingIndicator.isHidden = !circle.isHidden
    }
    
    // Calculate and transform bearing based on change in location or provided heading
    private func setBearing(start: CLLocationCoordinate2D? = nil, end: CLLocationCoordinate2D? = nil, heading: Double? = nil) {
        
        // Latitude: North / South, Longitude: East / West
        if let start = start, let end = end {
            
            // If no location change, don't change anything
            let latDelta = end.latitude - start.latitude
            let longDelta = end.longitude - start.longitude
            if latDelta == 0 || longDelta == 0 {
                return
            }
            
            // Calulcate bearing from start and end points based on location change
            let degrees = (getBearingBetween(start, end) + 360).truncatingRemainder(dividingBy: 360)
            let newDegrees = degrees - self.currentBearing
            let currentAngle = CGFloat(-1) * CGFloat(self.degreesToRadians(newDegrees))
            self.bearingIndicator.transform = CGAffineTransform(rotationAngle: CGFloat(-1) * CGFloat(degreesToRadians(currentBearing)))
            self.bearingIndicator.transform = CGAffineTransform(rotationAngle: currentAngle)
            self.currentBearing = newDegrees
            
        } else if let heading = heading {
            
            print("Setting bearing with value:", heading)
            // Use endpoint-provided value to change bearing
            // let newDegrees = heading - currentBearing
            // let currentAngle: CGFloat = CGFloat(-1) * CGFloat(degreesToRadians(heading)) // CGFloat(degreesToRadians(newDegrees))
            let resetFromAngle = CGFloat(degreesToRadians(currentBearing))
            let setToAngle = CGFloat(-1) * CGFloat(degreesToRadians(heading))
            self.bearingIndicator.transform = CGAffineTransform(rotationAngle: resetFromAngle)
            self.bearingIndicator.transform = CGAffineTransform(rotationAngle: setToAngle)
            self.currentBearing = heading
            
        } else {
            print("setBearing: no parameters passed in")
        }
        
    }
    
    func getBearingBetween(_ point1: CLLocationCoordinate2D, _ point2: CLLocationCoordinate2D) -> Double {
        
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
    
    func degreesToRadians(_ degrees: Any) -> Double {
        let value = degrees as? Double ?? Double(degrees as! Int)
        return value * .pi / 180
    }
    
    func radiansToDegrees(_ radians: Any) -> Double {
        let value = radians as? Double ?? Double(radians as! Int)
        return value * 180 / .pi
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
