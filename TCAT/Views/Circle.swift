//
//  Circle.swift
//  TCAT
//
//  Created by Matthew Barker on 3/1/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

enum CircleType: String {
    // small solid circle
    case smallSolid
    // used to indicate destination
    case largeBordered
    // Used for bus stops in route detail cell expansion
    case smallOutline
}

private enum CircleStyle {
    case solid, bordered, outline
}

private enum CircleSize {
    case small, large
}

class Circle: UIView {
    
    init(type: CircleType, color: UIColor) {
        
        var size: CircleSize
        var style: CircleStyle
        
        switch type {
            
        case .smallSolid:
            size = .small
            style = .solid
            
        case .largeBordered:
            size = .large
            style = .bordered
            
        case .smallOutline:
            size = .small
            style = .outline
            
        }
        
        let radius: CGFloat = CGFloat(size == .small ? 16 : 32)
        super.init(frame: CGRect(x: 0, y: 0, width: radius, height: radius))
        
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
        
        switch style {
            
            case .solid:
                
                backgroundColor = color
            
            case .bordered:
                
                backgroundColor = .white
                layer.borderColor = color.cgColor
                layer.borderWidth = 4.0
                
                let solidCircle = CALayer()
                solidCircle.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
                solidCircle.position = center
                solidCircle.cornerRadius = solidCircle.frame.height / 2
                solidCircle.backgroundColor = color.cgColor
                layer.addSublayer(solidCircle)
            
            case .outline:
                
                backgroundColor = .white
                layer.borderColor = color.cgColor
                layer.borderWidth = 1.0
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
