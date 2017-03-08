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
    var titleLabelLeft: UILabel!
    var detailLabel: UILabel!
    var busIconView: BusIcon!
    var titleLabelRight: UILabel!
    var chevron: UIImageView!
    var detailTextView: UITextView!
    
    let cellHeight: CGFloat = 96
    var iconViewFrame: CGRect = CGRect()
    var isExpanded: Bool = false
    
    let grayColor = UIColor(red: 74 / 255, green: 74 / 255, blue: 74 / 255, alpha: 1)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabelLeft = UILabel()
        titleLabelLeft.frame = CGRect(x: 140, y: 0, width: 20, height: 20)
        titleLabelLeft.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        titleLabelLeft.textColor = grayColor
        titleLabelLeft.text = "Board"
        titleLabelLeft.sizeToFit()
        let labelOffset: CGFloat = (titleLabelLeft.frame.height / 2) + 4
        titleLabelLeft.center.y = (cellHeight / 2) - labelOffset
        contentView.addSubview(titleLabelLeft)
        
        titleLabelRight = UILabel()
        titleLabelRight.frame = CGRect(x: 140 + 48 + 8, y: 0, width: 20, height: 20)
        titleLabelRight.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        titleLabelRight.textColor = grayColor
        titleLabelRight.text = "Title Label"
        titleLabelRight.sizeToFit()
        titleLabelRight.center.y = (cellHeight / 2) - labelOffset
        contentView.addSubview(titleLabelRight)
        
        detailLabel = UILabel()
        detailLabel.frame = CGRect(x: 140, y: 0, width: 20, height: 20)
        detailLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        detailLabel.textColor = grayColor.withAlphaComponent(0.5)
        detailLabel.text = "Detail Label"
        detailLabel.sizeToFit()
        detailLabel.center.y = (cellHeight / 2) + labelOffset
        contentView.addSubview(detailLabel)
        
        chevron = UIImageView()
        chevron.frame.size = CGSize(width: 13.5, height: 8)
        chevron.frame.origin = CGPoint(x: UIScreen.main.bounds.width - 20 - chevron.frame.width, y: 0)
        chevron.image = UIImage(named: "chevron")
        chevron.alpha = 0.5
        contentView.addSubview(chevron)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("Something bad happened"); fatalError("init(coder:) has not been implemented")
    }
    
    func colorAttrString(pattern: String, attrString: NSMutableAttributedString, color: UIColor) -> NSMutableAttributedString {
        
        let attrString = NSMutableAttributedString(string: pattern)
        let colorAttribute = [NSForegroundColorAttributeName : color]
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let ranges = regex.matches(in: pattern, options: [], range: NSMakeRange(0, pattern.characters.count)).map {$0.range}
            for range in ranges { attrString.addAttributes(colorAttribute, range: range) }
        } catch { }
        
        return attrString
    }
    
    func busRouteAttrString(pattern: String, attrString: NSMutableAttributedString, color: UIColor = .blue) -> NSMutableAttributedString {
        
        let attrString = NSMutableAttributedString(string: pattern)
        let colorAttributes = [NSBackgroundColorAttributeName : color]
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let ranges = regex.matches(in: pattern, options: [], range: NSMakeRange(0, pattern.characters.count)).map {$0.range}
            for range in ranges { attrString.addAttributes(colorAttributes, range: range) }
        } catch { }
        
        return attrString
    }
    
    /** Precondition: Direction is BoardDirection */
    func setCell(_ direction: Direction, firstStep: Bool) {
        
        let boardDirection = direction as! DepartDirection
        let labelOffset: CGFloat = (titleLabelLeft.frame.height / 2) + 4
        let shouldAddIconView = iconView == nil
        let shouldAddBusIconView = busIconView == nil
        
        iconView = DetailIconView(height: cellHeight,
                                  type: IconType.busStart,
                                  time: direction.timeDescription,
                                  firstStep: firstStep,
                                  lastStep: false)
        
        if shouldAddIconView { contentView.addSubview(iconView!) }
        
        busIconView = BusIcon(size: .small, number: boardDirection.routeNumber)
        busIconView.frame.origin = CGPoint(x: titleLabelLeft.frame.maxX + 8, y: 0)
        busIconView.center.y = (cellHeight / 2) - labelOffset
        if shouldAddBusIconView { contentView.addSubview(busIconView) }
        
        titleLabelRight.attributedText = bold(pattern: direction.place, in: direction.placeDescription)
        titleLabelRight.frame.origin.x = busIconView.frame.maxX + 8
        titleLabelRight.sizeToFit()
        
        detailLabel.text = "\(boardDirection.stops.count) stops"
        detailLabel.sizeToFit()
        
        chevron.center.y = iconView.center.y
        
    }
    
    func getCellHeight() -> CGFloat { return cellHeight }
    
}

