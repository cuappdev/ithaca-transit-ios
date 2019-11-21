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
        addLabel.textColor = Colors.notificationBlue
        addLabel.textAlignment = .center
        contentView.addSubview(addLabel)

        addImageView.image = UIImage(named: "addFavorite")
        contentView.addSubview(addImageView)

        setupConstraints()
    }

    private func setupConstraints() {
        addImageView.snp.makeConstraints{ make in
            make.centerX.top.equalToSuperview()
            make.size.equalTo(56)
        }

        addLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(addImageView.snp.bottom).offset(11)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
