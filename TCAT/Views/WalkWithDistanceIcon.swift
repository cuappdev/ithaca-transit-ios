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

    init(withDistance distance: Double) {
        travelDistanceLabel = UILabel()
        travelDistanceLabel.font = UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 12.0)
        travelDistanceLabel.textColor = .mediumGrayColor
        
        if distance > 0  {
            travelDistanceLabel.text = "\(roundedString(distance))"
            travelDistanceLabel.sizeToFit()
        }
        
        walkIcon = UIImageView(image: #imageLiteral(resourceName: "walk"))
        walkIcon.contentMode = .scaleAspectFit
        walkIcon.tintColor = .mediumGrayColor
        
        let width: CGFloat = travelDistanceLabel.frame.width > 0 ? travelDistanceLabel.frame.width : 34.0
        let height: CGFloat = walkIcon.frame.height + walkIconAndDistanceLabelVerticalSpace + travelDistanceLabel.frame.height
        
        super.init(frame: CGRect(origin: CGPoint.zero, size:  CGSize(width: width, height: height)))
        
        walkIcon.center.x = center.x
        travelDistanceLabel.center.x = center.x
        
        let oldFrame = travelDistanceLabel.frame
        travelDistanceLabel.frame = CGRect(x: oldFrame.minX, y: walkIcon.frame.maxY + walkIconAndDistanceLabelVerticalSpace, width: oldFrame.width, height: oldFrame.height)
        
        addSubview(walkIcon)
        addSubview(travelDistanceLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
