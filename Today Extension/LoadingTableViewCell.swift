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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(loadingIndicator)
        
        loadingIndicator.snp.makeConstraints { make in
            let width: CGFloat = 40.0
            let verticalMargin: CGFloat = 20.0 // top & bottom margin
            
            make.top.equalToSuperview().inset(verticalMargin)
            make.bottom.equalToSuperview().inset(verticalMargin)
            make.width.equalTo(width)
            make.center.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
