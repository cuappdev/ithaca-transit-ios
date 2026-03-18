//
//  HotspotDetailViewController.swift
//  TCAT
//
//  Created by Gabriel Castillo on 3/11/26.
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

class HotspotDetailViewController: UIViewController {

    // MARK: - Snap heights (collapsed, partial, open)
    private let snapHeights: [CGFloat] = [140, 280, 310]
    private var cardHeightConstraint: Constraint?
    private var currentSnapIndex = 0

    // MARK: - Constants
    private let directionsButtonHeight: CGFloat = 44
    private let directionsButtonOverlap: CGFloat = 22
    private let dragIndicatorSize = CGSize(width: 36, height: 3)

    // MARK: - Subviews
    private let cardView = UIView()
    private let dragIndicator = UIView()
    private let backButton = UIButton(type: .system)
    private let contentStack = UIStackView()
    private let contentClipView = UIView()  // clips overflowing rows during drag

    // Content rows
    private let headerRow = UIView()       // calendar icon + title
    private let calendarImageView = UIImageView()
    private let eventTitleLabel = UILabel()
    private let locationLabel = UILabel()
    private let tagsLabel = UILabel()
    private let timeLabel = UILabel()
    private let separatorView = UIView()
    private let organizerHeaderLabel = UILabel()
    private let organizerMessageLabel = UILabel()
    private let moreInfoLabel = UILabel()

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
        updateVisibility(for: 0, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance()
    }

