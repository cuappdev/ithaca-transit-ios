//
//  CircleLine.swift
//  TCAT
//
//  Created by Monica Ong on 5/9/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class CircleLine: UIView {
    
    // MARK: View vars
    
    var solidCircle: Circle!
    var line: SolidLine!
    var borderedCircle: Circle!
    
    // MARK: Spacing vars
    
    let superviewWidth: CGFloat = 16
    let superviewHeight: CGFloat = 56
    let lineHeight: CGFloat = 27
    
    init(color: UIColor){
        super.init(frame: CGRect(x: 0, y: 0, width: superviewWidth, height: superviewHeight))
        
        solidCircle = Circle(size: .small, color: color, style: .solid)
        line = SolidLine(height: lineHeight, color: color)
        borderedCircle = Circle(size: .medium, color: color, style: .bordered)
        
        positionSolidCircle()
        positionLine(usingSolidCircle: solidCircle)
        positionBorderedCircle(usingLine: line)
        
        addSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Position
    
    private func positionSolidCircle(){
        solidCircle.center.x = center.x
    }
    
    private func positionLine(usingSolidCircle solidCircle: Circle){
        line.center.x = solidCircle.center.x
        
        let oldFrame = line.frame
        let newFrame = CGRect(x: oldFrame.minX, y: solidCircle.frame.maxY, width: oldFrame.width, height: oldFrame.height)
        
        line.frame = newFrame
    }
    
    private func positionBorderedCircle(usingLine line: RouteLine){
        let oldFrame = borderedCircle.frame
        let newFrame = CGRect(x: oldFrame.minX, y: line.frame.maxY, width: oldFrame.width, height: oldFrame.height)
        
        borderedCircle.frame = newFrame
        
        borderedCircle.center.x = line.center.x
    }
    
    // MARK: Add subviews
    
    private func addSubviews(){
        addSubview(solidCircle)
        addSubview(line)
        addSubview(borderedCircle)
    }

}
