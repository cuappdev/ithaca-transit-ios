//
//  FunSpotCardViewController.swift
//  TCAT
//
//  Created by Gabriel Castillo on 4/8/26.
//  Copyright © 2026 cuappdev. All rights reserved.
//

import SnapKit
import UIKit

// MARK: - PassthroughView
/// Passes touches through to the map for any region not occupied by a subview.
private class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        return hit == self ? nil : hit
    }
}

class FunSpotCardViewController: UIViewController {

    // MARK: - Snap heights (collapsed, expanded)
    private let snapHeights: [CGFloat] = [300, 500]
    private var cardHeightConstraint: Constraint?
    private var currentSnapIndex = 0

    // MARK: - Constants
    private let imageHeight: CGFloat = 150          // snapHeights[0] / 2
    private let buttonHeight: CGFloat = 44
    private let cardCornerRadius: CGFloat = 16
    private let horizontalPadding: CGFloat = 16
    private let dragIndicatorSize = CGSize(width: 36, height: 3)

    // MARK: - Subviews
    private let cardView = UIView()
    private let imageView = UIImageView()
    private let dragIndicator = UIView()
    private let backButton = UIButton(type: .system)
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

    // MARK: - Callback
    var onDismiss: (() -> Void)?

    // MARK: - Lifecycle
    override func loadView() {
        view = PassthroughView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupSubviews()
        setupConstraints()
        expandedStack.isHidden = true
        expandedStack.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance()
    }

