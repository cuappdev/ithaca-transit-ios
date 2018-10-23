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

    var label: UILabel {
        let label = UILabel()
        label.font = .style(Fonts.SanFrancisco.regular, size: 12)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        return label
    }
    
    override init(reuseIdentifier: String?) {
        print("[PhraseLabelFooterView] init")
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        print("[PhraseLabelFooterView] updateConstraints")
        label.snp.makeConstraints { (make) in
            let constant: CGFloat = 8
            make.leading.equalToSuperview().offset(RouteDetailCellSize.regularWidth)
            make.trailing.equalToSuperview().offset(-constant)
        }
    }
    
    override func layoutSubviews() {
        print("[PhraseLabelFooterView] layoutSubviews")
        label.snp.makeConstraints { (make) in
            let constant: CGFloat = 8
            make.leading.equalToSuperview().offset(RouteDetailCellSize.regularWidth)
            make.trailing.equalToSuperview().offset(-constant)
        }
    }
    
    func setView(with message: String) {
        label.text = message
    }

}
