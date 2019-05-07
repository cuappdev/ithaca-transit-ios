//
//  PlaceTableViewCell.swift
//  TCAT
//
//  Created by Austin Astorga on 3/22/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

    var place: Place?

    private var iconColor: UIColor = Colors.metadataIcon

    let labelWidthPadding: CGFloat = 45.0
    let labelXPosition: CGFloat = 46.0
    let imageHeight: CGFloat = 20.0
    let imageWidth: CGFloat = 20.0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        preservesSuperviewLayoutMargins = false
        separatorInset = .zero
        layoutMargins = .zero

        textLabel?.text = place?.name
        detailTextLabel?.text = place?.description
        iconColor = place?.type == .busStop ? Colors.tcatBlue : Colors.metadataIcon
        imageView?.frame = CGRect(x: 16, y: 5, width: imageWidth, height: imageHeight)
        imageView?.contentMode = .scaleAspectFit
        imageView?.center.y = bounds.height / 2.0
        imageView?.image = place?.type == .busStop ? UIImage(named: "bus-pin") : UIImage(named: "pin")
        imageView?.tintColor = iconColor

        textLabel?.frame.origin.x = labelXPosition
        textLabel?.frame.size.width = frame.width - labelWidthPadding
        textLabel?.font = .getFont(.regular, size: 14) // has been size: 14 elsewhere

        detailTextLabel?.frame.origin.x = labelXPosition
        detailTextLabel?.frame.size.width = frame.width - labelWidthPadding
        detailTextLabel?.textColor = Colors.metadataIcon
        detailTextLabel?.font = .getFont(.regular, size: 12)

    }
}
