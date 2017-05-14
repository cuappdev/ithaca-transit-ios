//
//  DottedLine.swift
//  TCAT
//
//  Created by Monica Ong on 5/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class DottedLine: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
        //So to only make height of 21 (the exact distance between stop dots')
        let lineHeight: CGFloat = 3
        let lineSpace: CGFloat = 1.5
        var lineY: CGFloat = 0
        for _ in 1...5{
            let line = CALayer()
            line.frame = CGRect(x: 0, y: lineY, width: frame.width, height: lineHeight)
            line.backgroundColor = UIColor.mediumGrayColor.cgColor
            lineY += (line.frame.height + lineSpace)
            layer.addSublayer(line)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
