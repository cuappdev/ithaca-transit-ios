//
//  NoFavoritesCell.swift
//  Today Extension
//
//  Created by Yana Sang on 2/4/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

class NoFavoritesCell: UITableViewCell {

    let addFavoriteLabel = UILabel()
    let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addFavoriteLabel.font = .getFont(.medium, size: 14.0)
        addFavoriteLabel.textColor = Colors.primaryText
        addFavoriteLabel.text = "Add a Favorite "
        
        label.font = .getFont(.regular, size: 14.0)
        label.textColor = Colors.primaryText
        label.text = "to show favorite trips here."
        
        contentView.addSubview(addFavoriteLabel)
        contentView.addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addFavoriteLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(55.0)
            make.width.equalTo(addFavoriteLabel.intrinsicContentSize.width)
        }
        
        label.snp.makeConstraints { (make) in
            make.leading.equalTo(addFavoriteLabel.snp.trailing)
            make.centerY.equalToSuperview()
            make.width.equalTo(label.intrinsicContentSize.width)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
