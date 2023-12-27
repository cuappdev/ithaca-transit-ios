//
//  SummaryView.swift
//  TCAT
//
//  Created by Matthew Barker on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class SummaryView: UIView {

    private var iconView: UIView!
    private let labelsContainerView = UIView()
    private let liveIndicator = LiveIndicator(size: .small, color: .clear)
    private let mainLabel = UILabel()
    private let secondaryLabel = UILabel()
    private let tab = UIView()

    private let tabSize = CGSize(width: 32, height: 4)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(route: Route) {
        // View Initialization
        super.init(frame: .zero)

        // TODO:
        // This value ends up getting overwritten by constraints, which is what we want,
        // but for some reason if it is not set prior to writing the constraints, the
        // entire view comes out blank. I'm still investigating but it seems to be an,
        // issue with the Pulley Pod that we're using.
        frame.size = CGSize(width: UIScreen.main.bounds.width, height: 100)
        backgroundColor = Colors.backgroundWash
        roundCorners(corners: [.topLeft, .topRight], radius: 16)

        setupTab()
        setupLabelsContainerView(for: route)
        setIcon(for: route)
        setupConstraints()
    }

    func setupTab() {
        tab.backgroundColor = Colors.metadataIcon
        tab.layer.cornerRadius = tabSize.height / 2
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
            make.top.equalTo(mainLabel.snp.bottom).offset(labelSpacing).priority(.high)
            make.leading.trailing.equalTo(mainLabel)
            make.bottom.equalToSuperview()
        }
    }

    func setupConstraints() {
        let labelLeadingInset = 120
        let labelsContainerViewToTabSpacing: CGFloat = 10
        let labelsContainerViewToBottomSpacing: CGFloat = 16
        let tabTopInset: CGFloat = 6
        let textLabelPadding: CGFloat = 16
        let walkIconSize = CGSize(
            width: iconView.intrinsicContentSize.width * 2,
            height: iconView.intrinsicContentSize.height * 2
        )

        tab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(tabTopInset)
            make.size.equalTo(tabSize)
        }

        labelsContainerView.snp.makeConstraints { make in
            make.top.equalTo(tab.snp.bottom).offset(labelsContainerViewToTabSpacing).priority(.high)
            make.leading.equalToSuperview().inset(labelLeadingInset)
            make.trailing.equalToSuperview().inset(textLabelPadding).priority(.high)
            make.bottom.equalToSuperview().inset(labelsContainerViewToBottomSpacing)
        }

        iconView.snp.makeConstraints { make in
            if iconView is UIImageView {
                make.size.equalTo(walkIconSize)
            } else if iconView is BusIcon {
                make.size.equalTo(iconView.intrinsicContentSize)
            }
            make.centerY.equalToSuperview()
            make.centerX.equalTo(labelLeadingInset/2)
        }
    }

    /// Update summary card data and position accordingly
    private func configureMainLabelText(for route: Route) {

        let mainLabelBoldFont: UIFont = .getFont(.semibold, size: 14)

        if let departDirection = (route.directions.filter { $0.type == .depart }).first {

            var color: UIColor = Colors.primaryText

            let content = "Depart at \(departDirection.startTimeWithDelayDescription) from \(departDirection.name)"
            // This changes font to standard size. Label's font is different.
            var attributedString = departDirection.startTimeWithDelayDescription.bold(
                in: content,
                from: mainLabel.font,
                to: mainLabelBoldFont
            )
            attributedString = departDirection.name.bold(in: attributedString, to: mainLabelBoldFont)

            mainLabel.attributedText = attributedString

            if let delay = departDirection.delay {
                color = delay >= 60 ? Colors.lateRed : Colors.liveGreen

                let range = (attributedString.string as NSString).range(
                    of: departDirection.startTimeWithDelayDescription
                )
                attributedString.addAttribute(.foregroundColor, value: color, range: range)

                // Find time within label to place live indicator
                if let stringRect = mainLabel.boundingRect(of: departDirection.startTimeWithDelayDescription + " ") {
                    // Add spacing to insert live indicator within text
                    attributedString.insert(NSAttributedString(string: "    "), at: range.location + range.length)
                    liveIndicator.setColor(to: color)
                    if !mainLabel.subviews.contains(liveIndicator) {
                        mainLabel.addSubview(liveIndicator)
                    }

                    liveIndicator.snp.remakeConstraints { make in
                        make.leading.equalToSuperview().inset(stringRect.maxX)
                        make.centerY.equalTo(stringRect.midY)
                    }

                    mainLabel.attributedText = attributedString
                }
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
            addSubview(iconView)
        } else {
            // Show walking glyph
            iconView = UIImageView(image: #imageLiteral(resourceName: "walk"))
            iconView.contentMode = .scaleAspectFit
            iconView.tintColor = Colors.metadataIcon
            addSubview(iconView)
        }
    }

}
