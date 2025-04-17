//
//  EcosystemFilterBallCollectionViewCell.swift
//  TCAT
//
//  Created by Asen Ou on 4/16/25.
//  Copyright © 2025 Cornell AppDev. All rights reserved.
//

import UIKit

class EcosystemFilterBallCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties (views)
    private let iconBg = UIView()
    private let iconView = UIImageView()
    private let label = UILabel()

    // MARK: - Properties (data)
    static let reuse = "EcosystemFilterBallCollectionViewCellReuse"
    private let iconSize = CGSize(width: 64, height: 64)

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()

        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Data config
    func configure(name: String, icon: UIImage, color: UIColor, isSelected: Bool) {
        label.text = name
        iconView.image = icon
        iconBg.backgroundColor = color
        contentView.alpha = isSelected ? 1.0 : 0.25
    }

    // MARK: - Setup Subviews
    private func setupUI() {
        setupIconBg()
        contentView.addSubview(iconBg)

        setupIcon()
        contentView.addSubview(iconView)

        setupLabel()
        contentView.addSubview(label)
    }

    private func setupIconBg() {
        iconBg.layer.cornerRadius = iconSize.height / 2
        iconBg.clipsToBounds = true
    }

    private func setupIcon() {
    }

    private func setupLabel() {
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
    }

    private func setupConstraints() {
        iconBg.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(iconSize)
            make.left.right.equalToSuperview()
        }

        iconView.snp.makeConstraints { make in
            make.centerX.equalTo(iconBg.snp.centerX)
            make.centerY.equalTo(iconBg.snp.centerY)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(iconBg.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(16)
        }
    }
}
