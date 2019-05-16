//
//  PlaceTableViewCell.swift
//  TCAT
//
//  Created by Austin Astorga on 3/22/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class GeneralTableViewCell: UITableViewCell {

    private let imageHeight: CGFloat = 20
    private let imageWidth: CGFloat = 20
    private let labelWidthPadding: CGFloat = 45
    private let labelXPosition: CGFloat = 46

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        preservesSuperviewLayoutMargins = false
        separatorInset = .zero
        layoutMargins = .zero

        switch reuseIdentifier {
        case Constants.Cells.seeAllStopsIdentifier:

            textLabel?.text = Constants.General.seeAllStops
            textLabel?.frame.origin.x = labelXPosition
            textLabel?.frame.size.width = frame.width - labelWidthPadding

            imageView?.frame = CGRect(x: 16, y: 5, width: imageWidth, height: imageHeight)
            imageView?.center.y = bounds.height / 2
            imageView?.image = #imageLiteral(resourceName: "list")

            accessoryType = .disclosureIndicator
        case Constants.Cells.currentLocationIdentifier:
            textLabel?.text = Constants.General.currentLocation
            imageView?.image = #imageLiteral(resourceName: "location")
        default:
            break
        }

        textLabel?.font = .getFont(.regular, size: 14)

    }
}
