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

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
//        backgroundColor = .lightGray
//        nameLabel = UILabel()
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        nameLabel.font = .systemFont(ofSize: 16)
//        nameLabel.numberOfLines = 2
//        nameLabel.textColor = .white
//        nameLabel.textAlignment = .center
//        contentView.addSubview(nameLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
//        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
//        nameLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
//        nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
//        nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
//        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        print("In configure")
    }

}

