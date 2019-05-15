//
//  PlaceTableViewCell.swift
//  TCAT
//
//  Created by Austin Astorga on 3/22/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

    private let iconView = UIImageView()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        print(frame.height)
        iconView.contentMode = .scaleAspectFit
        contentView.addSubview(iconView)

        nameLabel.font = .getFont(.regular, size: 14) // has been size: 14 elsewhere
        contentView.addSubview(nameLabel)

        descriptionLabel.textColor = Colors.metadataIcon
        descriptionLabel.font = .getFont(.regular, size: 12)
        contentView.addSubview(descriptionLabel)

        setupConstraints()
    }

    func setupConstraints() {
        let descriptionLabelHeight: CGFloat = 14.5
        let iconSize = CGSize(width: 20, height: 20)
        let iconLeadingInset = 16
        let nameLabelHeight: CGFloat = 17
        let nameLabelLeadingInset = 10
        let placeNameToDescriptionSpacing: CGFloat = 2.5 // Standard number from apple's UITableviewCell with .subtitle style
        let trailingInset = 45

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(iconLeadingInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(iconSize)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(nameLabelLeadingInset)
            make.trailing.equalToSuperview().inset(trailingInset)
            make.bottom.equalTo(contentView.snp.centerY).offset(-placeNameToDescriptionSpacing / 2)
            make.height.equalTo(nameLabelHeight)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(contentView.snp.centerY).offset(placeNameToDescriptionSpacing / 2)
            make.height.equalTo(descriptionLabelHeight)
        }
    }

    func configureCell(for place: Place) {
        iconView.tintColor = place.type == .busStop ? Colors.tcatBlue : Colors.metadataIcon
        iconView.image = place.type == .busStop ? UIImage(named: "bus-pin") : UIImage(named: "pin")
        nameLabel.text = place.name
        descriptionLabel.text = place.description
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
