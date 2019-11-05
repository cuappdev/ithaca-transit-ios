//
//  FavoritesCollectionViewCell.swift
//  TCAT
//
//  Created by Lucy Xu on 11/4/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

class FavoritesCollectionViewCell: UICollectionViewCell {

    var nameLabel: UILabel!
    var favoritesCircle: UIView!
    var heartImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 12, weight: .regular)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(nameLabel)

        favoritesCircle = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
        favoritesCircle.center = contentView.center
        favoritesCircle.backgroundColor = Colors.tcatBlue
        favoritesCircle.layer.cornerRadius = 28
        contentView.addSubview(favoritesCircle)

        heartImageView = UIImageView(image: UIImage(named: "heart"))
        heartImageView.contentMode = .scaleAspectFit
        contentView.addSubview(heartImageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        favoritesCircle.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(56)
            make.width.equalTo(56)
            make.centerX.equalToSuperview()
        }

        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(favoritesCircle.snp.bottom).offset(11)
        }

        heartImageView.snp.makeConstraints{ make in
            make.centerX.equalTo(favoritesCircle.snp.centerX)
            make.centerY.equalTo(favoritesCircle.snp.centerY)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(for name: String) {
        nameLabel.text = name
    }

}

