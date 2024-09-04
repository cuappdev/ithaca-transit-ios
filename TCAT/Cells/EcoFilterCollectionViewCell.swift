//
//  EcoFilterCollectionViewCell.swift
//  TCAT
//
//  Created by Jayson Hahn on 5/5/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation
import UIKit

class EcoFilterCollectionViewCell: UICollectionViewCell {

    private var circleView = UIImageView(image: UIImage(systemName: "circle.fill"))
    private var filterLabel = UILabel()
    private var symbol = UIImageView()


    static let reuse = "EcoFilterCellReuseIdentifier"

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .clear

        setupNameLabel()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(circleView)
        symbol.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(symbol)

        setupConstraints()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(filterColor: UIColor, filtername: String, filterSymbol: String) {
        circleView.tintColor = filterColor
        symbol.image = UIImage(named: filterSymbol)
        filterLabel.text = filtername
    }

    func setupNameLabel() {
        filterLabel.font = .systemFont(ofSize: 14, weight: .regular)
        filterLabel.textColor = UIColor(hex: "616161")
        filterLabel.textAlignment = .center
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(filterLabel)
    }

    func setupConstraints() {
        filterLabel.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
        }

        circleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(circleView.snp.width)
        }

        symbol.snp.makeConstraints { make in
            make.centerX.equalTo(circleView.snp.centerX)
            make.centerY.equalTo(circleView.snp.centerY)
        }

    }

}
