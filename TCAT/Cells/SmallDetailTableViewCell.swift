//
//  RouteDetailTableView.swift
//  TCAT
//
//  Created by Matthew Barker on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class SmallDetailTableViewCell: UITableViewCell {
    
    var iconView: DetailIconView? = nil
    var titleLabel: UILabel!
    
    let cellHeight: CGFloat = RouteDetailCellSize.smallHeight
    let cellWidth: CGFloat = RouteDetailCellSize.regularWidth
    var iconViewFrame: CGRect = CGRect()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel = UILabel()
        titleLabel.frame = CGRect(x: cellWidth, y: 0, width: UIScreen.main.bounds.width - cellWidth - 20, height: 20)
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = .secondaryTextColor
        titleLabel.text = "Small Cell"
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        titleLabel.center.y = cellHeight / 2
        contentView.addSubview(titleLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCell(_ direction: Direction, busEnd: Bool, firstStep: Bool, lastStep: Bool) {
        
        let shouldAddSubview = iconView == nil
        
        iconView = DetailIconView(height: cellHeight,
                                  type: busEnd ? IconType.busEnd: IconType.noBus,
                                  time: direction.startTimeDescription,
                                  firstStep: firstStep,
                                  lastStep: lastStep)
        
        if shouldAddSubview {
            contentView.addSubview(iconView!)
        }
        
        if busEnd {
            // Arrive Direction
            titleLabel.attributedText = bold(pattern: direction.name, in: direction.locationNameDescription)
        } else {
            // Walk Direction
            var walkString = lastStep ? "Arrive at \(direction.name)" : direction.locationNameDescription
            var distanceInMiles = direction.travelDistanceInMiles
            let roundAmount = distanceInMiles < 10 ? 1 : 0
            let formattedDistance = distanceInMiles.roundToPlaces(places: roundAmount)
            if formattedDistance > 0 { walkString += " (\(formattedDistance) mi)" }
            titleLabel.attributedText = bold(pattern: direction.name, in: walkString)
            if lastStep {
                iconView?.changeTime(direction.endTimeDescription)
            }
        }
        
        titleLabel.sizeToFit()
        titleLabel.frame.size.width = UIScreen.main.bounds.width - cellWidth - 20
        titleLabel.center.y = cellHeight / 2
        
    }
    
}
