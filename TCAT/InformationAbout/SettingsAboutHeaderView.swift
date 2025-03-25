//
//  SettingsAboutHeaderView.swift
//  TCAT
//
//  Created by Asen Ou on 3/16/25.
//  Copyright © 2025 Cornell AppDev. All rights reserved.
//

import UIKit

class SettingsAboutHeaderView: UIView {

    private let stackView = UIStackView()

    private let logoView = UIImageView()
    private let subtitleLabel = UILabel()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.alignment = .center
        stackView.axis = .vertical

        stackView.addArrangedSubview(logoView)
        setUpLogoView()
        stackView.setCustomSpacing(12, after: logoView)

        stackView.addArrangedSubview(subtitleLabel)
        setUpSubtitleLabel()
        stackView.setCustomSpacing(0, after: subtitleLabel)

        stackView.addArrangedSubview(titleLabel)
        setUpTitleLabel()
    }

    private func setUpLogoView() {
        logoView.image = UIImage(named: "appDevLogo")
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.text = "DESIGNED AND DEVELOPED BY"
        let fontSize = UIFont.preferredFont(forTextStyle: .caption1).pointSize
        subtitleLabel.font = .systemFont(ofSize: fontSize, weight: .medium)
//        subtitleLabel.font = .preferredFont(for: .caption1, weight: .medium)
//        subtitleLabel.textColor = UIColor
    }

    private func setUpTitleLabel() {
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: "Cornell", attributes: [
            .font: UIFont.systemFont(ofSize: 36, weight: .regular)
        ]))
        attributedText.append(NSAttributedString(string: "AppDev", attributes: [
            .font: UIFont.systemFont(ofSize: 36, weight: .semibold)
        ]))
        titleLabel.attributedText = attributedText
        titleLabel.textColor = .black
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(layoutMarginsGuide)
        }

        logoView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
    }

}
