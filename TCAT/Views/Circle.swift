//
//  Circle.swift
//  TCAT
//
//  Created by Matthew Barker on 3/1/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

enum CircleSize: Int{
    case small = 8, large = 16
}

enum CircleStyle {
    case solid, bordered, outline
}

class Circle: UIView {
    
    init(size: CircleSize, color: UIColor, style: CircleStyle){
        let radius: CGFloat = (size == .small) ? 8 : 16
        super.init(frame: CGRect(x: 0, y: 0, width: radius, height: radius))
        
        layer.cornerRadius = frame.width/2
        clipsToBounds = true
        
        switch style {
            case .solid:
                backgroundColor = color
            case .bordered:
                backgroundColor = .clear
                layer.borderColor = color.cgColor
                layer.borderWidth = 1.0
                
                let solidCircle = CALayer()
                solidCircle.frame = CGRect(x: 0, y: 0, width: 8, height: 8)
                solidCircle.position = center
                solidCircle.cornerRadius = solidCircle.frame.height/2
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
