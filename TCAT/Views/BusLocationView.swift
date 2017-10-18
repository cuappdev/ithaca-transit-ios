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
    
    init(number: Int) {
        
        self.busIcon = BusIcon(type: .liveTracking, number: number)
        
        let padding: CGFloat = 6
        let tailHeight: CGFloat = 12
        let width = self.busIcon.frame.width + 2 * padding
        let height = self.busIcon.frame.height + padding * 2
        
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height + tailHeight + 2))
        
        let base = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        base.backgroundColor = .white
        base.layer.cornerRadius = 6
        base.addShadow(shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 2)
        addSubview(base)
        
        busIcon.center = base.center
        addSubview(busIcon)

        let frame = CGRect(x: base.frame.width / 2 - (tailHeight / 2), y: base.frame.maxY, width: tailHeight, height: tailHeight)
        let tail = TriangleView(frame: frame)
        tail.addShadow(shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 2)
        addSubview(tail)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
