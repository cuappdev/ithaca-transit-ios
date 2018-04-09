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
    
    func setCell(_ direction: Direction, firstStep: Bool, lastStep: Bool) {
        
        let shouldAddSubview = iconView == nil

        if shouldAddSubview {
            iconView = DetailIconView(direction: direction, height: cellHeight, firstStep: firstStep, lastStep: lastStep)
            contentView.addSubview(iconView!)
        } else {
            iconView?.updateTimes(with: direction, isLast: lastStep)
        }
        
        if direction.type == .arrive {
            // Arrive Direction
            titleLabel.attributedText = bold(pattern: direction.name, in: direction.locationNameDescription)
        } else {
            // Walk Direction
            var walkString = direction.locationNameDescription
            if direction.travelDistance > 0 {
                walkString += " (\(direction.travelDistance.roundedString))"
            }
            titleLabel.attributedText = bold(pattern: direction.name, in: walkString)
        }
        
        titleLabel.sizeToFit()
        titleLabel.frame.size.width = UIScreen.main.bounds.width - cellWidth - 20
        titleLabel.center.y = cellHeight / 2
        
    }
    
}
