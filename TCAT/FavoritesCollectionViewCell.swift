//
//  FavoritesCollectionViewCell.swift
//  TCAT
//
//  Created by Lucy Xu on 11/4/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

class FavoritesCollectionViewCell: UICollectionViewCell {

    private var nameLabel: UILabel!
    private var heartImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 12, weight: .regular)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(nameLabel)

        heartImageView = UIImageView(image: UIImage(named: "favorite"))
        heartImageView.contentMode = .scaleAspectFit
        contentView.addSubview(heartImageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let heartImageSize = 56
        let nameLabelTopPadding = 11

        heartImageView.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(heartImageSize)
            make.width.equalTo(heartImageSize)
        }

        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(heartImageView.snp.bottom).offset(nameLabelTopPadding)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(for name: String) {
        nameLabel.text = name
    }

}

