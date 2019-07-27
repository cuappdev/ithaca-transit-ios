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
    private var tab = UIView()

    /// Three times the height of the tab view (spacing + tabHeight + spacing)
    private var tabInsetHeight: CGFloat = 12

    /// The usable height of the summaryView
    var safeAreaHeight: CGFloat {
        return frame.size.height - tabInsetHeight
    }

    /// The y-coordinate center of the safe area
    var safeAreaCenterY: CGFloat {
        return tabInsetHeight + safeAreaHeight / 2
    }

    /// The primary summary label
    private var mainLabel = UILabel()

    private let labelsContainerView = UIView()

    private var iconView: UIView!

    /// The live indicator
    private var liveIndicator = LiveIndicator(size: .small, color: .clear)

    /// The secondary label (Trip Duration)
    private var secondaryLabel = UILabel()

    /// Whether route icons have been set or not
    private var didSetRoutes: Bool = false

    /// The device's bounds
    private var main = UIScreen.main.bounds
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
        super.init(frame: CGRect(x: 0, y: 0, width: main.width, height: height))
        backgroundColor = Colors.backgroundWash
        roundCorners(corners: [.topLeft, .topRight], radius: 16)

        setupTab()
        setupLabelsContainerView()
        addSubview(liveIndicator)
        configure(for: route)
        setupConstraints()
    }

    func setupTab() {
        tab.backgroundColor = Colors.metadataIcon
        tab.layer.cornerRadius = tab.frame.height / 2
        addSubview(tab)
    }

    func setupLabelsContainerView() {
        setupMainLabel()
        setupSecondaryLabel()

        setupLabelConstraints()

        addSubview(labelsContainerView)
    }

    func setupMainLabel() {
        mainLabel.font = .getFont(.regular, size: 16)
        mainLabel.textColor = Colors.primaryText
        mainLabel.numberOfLines = 0
        mainLabel.allowsDefaultTighteningForTruncation = true
        mainLabel.lineBreakMode = .byTruncatingTail
        labelsContainerView.addSubview(mainLabel)
    }

    func setupSecondaryLabel() {
        secondaryLabel.font = .getFont(.regular, size: 12)
        secondaryLabel.textColor = Colors.metadataIcon
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
        /// The center to use for the next bus icon. Initalized for 0-1 bus(es).
        let iconCenter = CGPoint(x: DetailIconView.width / 2, y: safeAreaCenterY)

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
    func configure(for route: Route) {

        setBusIcons(for: route)

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

        secondaryLabel.text = "Trip Duration: \(route.totalDuration) minute\(route.totalDuration == 1 ? "" : "s")"

        mainLabel.snp.makeConstraints { make in
            make.height.equalTo(mainLabel.text?.heightWithConstrainedWidth(width: UIScreen.main.bounds.width - 136, font: mainLabel.font) ?? 0)
        }
    }

    func updateTimes(for route: Route) {

    }

    /// Add and place bus icons.
    private func setBusIcons(for route: Route) {

        let spacing: CGFloat = 12

        subviews.filter { $0.tag == iconTag }.removeViewsFromSuperview()

        // Create and place bus icons
        let busRoutes: [Int] = route.directions.compactMap {
            return $0.type == .depart ? $0.routeNumber : nil
        }

        // Show walking glyph
        if busRoutes.isEmpty {

            // Create and add bus icon
            iconView = UIImageView(image: #imageLiteral(resourceName: "walk"))
            iconView.tag = iconTag
            iconView.contentMode = .scaleAspectFit
            iconView.tintColor = Colors.metadataIcon
            addSubview(iconView)
        }

            // Place one sole bus icon
        else if busRoutes.count == 1 {

            // Create and add bus icon
            iconView = BusIcon(type: .directionLarge, number: busRoutes.first!)
            iconView.tag = iconTag
            addSubview(iconView)
        }

            // Place up to 2 bus icons. This will not support more buses without changes
        else {
//            // Adjust initial variables
            let exampleBusIcon = BusIcon(type: .directionSmall, number: 0)
//            iconCenter.y = tabInsetHeight + safeAreaCenterY - (spacing / 4) - exampleBusIcon.frame.height
//
//            for (index, route) in busRoutes.enumerated() {
//
//                // Create and add bus icon
//                let busIcon = BusIcon(type: .directionSmall, number: route)
//                busIcon.tag = iconTag
//                busIcon.center = iconCenter
//                addSubview(busIcon)
//
//                // Adjust center point
//                iconCenter.y += busIcon.frame.height + (spacing / 2)
//
//                // Stop once two buses have been placed
//                if index == 1 { break }
//
//            }
        }
    }
}
