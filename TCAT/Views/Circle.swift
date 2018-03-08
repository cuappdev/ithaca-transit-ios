//
//  Circle.swift
//  TCAT
//
//  Created by Matthew Barker on 3/1/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

enum CircleSize: String {
    case small, large
}

enum CircleStyle {
    case solid, bordered, outline
}

class Circle: UIView {
    
    init(size: CircleSize, color: UIColor, style: CircleStyle) {
        
        let radius: CGFloat = CGFloat(size == .small ? 12 : 32)
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
