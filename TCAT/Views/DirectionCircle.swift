//
//  File.swift
//  TCAT
//
//  Created by Matthew Barker on 3/1/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

enum CircleType: String {
    case standardOn, standardOff, finishOn, finishOff, busStop
}

class DirectionCircle: UIView {
    
    var type: CircleType!

    
    init(_ type: CircleType) {
        
        let isStandard = type != .finishOn && type != .finishOff
        
        let radius = !isStandard ? 16 : 8
        super.init(frame: CGRect(x: 0, y: 0, width: radius, height: radius))
        
        layer.cornerRadius = frame.size.width / 2
        clipsToBounds = true
        
        if !isStandard {
            backgroundColor = .clear
            layer.borderColor = (type == .finishOn) ? UIColor.tcatBlue.cgColor : UIColor.gray.cgColor
            layer.borderWidth = 1.0
            let innerCircle = DirectionCircle(type == .finishOn ? .standardOn : .standardOff)
            innerCircle.center = center
            addSubview(innerCircle)
        } else {
            backgroundColor = type == .standardOff ? .gray :  UIColor.tcatBlue
            if type == .busStop {
                backgroundColor = .white
                layer.borderColor =  UIColor.tcatBlue.cgColor
                layer.borderWidth = 1.0
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
