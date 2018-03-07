//
//  WalkWithDistanceIcon.swift
//  TCAT
//
//  Created by Monica Ong on 3/7/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit

class WalkWithDistanceIcon: UIView {

    // MARK: View vars
    
    var walkIcon: UIImageView
    var travelDistanceLabel: UILabel
    
    // MARK: Spacing vars
    
    let walkIconAndDistanceLabelVerticalSpace: CGFloat = 2.0

    init(walkIcon: UIImageView, travelDistanceLabel: UILabel) {
        self.walkIcon = walkIcon
        self.travelDistanceLabel = travelDistanceLabel
        
        let width: CGFloat = travelDistanceLabel.frame.width > 0 ? travelDistanceLabel.frame.width : 34.0
        let height: CGFloat = walkIcon.frame.height + walkIconAndDistanceLabelVerticalSpace + travelDistanceLabel.frame.height
        
        super.init(frame: CGRect(origin: CGPoint.zero, size:  CGSize(width: width, height: height)))
        
        self.walkIcon.center.x = center.x
        self.travelDistanceLabel.center.x = center.x
        
        let oldFrame = self.travelDistanceLabel.frame
        self.travelDistanceLabel.frame = CGRect(x: oldFrame.minX, y: self.walkIcon.frame.maxY + walkIconAndDistanceLabelVerticalSpace, width: oldFrame.width, height: oldFrame.height)
        
        addSubview(self.walkIcon)
        addSubview(self.travelDistanceLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
