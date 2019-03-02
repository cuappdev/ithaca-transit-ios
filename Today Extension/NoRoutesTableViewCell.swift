//
//  NoRoutesTableViewCell.swift
//  Today Extension
//
//  Created by Yana Sang on 2/28/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

class NoRoutesCell: UITableViewCell {

    let noRoutesLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        noRoutesLabel.font = .getFont(.regular, size: 14.0)
        noRoutesLabel.textColor = Colors.primaryText
        noRoutesLabel.text = "Unable to Load Routes"

        contentView.addSubview(noRoutesLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        noRoutesLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(noRoutesLabel.intrinsicContentSize.width)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
