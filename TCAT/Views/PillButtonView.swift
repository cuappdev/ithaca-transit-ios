//
//  PillButtonView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class PillButtonView: UIView {

    private let container = UIView()
    let imageView = UIImageView()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(container)
        setUpContainer()
    }

    private func setUpContainer() {
        container.addSubview(imageView)
        setUpImageView()

        container.addSubview(titleLabel)
        setUpTitleLabel()
    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFit
    }

    private func setUpTitleLabel() {
//        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.font = .preferredFont(forTextStyle: .body)
    }

    private func setUpConstraints() {
        container.snp.makeConstraints { make in
            make.centerX.top.bottom.equalTo(layoutMarginsGuide)
            make.leading.greaterThanOrEqualTo(layoutMarginsGuide)
            make.trailing.lessThanOrEqualTo(layoutMarginsGuide)
        }

        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.leading.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(4)
            make.top.trailing.bottom.equalToSuperview()
        }

        titleLabel.setContentHuggingPriority(
            imageView.contentHuggingPriority(for: .horizontal) + 1,
            for: .horizontal
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }

}
