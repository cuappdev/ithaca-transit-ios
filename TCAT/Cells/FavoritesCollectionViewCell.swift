//
//  FavoritesCollectionViewCell.swift
//  TCAT
//
//  Created by Lucy Xu on 11/4/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

class FavoritesCollectionViewCell: UICollectionViewCell {

    private let heartImageView = UIImageView()
    private let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        nameLabel.font = .systemFont(ofSize: 12, weight: .regular)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(nameLabel)

        heartImageView.contentMode = .scaleAspectFit
        contentView.addSubview(heartImageView)

        setupConstraints()
    }

    private func setupConstraints() {

        let heartImageSize = 56
        let nameLabelTopPadding = 11

        heartImageView.snp.makeConstraints{ make in
            make.centerX.top.equalToSuperview()
            make.size.equalTo(heartImageSize)
        }

        nameLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(heartImageView.snp.bottom).offset(nameLabelTopPadding)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(for place: Place, editing: Bool) {
        nameLabel.text = place.name
        if editing {
            heartImageView.image = UIImage(named: "removeFavorite")
        } else {
            heartImageView.image = UIImage(named: "favorite")
        }
    }

}


