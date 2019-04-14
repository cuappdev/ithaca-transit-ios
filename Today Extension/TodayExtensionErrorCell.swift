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
        mainLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
