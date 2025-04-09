//
//  SettingsAppIconCollectionViewCell.swift
//  TCAT
//
//  Created by Asen Ou on 3/21/25.
//  Copyright © 2025 Cornell AppDev. All rights reserved.
//

import UIKit

class SettingsAppIconCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties (view)
    private let centerLabel = UILabel()
    private let iconView = UIImageView()

    // MARK: - Properties (data)
    static let reuse: String = "SettingsAppIconCollectionViewCellReuse"

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .black

        setUpUI()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Data config
    func configure(image: UIImage?, isSelected: Bool) {
        iconView.image = image
    }

    // MARK: - View setup
    private func setUpUI() {
        centerLabel.text = "*icon*"
        centerLabel.font = UIFont.systemFont(ofSize: 6, weight: .bold)
        centerLabel.textColor = .white
        centerLabel.textAlignment = .center
        contentView.addSubview(centerLabel)

        setUpIcon()
        contentView.addSubview(iconView)
    }

    private func setUpIcon() {
        //
        iconView.contentMode = .scaleAspectFit
    }

    // MARK: - Constraints
    private func setUpConstraints() {
        centerLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
