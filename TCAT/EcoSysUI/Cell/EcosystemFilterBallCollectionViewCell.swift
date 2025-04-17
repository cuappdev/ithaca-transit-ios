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
    private let iconView = UIImageView()
    private let label = UILabel()

    // MARK: - Properties (data)
    static let reuse = "EcosystemFilterBallCollectionViewCellReuse"

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
    func configure(name: String, icon: UIImage, color: UIColor) {
        label.text = name
        iconView.image = icon
        iconView.backgroundColor = color
    }

    // MARK: - Setup Subviews
    private func setupUI(){
        setupIcon()
        contentView.addSubview(iconView)

        setupLabel()
        contentView.addSubview(label)
    }

    private func setupIcon() {
//        iconView.mask = Circle(size: .medium, style: .outline, color: .clear)
    }

    private func setupLabel() {
        // change font and etc.
    }

    private func setupConstraints() {
        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(64)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(16)
        }
    }
}
