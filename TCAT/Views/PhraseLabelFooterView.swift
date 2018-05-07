//
//  PhraseLabelFooterView.swift
//  TCAT
//
//  Created by Matt Barker on 4/29/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit
import SnapKit

class PhraseLabelFooterView: UITableViewHeaderFooterView {

    var label: UILabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        
        label.font = UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 12)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupView(labelText: String) {
        
        if label.text == "" {
            label.text = labelText
            contentView.addSubview(label)
        }

        label.snp.makeConstraints { (make) in
            let constant: CGFloat = 8
            make.leading.equalToSuperview().offset(RouteDetailCellSize.regularWidth)
            make.trailing.equalToSuperview().offset(-constant)
        }
        
    }

}
