//
//  RouteLine.swift
//  TCAT
//
//  Created by Monica Ong on 5/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class RouteLine: UIView {
    
    let width: CGFloat = 4.0
    
    init(x: CGFloat, y: CGFloat, height: CGFloat){
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class SolidLine: RouteLine {
    
    init(x: CGFloat, y: CGFloat, height: CGFloat, color: UIColor) {
        super.init(x: x, y: y, height: height)
        
        backgroundColor = color
    }
    
    convenience init(height: CGFloat, color: UIColor) {
        self.init(x: 0, y: 0, height: height, color: color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class DottedLine: RouteLine {
    
    init(x: CGFloat, y: CGFloat, height: CGFloat, color: UIColor){
        super.init(x: x, y: y, height: height)
        
        let dashHeight: CGFloat = 3.75
        let dashSpace: CGFloat = 4
        
        var nextDashYPos: CGFloat = dashSpace
        for _ in 0..<2{
            let line = CALayer()
            
            line.frame = CGRect(x: 0, y: nextDashYPos, width: frame.width, height: dashHeight)
            line.backgroundColor = color.cgColor
            line.cornerRadius = dashHeight/2
            
            layer.addSublayer(line)
            nextDashYPos += (line.frame.height + dashSpace)
        }
    }
        
    convenience init(height: CGFloat, color: UIColor) {
        self.init(x: 0, y: 0, height: height, color: color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
