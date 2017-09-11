//
//  RouteLine.swift
//  TCAT
//
//  Created by Monica Ong on 5/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class RouteLine: UIView{
    
    let width: CGFloat = 1.0
    
    init(x: CGFloat, y: CGFloat, height: CGFloat){
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class SolidLine: RouteLine{
        
    init(x: CGFloat, y: CGFloat, height: CGFloat, color: UIColor){
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

class DashedLine: RouteLine {
    
    init(x: CGFloat, y: CGFloat, color: UIColor){
        super.init(x: x, y: y, height: 25)
        
        //Dashed line height and spacing for a total line height of 25.5 (the exact distance between stop dots')
        let dashHeight: CGFloat = 3
        let dashSpace: CGFloat = 1.5
        
        var nextDashYPos: CGFloat = 0
        for _ in 1...6{
            let line = CALayer()
            line.frame = CGRect(x: 0, y: nextDashYPos, width: frame.width, height: dashHeight)
            line.backgroundColor = color.cgColor
            nextDashYPos += (line.frame.height + dashSpace)
            layer.addSublayer(line)
        }
    }
        
    convenience init(color: UIColor) {
        self.init(x: 0, y: 0, color: color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
