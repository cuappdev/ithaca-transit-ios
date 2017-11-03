//
//  BusIcon.swift
//  TCAT
//
//  Created by Matthew Barker on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//
import UIKit

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
    
    init(number: Int) {
        
        let background = UIImageView(image: #imageLiteral(resourceName: "liveBusBackground"))
        background.frame.size = CGSize(width: background.frame.width * 1.25, height: background.frame.height * 1.25)

        super.init(frame: CGRect(x: 0, y: 0, width: background.frame.width, height: background.frame.height))
        
        let base = background
        addSubview(base)
        
        busIcon = BusIcon(type: .liveTracking, number: number)
        busIcon.center.x = base.center.x
        busIcon.frame.origin.y = 6
        addSubview(busIcon)
        
        bearingIndicator = UIImageView(image: #imageLiteral(resourceName: "bearing"))
        bearingIndicator.center.x = center.x
        bearingIndicator.frame.origin.y = 44 - (bearingIndicator.frame.width / 2)
        addSubview(bearingIndicator)
        
        // Set initial point to North
        self.bearingIndicator.transform = CGAffineTransform(rotationAngle: .pi)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Animate a change in bearing of bus
    func setBearing(_ degrees: Int) {
        let angle: CGFloat = CGFloat(Double(degrees) / 360) * .pi * 2
        UIView.animate(withDuration: 0.2) {
            self.bearingIndicator.transform = CGAffineTransform(rotationAngle: angle)
        }
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
