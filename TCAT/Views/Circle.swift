//
//  Circle.swift
//  TCAT
//
//  Created by Matthew Barker on 3/1/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

enum CircleStyle {
    case solid
    case bordered
    case outline
}

enum CircleSize {
    case small
    case large
}

class Circle: UIView {
    
    init(size: CircleSize, style: CircleStyle, color: UIColor) {
        
        let radius: CGFloat = size == .small ? 12 : 18
        super.init(frame: CGRect(x: 0, y: 0, width: radius, height: radius))
        
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
        
        switch style {
            
            case .solid:
                
                backgroundColor = color
            
            case .bordered:
                
                backgroundColor = .white
                layer.borderColor = color.cgColor
                layer.borderWidth = 2.0
                
                let solidCircle = CALayer()
                solidCircle.frame = CGRect(x: 0, y: 0, width: 8, height: 8)
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
