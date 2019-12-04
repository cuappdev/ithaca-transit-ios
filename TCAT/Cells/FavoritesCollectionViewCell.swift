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
    private let minusImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        nameLabel.font = .systemFont(ofSize: 12, weight: .regular)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(nameLabel)
        
        contentView.addSubview(heartImageView)

        minusImageView.image = UIImage(named: "minus")
        contentView.addSubview(minusImageView)

        setupConstraints()
    }

    private func setupConstraints() {
        heartImageView.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.size.equalTo(56)
        }

        minusImageView.snp.makeConstraints { make in
            make.centerX.equalTo(heartImageView).offset(24)
            make.centerY.equalTo(heartImageView).offset(-16)
            make.size.equalTo(22)
        }

        nameLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(heartImageView.snp.bottom).offset(11)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(for place: Place, isEditing: Bool) {
        nameLabel.text = place.name
        let heartImage = isEditing ? "fadedHeart" : "blueHeart"
        heartImageView.image = UIImage(named: heartImage)
        minusImageView.isHidden = !isEditing
    }

}
