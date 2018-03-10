//
//  Circle.swift
//  TCAT
//
//  Created by Matthew Barker on 3/1/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

enum CircleSize: Int {
    case small = 12
    case medium = 16
    case large = 24
}

enum CircleStyle {
    case solid, bordered, outline
}

class Circle: UIView {
    
    init(size: CircleSize, color: UIColor, style: CircleStyle) {
        
        let diameter: CGFloat = CGFloat(size.rawValue)
        super.init(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
        
        switch style {
            
            case .solid:
                
                backgroundColor = color
            
            case .bordered:
                
                backgroundColor = .white
                layer.borderColor = color.cgColor
                layer.borderWidth = 2.5
                
                let solidCircle = CALayer()
                solidCircle.frame = CGRect(x: 0, y: 0, width: 6, height: 6)
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
