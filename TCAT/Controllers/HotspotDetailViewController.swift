//
//  HotspotDetailViewController.swift
//  TCAT
//
//  Created by Gabriel Castillo on 3/11/26.
//  Copyright © 2026 cuappdev. All rights reserved.
//

import SnapKit
import UIKit

class HotspotDetailViewController: SnapCardViewController {

    // MARK: - SnapCardViewController overrides

    override var snapHeights: [CGFloat] { [140, 240, 310] }
    override var cardBottomInset: CGFloat { directionsButtonOverlap }
    override func extraEntranceViews() -> [UIView] { [directionsButton] }

    // MARK: - Constants

    private let directionsButtonHeight: CGFloat = 40
    private let directionsButtonOverlap: CGFloat = 26
    private let directionsButtonWidth: CGFloat = 159

    // MARK: - Subviews

    private let contentStack = UIStackView()
    private let contentClipView = UIView()

    // Content rows
    private let headerRow = UIView()
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

    // MARK: - Data

    private let hotspot: Hotspot

    // MARK: - Init

    init(hotspot: Hotspot) {
        self.hotspot = hotspot
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
        configure(with: hotspot)
        updateVisibility(for: 0, animated: false)
    }

    // MARK: - Setup

    private func setupSubviews() {
        calendarImageView.image = UIImage(named: "hotspot-event")
        calendarImageView.tintColor = Colors.naviOrange
        calendarImageView.contentMode = .scaleAspectFit
        calendarImageView.setContentHuggingPriority(.required, for: .horizontal)

        eventTitleLabel.font = UIFont.getFont(.semibold, size: 22)
        eventTitleLabel.textColor = Colors.primaryText

        headerRow.addSubview(calendarImageView)
        headerRow.addSubview(eventTitleLabel)

        locationLabel.font = UIFont.getFont(.regular, size: 16)
        locationLabel.textColor = Colors.metadataIcon

        tagsLabel.font = UIFont.getFont(.regular, size: 16)
        tagsLabel.textColor = Colors.secondaryText

        timeLabel.font = UIFont.getFont(.regular, size: 16)

        separatorView.backgroundColor = Colors.dividerTextField

        organizerHeaderLabel.text = "Organizer Message"
        organizerHeaderLabel.font = UIFont.getFont(.bold, size: 16)
        organizerHeaderLabel.textColor = Colors.secondaryText

        let italicFont = UIFont.getFont(.regular, size: 16).italic()
        organizerMessageLabel.font = italicFont
        organizerMessageLabel.textColor = Colors.secondaryText
        organizerMessageLabel.numberOfLines = 0

        moreInfoLabel.font = italicFont
        moreInfoLabel.textColor = Colors.secondaryText
        moreInfoLabel.numberOfLines = 0

        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.alignment = .fill
        contentStack.setCustomSpacing(12, after: timeLabel)
        contentStack.setCustomSpacing(15, after: tagsLabel)
        contentStack.setCustomSpacing(15, after: separatorView)
        [headerRow, locationLabel, timeLabel, tagsLabel,
         separatorView, organizerHeaderLabel, organizerMessageLabel,
         moreInfoLabel].forEach { contentStack.addArrangedSubview($0) }

        [timeLabel, separatorView, organizerHeaderLabel, organizerMessageLabel, moreInfoLabel].forEach {
            $0.alpha = 0
        }

        contentClipView.clipsToBounds = true
        cardView.addSubview(contentClipView)
        contentClipView.addSubview(contentStack)

        directionsButton.backgroundColor = Colors.naviOrange
        directionsButton.layer.cornerRadius = 20
        directionsButton.layer.shadowColor = Colors.black.cgColor
        directionsButton.layer.shadowOpacity = 0.15
        directionsButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        directionsButton.layer.shadowRadius = 4
        directionsButton.setImage(UIImage(named: "hotspot-directions"), for: .normal)
        directionsButton.setTitle("  Directions", for: .normal)
        directionsButton.setTitleColor(Colors.white, for: .normal)
        directionsButton.tintColor = Colors.white
        directionsButton.titleLabel?.font = UIFont.getFont(.semibold, size: 16)
        directionsButton.alpha = 0
        view.addSubview(directionsButton)
    }

    private func setupConstraints() {
        calendarImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 23, height: 24))
        }
        eventTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(calendarImageView.snp.trailing).offset(8)
            make.trailing.top.bottom.equalToSuperview()
        }

        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }

        contentClipView.snp.makeConstraints { make in
            make.top.equalTo(dragIndicator.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentStack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }

        directionsButton.snp.makeConstraints { make in
            make.trailing.equalTo(cardView).inset(16)
            make.bottom.equalTo(cardView.snp.bottom).offset(directionsButtonOverlap)
            make.width.equalTo(directionsButtonWidth)
            make.height.equalTo(directionsButtonHeight)
        }
    }

    // MARK: - Configuration

    private func configure(with hotspot: Hotspot) {
        eventTitleLabel.text = hotspot.title
        locationLabel.text = hotspot.location
        tagsLabel.text = hotspot.tags
        organizerMessageLabel.text = hotspot.organizerMessage
        moreInfoLabel.text = hotspot.moreInfo

        let timeLabelText = NSMutableAttributedString()
        let nowAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: Colors.liveGreen,
            .font: UIFont.getFont(.regular, size: 16)
        ]
        let restAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: Colors.secondaryText,
            .font: UIFont.getFont(.regular, size: 16)
        ]
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let endTimeString = timeFormatter.string(from: hotspot.endTime)
        if hotspot.isActive {
            timeLabelText.append(NSAttributedString(string: "NOW", attributes: nowAttrs))
            timeLabelText.append(NSAttributedString(string: " - until \(endTimeString)", attributes: restAttrs))
        } else {
            timeLabelText.append(NSAttributedString(string: endTimeString, attributes: restAttrs))
        }
        timeLabel.attributedText = timeLabelText
    }

    // MARK: - SnapCardViewController hooks

    override func dragDidChange(height: CGFloat) {
        updateAlphasDuringDrag(height: height)
    }

    override func didSnap(to index: Int, animated: Bool) {
        updateVisibility(for: index, animated: animated)
    }

    // MARK: - Drag alphas

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
    }

    // MARK: - Visibility

    private func updateVisibility(for snapIndex: Int, animated: Bool) {
        let isPartialOrOpen = snapIndex >= 1
        let isOpen = snapIndex >= 2

        let toggle: (UIView, Bool) -> Void = { v, visible in
            if animated {
                if visible { v.isHidden = false }
                UIView.animate(
                    withDuration: 0.35,
                    delay: 0,
                    usingSpringWithDamping: 0.9,
                    initialSpringVelocity: 0.1,
                    options: [.allowUserInteraction]
                ) {
                    v.alpha = visible ? 1 : 0
                } completion: { _ in
                    if !visible { v.isHidden = true }
                }
            } else {
                v.isHidden = !visible
                v.alpha = visible ? 1 : 0
            }
        }

        if isPartialOrOpen {
            organizerMessageLabel.text = hotspot.shortOrganizerMessage ?? hotspot.organizerMessage
        }
        if isOpen {
            organizerMessageLabel.text = hotspot.organizerMessage
        }

        toggle(timeLabel, isPartialOrOpen)
        toggle(separatorView, isPartialOrOpen)
        toggle(organizerHeaderLabel, isPartialOrOpen)
        toggle(organizerMessageLabel, isPartialOrOpen)
        toggle(moreInfoLabel, isOpen)

        backButton.alpha = 1
    }

}
