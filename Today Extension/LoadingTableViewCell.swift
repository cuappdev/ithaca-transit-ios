//
//  LoadingTableViewCell.swift
//  Today Extension
//
//  Created by Yana Sang on 3/6/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {

    let loadingIndicator = LoadingIndicator()
    let verticalMargin: CGFloat = 20.0 // top & bottom margin

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(loadingIndicator)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        loadingIndicator.snp.makeConstraints { make in
            make.top.equalTo(verticalMargin)
            make.bottom.equalToSuperview().inset(verticalMargin)
            make.width.equalTo(40.0)
            make.center.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
