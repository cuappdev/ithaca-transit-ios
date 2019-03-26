//
//  NoRoutesTableViewCell.swift
//  Today Extension
//
//  Created by Yana Sang on 2/28/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

class TodayExtensionErrorCell: UITableViewCell {

    var boldLabel = UILabel()
    let mainLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        mainLabel.font = .getFont(.regular, size: 14.0)
        mainLabel.textColor = Colors.primaryText
        contentView.addSubview(mainLabel)

        boldLabel.font = .getFont(.medium, size: 14.0)
        boldLabel.textColor = Colors.primaryText
        contentView.addSubview(boldLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        boldLabel.snp.makeConstraints { make in
            let leading: CGFloat = 60.0

            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(leading)
        }

        mainLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            if (boldLabel.text == nil) {
                make.centerX.equalToSuperview()
            } else {
                make.leading.equalTo(boldLabel.snp.trailing)
            }
            make.width.equalTo(mainLabel.intrinsicContentSize.width)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
