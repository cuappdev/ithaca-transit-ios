//
//  FunSpotCardViewController.swift
//  TCAT
//
//  Created by Gabriel Castillo on 4/8/26.
//  Copyright © 2026 cuappdev. All rights reserved.
//

import SnapKit
import UIKit

class FunSpotCardViewController: SnapCardViewController {

    // MARK: - SnapCardViewController overrides

    override var snapHeights: [CGFloat] { [300, 500] }
    override var dragIndicatorColor: UIColor { Colors.white }

    // MARK: - Constants

    private let imageHeight: CGFloat = 150
    private let buttonHeight: CGFloat = 40
    private let buttonWidth: CGFloat = 159
    private let horizontalPadding: CGFloat = 16

    // MARK: - Subviews

    private let imageView = UIImageView()
    private let contentClipView = UIView()
    private let contentStack = UIStackView()

    // Title row
    private let titleRow = UIView()
    private let locationTitleLabel = UILabel()
    private let categoryIconCircle = UIView()
    private let categoryIconView = UIImageView()
    private let starButton = UIButton(type: .system)

    // Address
    private let addressLabel = UILabel()

    // Expanded-only content
    private let expandedStack = UIStackView()
    private let separatorView = UIView()
    private let aboutLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let quoteLabel = UILabel()

    // Buttons row
    private let buttonsRow = UIView()
    private let shareButton = UIButton(type: .system)
    private let directionsButton = UIButton(type: .system)

    // MARK: - Data

    private var funSpot: FunSpot

    // MARK: - Init

    init(funSpot: FunSpot) {
        self.funSpot = funSpot
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupConstraints()
        configure(with: funSpot)
        expandedStack.isHidden = true
        expandedStack.alpha = 0
    }

    // MARK: - Setup

    private func setupSubviews() {
        // top corners masked to match card rounding
        imageView.backgroundColor = Colors.backgroundWash
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cardView.addSubview(imageView)
        // dragIndicator was added in base class before imageView — bring it above
        cardView.bringSubviewToFront(dragIndicator)

        contentClipView.clipsToBounds = true
        cardView.addSubview(contentClipView)

        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.alignment = .fill
        contentClipView.addSubview(contentStack)

        // --- titleRow ---
        locationTitleLabel.font = UIFont.getFont(.semibold, size: 22)
        locationTitleLabel.textColor = Colors.primaryText

        categoryIconCircle.backgroundColor = .clear
        categoryIconCircle.layer.cornerRadius = 15
        categoryIconCircle.layer.borderColor = Colors.dividerTextField.cgColor
        categoryIconCircle.layer.borderWidth = 1
        categoryIconCircle.setContentHuggingPriority(.required, for: .horizontal)

        categoryIconView.contentMode = .scaleAspectFit
        categoryIconView.setContentHuggingPriority(.required, for: .horizontal)
        categoryIconCircle.addSubview(categoryIconView)

        let starImage = UIImage(named: "hotspot-star")?.withRenderingMode(.alwaysOriginal)
        let starFillImage = UIImage(named: "hotspot-star-fill")?.withRenderingMode(.alwaysOriginal)
        starButton.setImage(starImage, for: .normal)
        starButton.setImage(starFillImage, for: .selected)
        starButton.setContentHuggingPriority(.required, for: .horizontal)
        starButton.addTarget(self, action: #selector(starTapped), for: .touchUpInside)

        [locationTitleLabel, categoryIconCircle, starButton].forEach { titleRow.addSubview($0) }

        // --- addressLabel ---
        addressLabel.font = UIFont.getFont(.regular, size: 16)
        addressLabel.textColor = Colors.metadataIcon

        // --- expandedStack ---
        expandedStack.axis = .vertical
        expandedStack.spacing = 8
        expandedStack.alignment = .fill

        separatorView.backgroundColor = Colors.dividerTextField

        aboutLabel.text = "About"
        aboutLabel.font = UIFont.getFont(.semibold, size: 16)
        aboutLabel.textColor = Colors.primaryText

        descriptionLabel.font = UIFont.getFont(.regular, size: 16)
        descriptionLabel.textColor = Colors.secondaryText
        descriptionLabel.numberOfLines = 0

        quoteLabel.numberOfLines = 0

        [separatorView, aboutLabel, descriptionLabel, quoteLabel]
            .forEach { expandedStack.addArrangedSubview($0) }
        expandedStack.setCustomSpacing(20, after: separatorView)
        expandedStack.setCustomSpacing(12, after: aboutLabel)
        expandedStack.setCustomSpacing(12, after: descriptionLabel)

        // --- buttonsRow ---
        shareButton.backgroundColor = Colors.white
        shareButton.layer.cornerRadius = 20
        shareButton.layer.borderColor = Colors.naviOrange.cgColor
        shareButton.layer.borderWidth = 1
        shareButton.layer.shadowColor = Colors.black.cgColor
        shareButton.layer.shadowOpacity = 0.15
        shareButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        shareButton.layer.shadowRadius = 4
        shareButton.setImage(UIImage(named: "hotspot-share")?.withRenderingMode(.alwaysOriginal), for: .normal)
        shareButton.setTitle("  Share", for: .normal)
        shareButton.tintColor = Colors.naviBrown
        shareButton.setTitleColor(Colors.naviBrown, for: .normal)
        shareButton.titleLabel?.font = UIFont.getFont(.semibold, size: 16)

        directionsButton.backgroundColor = Colors.naviOrange
        directionsButton.layer.cornerRadius = 20
        directionsButton.layer.shadowColor = Colors.black.cgColor
        directionsButton.layer.shadowOpacity = 0.15
        directionsButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        directionsButton.layer.shadowRadius = 4
        directionsButton.setImage(UIImage(named: "hotspot-directions"), for: .normal)
        directionsButton.setTitle("  Directions", for: .normal)
        directionsButton.tintColor = Colors.white
        directionsButton.setTitleColor(Colors.white, for: .normal)
        directionsButton.titleLabel?.font = UIFont.getFont(.semibold, size: 16)

        [shareButton, directionsButton].forEach { buttonsRow.addSubview($0) }
        cardView.addSubview(buttonsRow)

        [titleRow, addressLabel, expandedStack]
            .forEach { contentStack.addArrangedSubview($0) }
        contentStack.setCustomSpacing(4, after: titleRow)
        contentStack.setCustomSpacing(24, after: addressLabel)
    }

    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(imageHeight)
        }

