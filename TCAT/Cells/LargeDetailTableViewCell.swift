//
//  LargeDetailTableViewCell.swift
//  TCAT
//
//  Created by Matthew Barker on 2/13/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class LargeDetailTableViewCell: UITableViewCell {
    
    var iconView: DetailIconView!
    var titleLabel: UILabel!
    var detailLabel: UILabel!
    var busIconView: BusIcon!
    var chevron: UIImageView!
    
    let paragraphStyle = NSMutableParagraphStyle()
    let cellWidth: CGFloat = RouteDetailCellSize.regularWidth
    var cellHeight: CGFloat = RouteDetailCellSize.largeHeight
    
    var direction: Direction!
    var isExpanded: Bool = false
    let edgeSpacing: CGFloat = 16
    let labelSpacing: CGFloat = 4
    
    func getChevron() -> UIImageView {
        let chevron = UIImageView()
        chevron.frame.size = CGSize(width: 13.5, height: 8)
        chevron.frame.origin = CGPoint(x: UIScreen.main.bounds.width - 20 - chevron.frame.width, y: 0)
        chevron.image = UIImage(named: "arrow")
        chevron.tintColor = .mediumGrayColor
        return chevron
    }
    
    func getTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: cellWidth, y: 0, width: chevron.frame.minX - cellWidth, height: 20)
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textColor = .primaryTextColor
        titleLabel.text = "Board"
        titleLabel.sizeToFit()
        return titleLabel
    }
    
    func getDetailLabel() -> UILabel {
        let detailLabel = UILabel()
        detailLabel.frame = CGRect(x: cellWidth, y: 0, width: 20, height: 20)
        detailLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        detailLabel.textColor = .mediumGrayColor
        detailLabel.text = "Detail Label"
        detailLabel.lineBreakMode = .byWordWrapping
        detailLabel.sizeToFit()
        return detailLabel
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        chevron = getChevron()
        contentView.addSubview(chevron)
        
        titleLabel = getTitleLabel()
        contentView.addSubview(titleLabel)
        
        detailLabel = getDetailLabel()
        contentView.addSubview(detailLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /** Precondition: Direction is BoardDirection */
    func setCell(_ direction: Direction, firstStep: Bool) {
                
        self.direction = direction
        cellHeight = height()
        
        let shouldAddViews = iconView == nil || busIconView == nil ||
            titleLabel == nil || detailLabel == nil
        
        if shouldAddViews {
            iconView = DetailIconView(height: cellHeight,
                                      type: IconType.busStart,
                                      time: direction.startTimeDescription,
                                      firstStep: firstStep,
                                      lastStep: false)
            contentView.addSubview(iconView!)
            
            busIconView = BusIcon(type: .directionSmall, number: self.direction.routeNumber)
            busIconView = formatBusIconView(busIconView, titleLabel)
            contentView.addSubview(busIconView)
            
            titleLabel = formatTitleLabel(titleLabel)
            detailLabel = formatDetailLabel(detailLabel, titleLabel)
            
            // Place bus icon and chevron accordingly
            if titleLabel.frame.height > 60 {
                busIconView.frame.origin.y = titleLabel.frame.minY + (titleLabel.font.lineHeight / 2)
            }
            chevron.center.y = cellHeight / 2
        }
        
    }
    
    /** Abstracted formatting of content for titleLabel */
    func formatTitleLabel(_ label: UILabel) -> UILabel {
        
        // Add correct amount of spacing to create a gap for the busIcon
        // Using constant always returned from
        //      while label.frame.maxX < busIconView.frame.maxX + 8 {
        // because it will occasionally run infinitely because of format func calls
        var accum = 0
        while accum <= 16 {
            accum += 1
            label.text! += " "
            label.sizeToFit()
        }
        
        // Format and place labels
        let attributedString = NSMutableAttributedString(string: label.text!)
        attributedString.append(bold(pattern: self.direction.locationName,
                                     in: self.direction.locationNameDescription))
        label.attributedText = attributedString
        paragraphStyle.lineSpacing = 8
        
        label.numberOfLines = 0
        label.sizeToFit()
        label.frame.size.width = (chevron.frame.minX - 12) - cellWidth
        label.frame.origin.y = edgeSpacing // - paragraphStyle.lineSpacing
        
        attributedString.addAttribute(NSParagraphStyleAttributeName,
                                      value: paragraphStyle,
                                      range: NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        
        return label
    }
    
    /** Abstracted formatting of content for detailLabel. Needs titleLabel */
    func formatDetailLabel(_ label: UILabel, _ titleLabel: UILabel) -> UILabel {
        label.text = "\(self.direction.busStops.count) stops"
        label.frame.origin.y = titleLabel.frame.maxY + labelSpacing
        label.sizeToFit()
        return label
    }
    
    /** Abstracted formatting of content for busIconView. Needs initialized titleLabel */
    func formatBusIconView(_ icon: BusIcon, _ titleLabel: UILabel) -> BusIcon {
        icon.frame.origin = CGPoint(x: titleLabel.frame.maxX + 8,
                                    y: titleLabel.frame.minY + titleLabel.font.lineHeight)
        return icon
    }
    
    /** Precondition: setCell must be called before using this function */
    func height() -> CGFloat {
        let titleLabel = formatTitleLabel(getTitleLabel())
        let detailLabel = formatDetailLabel(getDetailLabel(), titleLabel)
        return titleLabel.frame.height + detailLabel.frame.height + labelSpacing + (edgeSpacing * 2)
    }
    
}

