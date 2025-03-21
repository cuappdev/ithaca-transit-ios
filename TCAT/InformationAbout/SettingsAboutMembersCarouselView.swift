//
//  SettingsAboutCarouselView.swift
//  TCAT
//
//  Created by Asen Ou on 3/16/25.
//  Copyright © 2025 Cornell AppDev. All rights reserved.
//

import UIKit

class SettingsAboutMembersCarouselView: UIView {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        addSubview(scrollView)
        setUpScrollView()
    }

    private func setUpScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
    }

    private func setUpConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.equalTo(layoutMarginsGuide)
        }
    }

    func addTitleView(_ title: String) {
        let label = UILabel()
//        label.font = .preferredFont(for: .footnote, weight: .semibold)
        label.font = .preferredFont(forTextStyle: .footnote)
        label.text = title

        stackView.addArrangedSubview(label)
    }

    func addMemberView(name: String) {
        let label = UILabel()
//        label.font = .preferredFont(for: .footnote, weight: .semibold)
        label.font = .preferredFont(forTextStyle: .footnote)
        label.text = name

        let container = ContainerView(pillContent: label)
        container.layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        container.backgroundColor = Colors.carouselGray

        stackView.addArrangedSubview(container)
    }

    func addSeparator() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "separatorStar")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Colors.carouselGray
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(8)
        }

        stackView.addArrangedSubview(imageView)
    }

    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()

        scrollView.contentInset = layoutMargins
    }

}
