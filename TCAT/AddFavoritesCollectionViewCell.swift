//
//  AddFavoritesCollectionViewCell.swift
//  TCAT
//
//  Created by Lucy Xu on 11/7/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

class AddFavoritesCollectionViewCell: UICollectionViewCell {

    private let addImageView = UIImageView()
    private let addLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addLabel.text = "Add"
        addLabel.font = .systemFont(ofSize: 14, weight: .regular)
        addLabel.textColor = UIColor(hex: "08A0E0")
        addLabel.textAlignment = .center
        contentView.addSubview(addLabel)

        addImageView.image = UIImage(named: "favorite")
        addImageView.contentMode = .scaleAspectFit
        contentView.addSubview(addImageView)

        setupConstraints()
    }

    private func setupConstraints() {

        let addImageSize = 56
        let nameLabelTopPadding = 11

        addImageView.snp.makeConstraints{ make in
            make.centerX.top.equalToSuperview()
            make.size.equalTo(addImageSize)
        }

        addLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(addImageView.snp.bottom).offset(nameLabelTopPadding)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
