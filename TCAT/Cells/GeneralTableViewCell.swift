//
//  PlaceTableViewCell.swift
//  TCAT
//
//  Created by Austin Astorga on 3/22/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class GeneralTableViewCell: UITableViewCell {

    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel.font = .getFont(.regular, size: 14)

        contentView.addSubview(titleLabel)
        contentView.addSubview(iconView)

        setupConstraints()
    }

    func setupConstraints() {
        let iconLeadingInset = 16
        let iconSize = CGSize(width: 20, height: 20)
        let titleLabelHeight: CGFloat = 17
        let titleLabelLeadingInset = 10
        let titleLabelTrailingInset = 45

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(iconLeadingInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(iconSize)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(titleLabelLeadingInset)
            make.trailing.equalToSuperview().inset(titleLabelTrailingInset)
            make.centerY.equalToSuperview()
            make.height.equalTo(titleLabelHeight)
        }
    }

    func configure(for type: SectionType) {
        switch type {
        case .seeAllStops:
            titleLabel.text = Constants.General.seeAllStops
            iconView.image = #imageLiteral(resourceName: "list")
        case .currentLocation:
            titleLabel.text = Constants.General.currentLocation
            iconView.image = #imageLiteral(resourceName: "location")
        default: break
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
