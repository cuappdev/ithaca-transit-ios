//
//  WalkWithDistanceIcon.swift
//  TCAT
//
//  Created by Monica Ong on 3/7/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit

class WalkWithDistanceIcon: UIView {

    // MARK: Size vars

    let width: CGFloat
    let height: CGFloat

    // MARK: View vars

    var walkIcon: UIImageView
    var travelDistanceLabel: UILabel

    // MARK: Spacing vars

    let walkIconAndDistanceLabelVerticalSpace: CGFloat = 2.0

    // MARK: Constraint var

    override var intrinsicContentSize: CGSize {
        return CGSize(width: width, height: height)
    }

    // MARK: Init

    init(withDistance distance: Double) {
        travelDistanceLabel = UILabel()
        travelDistanceLabel.font = .getFont(.regular, size: 12.0)
        travelDistanceLabel.textColor = Colors.metadataIcon

        if distance > 0 {
            travelDistanceLabel.text = "\(distance.roundedString)"
            travelDistanceLabel.sizeToFit()
        }

        walkIcon = UIImageView(image: #imageLiteral(resourceName: "walk"))
        walkIcon.contentMode = .scaleAspectFit
        walkIcon.tintColor = Colors.metadataIcon

        width = travelDistanceLabel.frame.width > 0 ? travelDistanceLabel.frame.width : 34.0
        height = walkIcon.frame.height + walkIconAndDistanceLabelVerticalSpace + travelDistanceLabel.frame.height

        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height)))

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
