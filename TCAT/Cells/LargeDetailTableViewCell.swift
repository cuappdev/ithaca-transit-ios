//
//  LargeDetailTableViewCell.swift
//  TCAT
//
//  Created by Matthew Barker on 2/13/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

protocol LargeDetailTableViewDelegate: class {
    func toggleCellExpansion(on cell: LargeDetailTableViewCell)
}

class LargeDetailTableViewCell: UITableViewCell {

    private weak var delegate: LargeDetailTableViewDelegate?

    private let chevron = LargeTapTargetButton(extendBy: 15)
    private let detailLabel = UILabel()
    private var iconView: DetailIconView!
    private let titleLabel = UILabel()
    private let hairline = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupChevron()
        setupTitleLabel()
        setupDetailLabel()

        setupConstraints()
    }

    private func setupChevron() {
        chevron.setImage(UIImage(named: "arrow"), for: .normal)
        chevron.tintColor = Colors.metadataIcon
        chevron.addTarget(self, action: #selector(chevronButtonPressed), for: .touchUpInside)
        contentView.addSubview(chevron)
    }

    private func setupTitleLabel() {
        titleLabel.font = .getFont(.regular, size: 14)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textColor = Colors.primaryText
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
    }

    private func setupDetailLabel() {
        detailLabel.font = .getFont(.regular, size: 14)
        detailLabel.lineBreakMode = .byWordWrapping
        detailLabel.textColor = Colors.metadataIcon
        contentView.addSubview(detailLabel)
    }

    private func setupHairline() {
        hairline.backgroundColor = Colors.tableViewSeparator
        contentView.addSubview(hairline)
    }

    private func setupConstraints() {
        let chevronSize = CGSize(width: 13.5, height: 8)
        let chevronTrailingInset = 20
        let labelSpacing: CGFloat = 4
        let labelInset: CGFloat = 12
        let titleLabelTrailingInset = 12

        chevron.snp.makeConstraints { make in
            make.size.equalTo(chevronSize)
            make.trailing.equalToSuperview().inset(chevronTrailingInset)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(labelInset)
            make.trailing.equalTo(chevron.snp.leading).offset(-titleLabelTrailingInset)
            make.bottom.equalTo(detailLabel.snp.top).offset(-labelSpacing)
        }

        detailLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(labelSpacing)
            make.bottom.equalToSuperview().inset(labelInset)
        }
    }

    private func setupConfigDependentConstraints() {
        let detailIconViewWidth = 114
        let titleLabelLeadingOffset = 6

        iconView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(detailIconViewWidth)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(titleLabelLeadingOffset)
        }

        hairline.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.bottom.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    /** Precondition: Direction is BoardDirection */
    func configure(for direction: Direction, isFirstStep: Bool, isExpanded: Bool, delegate: LargeDetailTableViewDelegate? = nil) {
        self.delegate = delegate
        setupHairline()

        if isExpanded == chevron.transform.isIdentity {
            flipChevron()
        }

        formatTitleLabel(for: direction)
        formatDetailLabel(for: direction)
        iconView = DetailIconView(for: direction, isFirstStep: isFirstStep, isLastStep: false)
        if direction.stops.isEmpty {
            chevron.alpha = 0 // .hidden attribute used for animation
        }
        contentView.addSubview(iconView)

        setupConfigDependentConstraints()
    }

    private func getBusIconImageAsTextAttachment(for direction: Direction) -> NSTextAttachment {
        let busIconSpacingBetweenText: CGFloat = 5

        // Instantiate busIconView offScreen to later turn into UIImage
        let busIconView = BusIcon(type: .directionSmall, number: direction.routeNumber)
        let busIconFrame = CGRect(x: -busIconView.intrinsicContentSize.width, y: 0, width: busIconView.intrinsicContentSize.width + busIconSpacingBetweenText * 2, height: busIconView.intrinsicContentSize.height)

        // Create container to add padding on sides
        let containerView = UIView(frame: busIconFrame)
        containerView.isOpaque = false
        containerView.addSubview(busIconView)
        busIconView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(5)
            make.top.bottom.equalToSuperview()
        }
        contentView.addSubview(containerView)

        // Create NSTextAttachment with the busIcon as a UIImage
        let iconAttachment = NSTextAttachment()
        iconAttachment.image = containerView.getImage()

        // Lower the textAttachment to be centered within the text
        var frame = containerView.frame
        frame.origin.y -= 7
        iconAttachment.bounds = frame

        // Remove the container as it is no longer needed
        containerView.removeFromSuperview()

        return iconAttachment
    }

    private func formatTitleLabel(for direction: Direction) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4

        // Beginning of string
        let titleLabelText = NSMutableAttributedString(string: direction.type == .transfer ? "Bus becomes" : "Board")

        titleLabelText.append(NSAttributedString(attachment: getBusIconImageAsTextAttachment(for: direction)))

        // Append rest of string
        let content = direction.locationNameDescription
        let labelBoldFont: UIFont = .getFont(.semibold, size: 14)
        let attributedString = direction.name.bold(in: content, from: titleLabel.font, to: labelBoldFont)
        titleLabelText.append(attributedString)
        titleLabelText.addAttribute(.paragraphStyle,
                                    value: paragraphStyle,
                                    range: NSRange(location: 0, length: titleLabelText.length))
        titleLabel.attributedText = titleLabelText
    }

    private func formatDetailLabel(for direction: Direction) {
        let totalStopCount = direction.stops.count + 1

        let detailLabelText = "\(totalStopCount) stop\(totalStopCount == 1 ? "" : "s")"

        // Number of minutes for the bus direction
        var timeString = Time.timeString(from: direction.startTime, to: direction.endTime)
        if timeString == "0 min" {  timeString = "1 min" }
        detailLabel.text = "\(detailLabelText) • \(timeString)"
    }

    private func flipChevron() {
        let chevronFlipDurationTime = 0.25

        // Flip arrow
        chevron.layer.removeAllAnimations()

        let transitionOptionsOne: UIView.AnimationOptions = [.transitionFlipFromTop, .showHideTransitionViews]
        UIView.transition(with: chevron, duration: chevronFlipDurationTime, options: transitionOptionsOne, animations: {
            self.chevron.isHidden = true
        })

        let rotationAngle = chevron.transform == CGAffineTransform(rotationAngle: CGFloat.pi)
            ? -CGFloat.pi
            : CGFloat.pi
        chevron.transform = chevron.transform.rotated(by: rotationAngle)
        let transitionOptionsTwo: UIView.AnimationOptions = [.transitionFlipFromBottom, .showHideTransitionViews]
        UIView.transition(with: chevron, duration: chevronFlipDurationTime, options: transitionOptionsTwo, animations: {
            self.chevron.isHidden = false
        })
    }

     @objc private func chevronButtonPressed() {
        flipChevron()
        delegate?.toggleCellExpansion(on: self)
    }

    override func prepareForReuse() {
        iconView.removeFromSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