    // MARK: - Setup
    private func setupSubviews() {
        // cardView
        cardView.backgroundColor = Colors.white
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.15
        cardView.layer.shadowOffset = .zero
        cardView.layer.shadowRadius = 8
        cardView.clipsToBounds = false
        cardView.alpha = 0
        view.addSubview(cardView)

        // pan gesture
        cardView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))

        // dragIndicator
        dragIndicator.backgroundColor = Colors.naviOrange
        dragIndicator.layer.cornerRadius = 1.5
        cardView.addSubview(dragIndicator)

        // backButton — white circle with dark chevron, no text
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: chevronConfig), for: .normal)
        backButton.backgroundColor = Colors.white
        backButton.layer.cornerRadius = 20
        backButton.clipsToBounds = false
        backButton.tintColor = Colors.primaryText
        backButton.alpha = 0
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOpacity = 0.15
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        backButton.layer.shadowRadius = 4
        view.addSubview(backButton)

        // calendarImageView
        calendarImageView.image = UIImage(named: "hotspot-event")
        calendarImageView.tintColor = Colors.naviOrange
        calendarImageView.contentMode = .scaleAspectFit
        calendarImageView.setContentHuggingPriority(.required, for: .horizontal)

        // eventTitleLabel
        eventTitleLabel.text = "AppDev: Navi Tabling"
        eventTitleLabel.font = UIFont.getFont(.semibold, size: 22)
        eventTitleLabel.textColor = Colors.primaryText

        // headerRow = icon + title side by side
        headerRow.addSubview(calendarImageView)
        headerRow.addSubview(eventTitleLabel)
        calendarImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 23, height: 24))
        }
        eventTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(calendarImageView.snp.trailing).offset(8)
            make.trailing.top.bottom.equalToSuperview()
        }

        // locationLabel
        locationLabel.text = "Duffield Atrium | 15 minute walk"
        locationLabel.font = UIFont.getFont(.regular, size: 16)
        locationLabel.textColor = Colors.metadataIcon

        // tagsLabel
        tagsLabel.text = "Stickers, charms, and bracelets"
        tagsLabel.font = UIFont.getFont(.regular, size: 16)
        tagsLabel.textColor = Colors.secondaryText

        // timeLabel
        let timeLabelText = NSMutableAttributedString()
        let nowAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: Colors.liveGreen,
            .font: UIFont.getFont(.regular, size: 16)
        ]
        let restAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: Colors.secondaryText,
            .font: UIFont.getFont(.regular, size: 16)
        ]
        timeLabelText.append(NSAttributedString(string: "NOW", attributes: nowAttrs))
        timeLabelText.append(NSAttributedString(string: " - until 5:00 PM", attributes: restAttrs))
        timeLabel.attributedText = timeLabelText

        // separatorView
        separatorView.backgroundColor = Colors.metadataIcon.withAlphaComponent(0.4)
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }

        // organizerHeaderLabel
        organizerHeaderLabel.text = "Organizer Message"
        organizerHeaderLabel.font = UIFont.getFont(.bold, size: 16)
        organizerHeaderLabel.textColor = Colors.secondaryText

        // organizerMessageLabel
        organizerMessageLabel.text = "Come check out our stall — we'll be here until 5 PM!"
        organizerMessageLabel.font = UIFont.getFont(.regular, size: 16)
        organizerMessageLabel.textColor = Colors.secondaryText
        organizerMessageLabel.numberOfLines = 0

        // moreInfoLabel
        moreInfoLabel.text = "More information on our instagram @navicornell"
        moreInfoLabel.font = UIFont.getFont(.regular, size: 16)
        moreInfoLabel.textColor = Colors.secondaryText
        moreInfoLabel.numberOfLines = 0

        // contentStack — vertical, auto-collapses hidden rows
        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.alignment = .fill
        contentStack.setCustomSpacing(12, after: tagsLabel)
        contentStack.setCustomSpacing(12, after: separatorView)
        [headerRow, locationLabel, timeLabel, tagsLabel,
         separatorView, organizerHeaderLabel, organizerMessageLabel,
         moreInfoLabel].forEach { contentStack.addArrangedSubview($0) }

        // Set initial alpha=0 for views that start hidden so fade-in works correctly
        [timeLabel, separatorView, organizerHeaderLabel, organizerMessageLabel, moreInfoLabel].forEach {
            $0.alpha = 0
        }

        // contentClipView prevents rows overflowing card bottom during drag
        contentClipView.clipsToBounds = true
        cardView.addSubview(contentClipView)
        contentClipView.addSubview(contentStack)

        // directionsButton — lives in view so it can overlap the card bottom edge
        directionsButton.backgroundColor = Colors.naviOrange
        directionsButton.layer.cornerRadius = 22
        directionsButton.clipsToBounds = true
        directionsButton.setImage(UIImage(named: "hotspot-directions"), for: .normal)
        directionsButton.setTitle("  Directions", for: .normal)
        directionsButton.setTitleColor(.white, for: .normal)
        directionsButton.tintColor = .white
        directionsButton.titleLabel?.font = UIFont.getFont(.semibold, size: 16)
        directionsButton.alpha = 0
        view.addSubview(directionsButton)
    }

    private func setupConstraints() {
        cardView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(directionsButtonOverlap)
            cardHeightConstraint = make.height.equalTo(snapHeights[0]).constraint
        }

        dragIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(10)
            make.size.equalTo(dragIndicatorSize)
        }

        contentClipView.snp.makeConstraints { make in
            make.top.equalTo(dragIndicator.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentStack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(8)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }

        directionsButton.snp.makeConstraints { make in
            make.trailing.equalTo(cardView).inset(16)
            make.bottom.equalTo(cardView.snp.bottom).offset(directionsButtonOverlap)
            make.width.equalTo(cardView.snp.width).multipliedBy(0.45)
            make.height.equalTo(directionsButtonHeight)
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
            self.directionsButton.alpha = 1
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
            updateAlphasDuringDrag(height: newHeight)

        case .ended, .cancelled:
            let velocity = gesture.velocity(in: view).y
            let currentHeight = panStartHeight - translation.y
            snap(to: bestSnapIndex(for: currentHeight, velocity: velocity), animated: true)

        default:
            break
        }
    }

    private func bestSnapIndex(for height: CGFloat, velocity: CGFloat) -> Int {
        if velocity < -400, currentSnapIndex < snapHeights.count - 1 { return currentSnapIndex + 1 }
        if velocity > 400, currentSnapIndex > 0 { return currentSnapIndex - 1 }
        return snapHeights.indices.min(by: {
            abs(snapHeights[$0] - height) < abs(snapHeights[$1] - height)
        }) ?? 0
    }

    private func snap(to index: Int, animated: Bool) {
        currentSnapIndex = index
        cardHeightConstraint?.update(offset: snapHeights[index])
        updateVisibility(for: index, animated: animated)
        if animated {
            UIView.animate(
                withDuration: 0.42,
                delay: 0,
                usingSpringWithDamping: 0.78,
                initialSpringVelocity: 0.3,
                options: [.allowUserInteraction]
            ) {
                self.view.layoutIfNeeded()
            }
        }
    }

    // Drives row alphas AND layout continuously while the user is dragging.
    // isHidden is tied to a 5% threshold so tagsLabel shifts up while timeLabel
    // is still essentially invisible, rather than jumping suddenly on release.
    private func updateAlphasDuringDrag(height: CGFloat) {
        let prog01 = ((height - snapHeights[0]) / (snapHeights[1] - snapHeights[0])).clamped(to: 0...1)
        let prog12 = ((height - snapHeights[1]) / (snapHeights[2] - snapHeights[1])).clamped(to: 0...1)

        [timeLabel, separatorView, organizerHeaderLabel, organizerMessageLabel].forEach {
            $0.isHidden = prog01 < 0.05
            $0.alpha = prog01
        }
        moreInfoLabel.isHidden = prog12 < 0.05
        moreInfoLabel.alpha = prog12
        backButton.alpha = 1

        // Commit constraint + isHidden changes immediately so layout tracks the finger
        view.layoutIfNeeded()
    }

    // MARK: - Visibility
    private func updateVisibility(for snapIndex: Int, animated: Bool) {
        let isPartialOrOpen = snapIndex >= 1
        let isOpen = snapIndex >= 2

        let toggle: (UIView, Bool) -> Void = { v, visible in
            if animated {
                if visible { v.isHidden = false }
                UIView.animate(withDuration: 0.25, animations: {
                    v.alpha = visible ? 1 : 0
                }, completion: { _ in
                    if !visible { v.isHidden = true }
                })
            } else {
                v.isHidden = !visible
                v.alpha = visible ? 1 : 0
            }
        }

        toggle(timeLabel, isPartialOrOpen)
        toggle(separatorView, isPartialOrOpen)
        toggle(organizerHeaderLabel, isPartialOrOpen)
        toggle(organizerMessageLabel, isPartialOrOpen)
        toggle(moreInfoLabel, isOpen)

        // Back button is always visible
        backButton.alpha = 1
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
            self.directionsButton.alpha = 0
        } completion: { _ in
            self.onDismiss?()
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }

}

// MARK: - Comparable clamp helper
private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