        contentClipView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(buttonsRow.snp.top).offset(-20)
        }

        contentStack.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(horizontalPadding)
        }

        locationTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
            make.trailing.lessThanOrEqualTo(categoryIconCircle.snp.leading).offset(-8)
        }
        categoryIconCircle.snp.makeConstraints { make in
            make.trailing.equalTo(starButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 38, height: 30))
        }
        categoryIconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 17))
        }
        starButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 30))
        }

        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }

        buttonsRow.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(horizontalPadding)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(buttonHeight)
        }
        shareButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(buttonWidth)
        }
        directionsButton.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(buttonWidth)
        }
    }

    // MARK: - Configuration

    private func configure(with funSpot: FunSpot) {
        locationTitleLabel.text = funSpot.name
        addressLabel.text = "\(funSpot.address) | \(String(format: "%.1f", funSpot.distanceMiles)) miles away"
        descriptionLabel.text = funSpot.about
        starButton.isSelected = funSpot.isFavorite

        if let name = funSpot.imageURL {
            imageView.image = UIImage(named: name)
        }

        let iconName: String
        switch funSpot.category {
        case .hotel: iconName = "hotspot-bed"
        default: iconName = "hotspot-\(funSpot.category.rawValue)"
        }
        categoryIconView.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)

        if let quote = funSpot.quote {
            quoteLabel.attributedText = NSAttributedString(
                string: "\u{201C}\(quote)\u{201D}",
                attributes: [
                    .font: UIFont.getFont(.regular, size: 16).italic(),
                    .foregroundColor: Colors.secondaryText
                ]
            )
            quoteLabel.isHidden = false
        } else {
            quoteLabel.isHidden = true
        }
    }

    // MARK: - SnapCardViewController hook

    override func didSnap(to index: Int, animated: Bool) {
        let isExpanded = index == 1
        if animated {
            if isExpanded { expandedStack.isHidden = false }
            UIView.animate(
                withDuration: 0.45,
                delay: 0,
                usingSpringWithDamping: 0.82,
                initialSpringVelocity: 0.4,
                options: [.allowUserInteraction]
            ) {
                self.expandedStack.alpha = isExpanded ? 1 : 0
            } completion: { _ in
                if !isExpanded { self.expandedStack.isHidden = true }
            }
        } else {
            expandedStack.isHidden = !isExpanded
            expandedStack.alpha = isExpanded ? 1 : 0
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        shareButton.layer.shadowPath = UIBezierPath(
            roundedRect: shareButton.bounds, cornerRadius: 20
        ).cgPath
    }

    // MARK: - Actions

    @objc private func starTapped() {
        funSpot.isFavorite.toggle()
        starButton.isSelected = funSpot.isFavorite
        // TODO: persist favorite state
    }

}
