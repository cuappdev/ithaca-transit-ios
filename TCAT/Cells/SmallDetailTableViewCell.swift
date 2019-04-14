//
//  RouteDetailTableView.swift
//  TCAT
//
//  Created by Matthew Barker on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class SmallDetailTableViewCell: UITableViewCell {

    var iconView: DetailIconView?
    var titleLabel: UILabel!

    let cellHeight: CGFloat = RouteDetailCellSize.smallHeight
    let cellWidth: CGFloat = RouteDetailCellSize.regularWidth
    var iconViewFrame: CGRect = CGRect()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel = UILabel()
        titleLabel.frame = CGRect(x: cellWidth, y: 0, width: UIScreen.main.bounds.width - cellWidth - 20, height: 20)
        titleLabel.font = .getFont(.regular, size: 14)
        titleLabel.textColor = Colors.primaryText
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

        let titleLabelBoldFont: UIFont = .getFont(.semibold, size: 14)

        if direction.type == .arrive {
            // Arrive Direction
            titleLabel.attributedText = direction.name.bold(in: direction.locationNameDescription,
                                                            from: titleLabel.font,
                                                            to: titleLabelBoldFont)
        } else {
            // Walk Direction
            var walkString = direction.locationNameDescription
            if direction.travelDistance > 0 {
                walkString += " (\(direction.travelDistance.roundedString))"
            }
            titleLabel.attributedText = direction.name.bold(in: walkString,
                                                            from: titleLabel.font,
                                                            to: titleLabelBoldFont)
        }

        titleLabel.sizeToFit()
        titleLabel.frame.size.width = UIScreen.main.bounds.width - cellWidth - 20
        titleLabel.center.y = cellHeight / 2

    }

}