    // MARK: - Setup
    private func setupSubviews() {
        // cardView
        cardView.backgroundColor = Colors.white
        cardView.layer.cornerRadius = cardCornerRadius
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.15
        cardView.layer.shadowOffset = .zero
        cardView.layer.shadowRadius = 8
        cardView.clipsToBounds = false
        cardView.alpha = 0
        view.addSubview(cardView)
        cardView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))

        // imageView — top corners masked to match card rounding
        imageView.backgroundColor = .systemBlue
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = cardCornerRadius
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cardView.addSubview(imageView)

        // dragIndicator — added after imageView so it renders on top
        dragIndicator.backgroundColor = Colors.naviOrange
        dragIndicator.layer.cornerRadius = 1.5
        cardView.addSubview(dragIndicator)

        // backButton
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: chevronConfig), for: .normal)
        backButton.backgroundColor = Colors.white
        backButton.layer.cornerRadius = 20
        backButton.clipsToBounds = false
        backButton.tintColor = Colors.primaryText
        backButton.alpha = 0
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOpacity = 0.15
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        backButton.layer.shadowRadius = 4
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backButton)

        // contentClipView
        contentClipView.clipsToBounds = true
        cardView.addSubview(contentClipView)

        // contentStack
        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.alignment = .fill
        contentClipView.addSubview(contentStack)

        // --- titleRow ---
        locationTitleLabel.text = "Statler Hotel"
        locationTitleLabel.font = UIFont.getFont(.semibold, size: 22)
        locationTitleLabel.textColor = Colors.primaryText

        // TODO: Replace with real category icon based on fun spot type
        categoryIconCircle.backgroundColor = UIColor(white: 0.93, alpha: 1)
        categoryIconCircle.layer.cornerRadius = 20
        categoryIconCircle.clipsToBounds = true
        categoryIconCircle.setContentHuggingPriority(.required, for: .horizontal)

        categoryIconView.image = UIImage(named: "hotspot-bed")?.withRenderingMode(.alwaysOriginal)
        categoryIconView.contentMode = .scaleAspectFit
        categoryIconView.setContentHuggingPriority(.required, for: .horizontal)
        categoryIconCircle.addSubview(categoryIconView)

        let starImage = UIImage(named: "hotspot-star")?.withRenderingMode(.alwaysOriginal)
        starButton.setImage(starImage, for: .normal)
        starButton.setImage(starImage, for: .selected)
        starButton.setContentHuggingPriority(.required, for: .horizontal)
        starButton.addTarget(self, action: #selector(starTapped), for: .touchUpInside)

        [locationTitleLabel, categoryIconCircle, starButton].forEach { titleRow.addSubview($0) }

        // --- addressLabel ---
        addressLabel.text = "103 State Dr | 0.3 miles away"
        addressLabel.font = UIFont.getFont(.regular, size: 16)
        addressLabel.textColor = Colors.metadataIcon

        // --- expandedStack ---
        expandedStack.axis = .vertical
        expandedStack.spacing = 8
        expandedStack.alignment = .fill

        separatorView.backgroundColor = Colors.metadataIcon.withAlphaComponent(0.4)

        aboutLabel.text = "About"
        aboutLabel.font = UIFont.getFont(.bold, size: 16)
        aboutLabel.textColor = Colors.secondaryText

        descriptionLabel.text = "The Statler Hotel at Cornell University is a AAA Four Diamond award-winning hotel that serves as both a luxury hotel and a working laboratory for Cornell's hospitality students."
        descriptionLabel.font = UIFont.getFont(.regular, size: 16)
        descriptionLabel.textColor = Colors.secondaryText
        descriptionLabel.numberOfLines = 0

        let italicDescriptor = UIFont.getFont(.regular, size: 16)
            .fontDescriptor
            .withSymbolicTraits(.traitItalic)
        let italicFont = italicDescriptor.map { UIFont(descriptor: $0, size: 16) }
            ?? UIFont.italicSystemFont(ofSize: 16)
        quoteLabel.attributedText = NSAttributedString(
            string: "\u{201C}Where hospitality meets education.\u{201D}",
            attributes: [
                .font: italicFont,
                .foregroundColor: Colors.secondaryText
            ]
        )
        quoteLabel.numberOfLines = 0

        [separatorView, aboutLabel, descriptionLabel, quoteLabel]
            .forEach { expandedStack.addArrangedSubview($0) }

        // --- buttonsRow ---
        shareButton.backgroundColor = Colors.backgroundWash
        shareButton.layer.cornerRadius = buttonHeight / 2
        shareButton.clipsToBounds = true
        let shareConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: shareConfig), for: .normal)
        shareButton.setTitle("  Share", for: .normal)
        shareButton.tintColor = Colors.primaryText
        shareButton.setTitleColor(Colors.primaryText, for: .normal)
        shareButton.titleLabel?.font = UIFont.getFont(.semibold, size: 16)

        directionsButton.backgroundColor = Colors.naviOrange
        directionsButton.layer.cornerRadius = buttonHeight / 2
        directionsButton.clipsToBounds = true
        directionsButton.setImage(UIImage(named: "hotspot-directions"), for: .normal)
        directionsButton.setTitle("  Directions", for: .normal)
        directionsButton.tintColor = .white
        directionsButton.setTitleColor(.white, for: .normal)
        directionsButton.titleLabel?.font = UIFont.getFont(.semibold, size: 16)

        [shareButton, directionsButton].forEach { buttonsRow.addSubview($0) }
        cardView.addSubview(buttonsRow)

        // Assemble contentStack
        [titleRow, addressLabel, expandedStack]
            .forEach { contentStack.addArrangedSubview($0) }
        contentStack.setCustomSpacing(4, after: titleRow)
        contentStack.setCustomSpacing(12, after: addressLabel)
    }

    private func setupConstraints() {
        cardView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            cardHeightConstraint = make.height.equalTo(snapHeights[0]).constraint
        }

        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(imageHeight)
        }

        dragIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(10)
            make.size.equalTo(dragIndicatorSize)
        }

        contentClipView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(buttonsRow.snp.top).offset(-12)
        }

        contentStack.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(horizontalPadding)
        }

        // titleRow internals
        locationTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
            make.trailing.lessThanOrEqualTo(categoryIconCircle.snp.leading).offset(-8)
        }
        categoryIconCircle.snp.makeConstraints { make in
            make.trailing.equalTo(starButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 40))
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

        // separatorView height
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }

        // buttonsRow pinned to card bottom
        buttonsRow.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(horizontalPadding)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(buttonHeight)
        }
        shareButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.45)
        }
        directionsButton.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.45)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(8)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
    }

    // MARK: - Entrance animation
    private func animateEntrance() {
        cardView.transform = CGAffineTransform(translationX: 0, y: 60)
        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.4,
            options: [.allowUserInteraction]
        ) {
            self.cardView.alpha = 1
            self.cardView.transform = .identity
            self.backButton.alpha = 1
        }
    }

    // MARK: - Pan gesture
    private var panStartHeight: CGFloat = 0

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .began:
            panStartHeight = snapHeights[currentSnapIndex]

        case .changed:
            let newHeight = (panStartHeight - translation.y)
                .clamped(to: snapHeights.first!...snapHeights.last!)
            cardHeightConstraint?.update(offset: newHeight)
            view.layoutIfNeeded()

        case .ended, .cancelled:
            let velocity = gesture.velocity(in: view).y
            let currentHeight = panStartHeight - translation.y
            snap(to: bestSnapIndex(for: currentHeight, velocity: velocity), animated: true)

        default:
            break
        }
    }

    private func bestSnapIndex(for height: CGFloat, velocity: CGFloat) -> Int {
        if velocity < -300 { return 1 }   // fast upward flick → expanded
        if velocity > 300  { return 0 }   // fast downward flick → collapsed
        return snapHeights.indices.min(by: {
            abs(snapHeights[$0] - height) < abs(snapHeights[$1] - height)
        }) ?? 0
    }

    private func snap(to index: Int, animated: Bool) {
        currentSnapIndex = index
        cardHeightConstraint?.update(offset: snapHeights[index])
        let isExpanded = index == 1

        if animated {
            if isExpanded { expandedStack.isHidden = false }
            UIView.animate(
                withDuration: 0.42,
                delay: 0,
                usingSpringWithDamping: 0.78,
                initialSpringVelocity: 0.3,
                options: [.allowUserInteraction]
            ) {
                self.view.layoutIfNeeded()
                self.expandedStack.alpha = isExpanded ? 1 : 0
            } completion: { _ in
                if !isExpanded { self.expandedStack.isHidden = true }
            }
        } else {
            expandedStack.isHidden = !isExpanded
            expandedStack.alpha = isExpanded ? 1 : 0
            view.layoutIfNeeded()
        }
    }

    // MARK: - Actions
    @objc private func backTapped() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: []
        ) {
            self.cardView.alpha = 0
            self.cardView.transform = CGAffineTransform(translationX: 0, y: 60)
            self.backButton.alpha = 0
        } completion: { _ in
            self.onDismiss?()
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }

    @objc private func starTapped() {
        starButton.isSelected.toggle()
        // TODO: persist favorite state
    }

}

// MARK: - Comparable clamp helper
private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
