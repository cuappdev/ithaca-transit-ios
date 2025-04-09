//
//  SettingsTableViewCell.swift
//  TCAT
//
//  Created by Asen Ou on 3/4/25.
//  Copyright © 2025 Cornell AppDev. All rights reserved.
//

import SnapKit
import UIKit

class SettingsTableViewCell: UITableViewCell {

    // MARK: - Properties (view)
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    // MARK: - Properties (data)
    static let reuse: String = "SettingsTableViewCellReuse"

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Data config
    func configure(image: UIImage?, title: String, subtitle: String) {
        iconView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    // MARK: - View setup
    private func setUpUI() {

        setUpIcon()
        contentView.addSubview(iconView)

        setUpLabels()
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        setUpConstraints()
    }

    private func setUpIcon() {
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = Colors.black
    }

    private func setUpLabels() {
        titleLabel.textColor = .black
        titleLabel.font = .getFont(.regular, size: 20)

        subtitleLabel.textColor = .gray
        subtitleLabel.font = .getFont(.regular, size: 14)
    }

    private func setUpConstraints() {
        let iconLeftXInset = 30
        let iconTextSpacing = 15
        let textRightXInset = 60
        let textYInset = 18

        iconView.snp.makeConstraints { make in
//            make.right.equalTo(titleLabel.snp.left).offset(-15)
//            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(iconLeftXInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(33)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(iconTextSpacing)
            make.right.equalToSuperview().inset(textRightXInset)

            make.top.equalToSuperview().inset(textYInset)
            make.bottom.equalTo(subtitleLabel.snp.top)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(iconTextSpacing)
            make.right.equalToSuperview().inset(textRightXInset)

            make.bottom.equalToSuperview().inset(textYInset)
        }
    }

}
