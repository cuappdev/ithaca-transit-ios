//
//  SummaryView.swift
//  TCAT
//
//  Created by Matthew Barker on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class SummaryView: UIView {

    /// The puller tab used to indicate dragability
    private let tab = UIView()

    /// Three times the height of the tab view (spacing + tabHeight + spacing)
    private let tabInsetHeight: CGFloat = 12

    /// The usable height of the summaryView
    var safeAreaHeight: CGFloat {
        return frame.size.height - tabInsetHeight
    }

    /// The y-coordinate center of the safe area
    private var safeAreaCenterY: CGFloat {
        return tabInsetHeight + safeAreaHeight / 2
    }

    /// The primary summary label
    private let mainLabel = UILabel()

    private let labelsContainerView = UIView()

    private var iconView: UIView!

    /// The live indicator
    private let liveIndicator = LiveIndicator(size: .small, color: .clear)

    /// The secondary label (Trip Duration)
    private let secondaryLabel = UILabel()

    /// Whether route icons have been set or not
    private var didSetRoutes: Bool = false

    /// Constant for label padding
    private let textLabelPadding: CGFloat = 16
    /// Identifier for bus route icons
    private let iconTag: Int = 14850

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(route: Route) {
        // View Initialization
        let height: CGFloat = 80 + tabInsetHeight
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
        backgroundColor = Colors.backgroundWash
        roundCorners(corners: [.topLeft, .topRight], radius: 16)

        setupTab()
        setupLabelsContainerView(for: route)
        setIcon(for: route)
        addSubview(liveIndicator)
        setupConstraints()
    }

    func setupTab() {
        tab.backgroundColor = Colors.metadataIcon
        tab.layer.cornerRadius = tab.frame.height / 2
        tab.clipsToBounds = true
        addSubview(tab)
    }

    func setupLabelsContainerView(for route: Route) {
        setupMainLabel(for: route)
        setupSecondaryLabel(for: route)

        setupLabelConstraints()

        addSubview(labelsContainerView)
    }

    func setupMainLabel(for route: Route) {
        mainLabel.font = .getFont(.regular, size: 16)
        mainLabel.textColor = Colors.primaryText
        mainLabel.numberOfLines = 0
        mainLabel.allowsDefaultTighteningForTruncation = true
        mainLabel.lineBreakMode = .byTruncatingTail
        configureMainLabelText(for: route)

        labelsContainerView.addSubview(mainLabel)
    }

    func setupSecondaryLabel(for route: Route) {
        secondaryLabel.font = .getFont(.regular, size: 12)
        secondaryLabel.textColor = Colors.metadataIcon
        secondaryLabel.text = "Trip Duration: \(route.totalDuration) minute\(route.totalDuration == 1 ? "" : "s")"

        labelsContainerView.addSubview(secondaryLabel)
    }

    func setupLabelConstraints() {
        let labelSpacing: CGFloat = 4

        mainLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        secondaryLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(labelSpacing)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func setupConstraints() {
        let tabTopInset = 6
        let labelLeadingInset = 120
        let walkIconSize = CGSize(width: iconView.frame.size.width * 2, height: iconView.frame.size.height * 2)

        tab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(tabTopInset)
            make.size.equalTo(CGSize(width: 32, height: 4))
        }

        labelsContainerView.snp.makeConstraints { make in
            make.centerY.equalTo(iconView)
            make.leading.equalTo(labelLeadingInset)
            make.trailing.equalToSuperview().inset(textLabelPadding)
        }

        iconView.snp.makeConstraints { make in
            if iconView is UIImageView {
                make.size.equalTo(walkIconSize)
            } else if iconView is BusIcon {
                make.size.equalTo(iconView.intrinsicContentSize)
            }

            make.centerY.equalToSuperview()
            make.centerX.equalTo(snp.leading).inset(DetailIconView.width / 2)
        }
    }

    /// Update summary card data and position accordingly
    private func configureMainLabelText(for route: Route) {

        var color: UIColor = Colors.primaryText

        let mainLabelBoldFont: UIFont = .getFont(.semibold, size: 14)

        if let departDirection = (route.directions.filter { $0.type == .depart }).first {

            if let delay = departDirection.delay {
                if delay >= 60 {
                    color = Colors.lateRed
                } else {
                    color = Colors.liveGreen
                }
            } else {
                liveIndicator.setColor(to: .clear)
                color = Colors.primaryText
            }

            let content = "Depart at \(departDirection.startTimeWithDelayDescription) from \(departDirection.name)"
            // This changes font to standard size. Label's font is different.
            var attributedString = departDirection.startTimeWithDelayDescription.bold(
                                       in: content,
                                       from: mainLabel.font,
                                       to: mainLabelBoldFont)
            attributedString = departDirection.name.bold(in: attributedString, to: mainLabelBoldFont)

            let range = (attributedString.string as NSString).range(of: departDirection.startTimeWithDelayDescription)
            attributedString.addAttribute(.foregroundColor, value: color, range: range)

            mainLabel.attributedText = attributedString

            // Find time within label to place live indicator
            if let stringRect = mainLabel.boundingRect(of: departDirection.startTimeWithDelayDescription + " ") {
                liveIndicator.frame.origin.x = mainLabel.frame.minX + stringRect.maxX
                liveIndicator.center.y = mainLabel.frame.minY + stringRect.midY
                liveIndicator.setColor(to: departDirection.delay == nil ? .clear : color)
            } else {
                print("[SummaryView] Could not find phrase in label")
                liveIndicator.setColor(to: .clear)
            }

        } else {
            let content = route.directions.first?.locationNameDescription ?? "Route Directions"
            let pattern = route.directions.first?.name ?? ""
            mainLabel.attributedText = pattern.bold(in: content, from: mainLabel.font, to: mainLabelBoldFont)
        }
    }

    func updateTimes(for route: Route) {
        configureMainLabelText(for: route)
    }

    private func setIcon(for route: Route) {
        let firstBusRoute = route.directions.compactMap {
            return $0.type == .depart ? $0.routeNumber : nil
        }.first

        if let first = firstBusRoute {
            iconView = BusIcon(type: .directionLarge, number: first)
            iconView.tag = iconTag
            addSubview(iconView)
        } else {
            // Show walking glyph
            iconView = UIImageView(image: #imageLiteral(resourceName: "walk"))
            iconView.tag = iconTag
            iconView.contentMode = .scaleAspectFit
            iconView.tintColor = Colors.metadataIcon
            addSubview(iconView)
        }
    }
}
