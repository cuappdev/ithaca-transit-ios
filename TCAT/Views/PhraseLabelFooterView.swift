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

    private var label: UILabel!

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = Colors.white
        contentView.frame.size = CGSize(width: UIScreen.main.bounds.size.width, height: RouteDetailCellSize.largeHeight)

        setupLabel()
        setupConstraints()
    }

    private func setupLabel() {
        label = UILabel()
        label.font = .getFont(.regular, size: 12)
        label.textColor = Colors.metadataIcon
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping

        addSubview(label)
    }

    private func setupConstraints() {
        let topPadding: CGFloat = 20
        label.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(topPadding)
        }
    }

    func configure(with message: String) {
        label.text = message
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
