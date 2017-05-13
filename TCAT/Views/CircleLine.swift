//
//  CircleLine.swift
//  TCAT
//
//  Created by Monica Ong on 5/9/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class CircleLine: UIView {
    
    var begSolidCircle: CALayer!
    var endSolidCircle: CALayer!
    var borderCircle: CALayer!
    var line: CALayer!
    
    let innerRadius: CGFloat = 8
    let outerRadius: CGFloat = 16
    let lineWidth: CGFloat = 1
    let lineHeight: CGFloat = 28
    
    
    init(color: UIColor, frame: CGRect){
        super.init(frame: frame)
        begSolidCircle = CALayer()
        begSolidCircle.frame = CGRect(x: 0, y: 0, width: innerRadius, height: innerRadius)
        begSolidCircle.cornerRadius = begSolidCircle.frame.height/2
        begSolidCircle.backgroundColor = color.cgColor
        
        line = CALayer()
        line.frame = CGRect(x: 0, y: begSolidCircle.frame.maxY, width: lineWidth, height: lineHeight)
        line.position.x = begSolidCircle.position.x
        line.backgroundColor = color.cgColor
        
        endSolidCircle = CALayer()
        endSolidCircle.frame = CGRect(x: 0, y: line.frame.maxY + innerRadius/2, width: innerRadius, height: innerRadius)
        endSolidCircle.position.x = begSolidCircle.position.x
        endSolidCircle.cornerRadius = endSolidCircle.frame.height/2
        endSolidCircle.backgroundColor = color.cgColor
        
        borderCircle = CALayer()
        borderCircle.frame = CGRect(x: 0, y: 0, width: outerRadius, height: outerRadius)
        borderCircle.position = endSolidCircle.position
        borderCircle.cornerRadius = borderCircle.frame.height/2
        borderCircle.backgroundColor = UIColor.clear.cgColor
        borderCircle.borderColor = color.cgColor
        borderCircle.borderWidth = 1.0
        
        layer.addSublayer(begSolidCircle)
        layer.addSublayer(line)
        layer.addSublayer(endSolidCircle)
        layer.addSublayer(borderCircle)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
