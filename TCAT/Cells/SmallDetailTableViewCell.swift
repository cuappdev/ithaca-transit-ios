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
        print("Something bad happened"); fatalError("init(coder:) has not been implemented")
    }
    
    func setCell(_ direction: Direction, busEnd: Bool, firstStep: Bool, lastStep: Bool) {
        
        let shouldAddSubview = iconView == nil
        iconView = DetailIconView(height: cellHeight,
                                  type: busEnd ? IconType.busEnd: IconType.noBus,
                                  time: direction.timeDescription,
                                  firstStep: firstStep,
                                  lastStep: lastStep)
        
        if shouldAddSubview { contentView.addSubview(iconView!) }
        
        if busEnd {
            let busDirection = direction as! ArriveDirection
            titleLabel.attributedText = bold(pattern: busDirection.place, in: busDirection.placeDescription)
        } else {
            let walkDirection = direction as! WalkDirection
            let walkString = walkDirection.placeDescription + " (\(walkDirection.travelDistance.roundToPlaces(places: 1)) mi)"
            titleLabel.attributedText = bold(pattern: walkDirection.place, in: walkString)
        }
        
        titleLabel.sizeToFit()
        titleLabel.frame.size.width = UIScreen.main.bounds.width - cellWidth - 20
        titleLabel.center.y = cellHeight / 2
        
    }
    
}
