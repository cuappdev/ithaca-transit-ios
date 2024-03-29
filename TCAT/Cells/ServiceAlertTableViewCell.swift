//
//  ServiceAlertTableViewCell.swift
//  TCAT
//
//  Created by Omar Rasheed on 12/7/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import SnapKit
import UIKit

class ServiceAlertTableViewCell: UITableViewCell {

    static let identifier: String = "serviceAlertCell"

    private var affectedRoutesLabel: UILabel?
    private var affectedRoutesStackView: UIStackView?
    private var descriptionLabel = UILabel()
    private var timeSpanLabel = UILabel()
    private var topSeparator: UIView?

    private let busIconHorizontalSpacing: CGFloat = 10
    private let borderInset: CGFloat = 16
    private var maxIconsPerRow: Int {
        let iconWidth = BusIconType.directionSmall.width
        let screenWidth = UIScreen.main.bounds.width
        let totalConstraintInset = borderInset * 2

        // swiftlint:disable:next line_length
        return Int((screenWidth - totalConstraintInset + busIconHorizontalSpacing) / (iconWidth + busIconHorizontalSpacing))
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupTimeSpanLabel()
        setupDescriptionLabel()
    }

    func configure(for alert: ServiceAlert, isNotFirstRow: Bool) {
        timeSpanLabel.text = formatTimeString(alert.fromDate, toDate: alert.toDate)

        descriptionLabel.text = alert.message
        if !alert.routes.isEmpty {
            setupAffectedRoutesStackView(alert: alert)
            setupaffectedRoutesLabel()
        }

        if isNotFirstRow {
            setupTopSeparator()
        }
    }

    private func setupTimeSpanLabel() {

        timeSpanLabel.numberOfLines = 0
        timeSpanLabel.font = .getFont(.semibold, size: 18)
        timeSpanLabel.textColor = Colors.primaryText

        contentView.addSubview(timeSpanLabel)
    }

    private func setupDescriptionLabel() {

        descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .getFont(.regular, size: 14)
        descriptionLabel.textColor = Colors.primaryText

        contentView.addSubview(descriptionLabel)
    }

    private func setupaffectedRoutesLabel() {

        let affectedRoutesLabel = UILabel()
        affectedRoutesLabel.font = .getFont(.semibold, size: 18)
        affectedRoutesLabel.textColor = Colors.primaryText
        affectedRoutesLabel.text = Constants.General.affectedRoutes

        self.affectedRoutesLabel = affectedRoutesLabel

        contentView.addSubview(affectedRoutesLabel)
    }

    private func setupAffectedRoutesStackView(alert: ServiceAlert) {
        let busIconVerticalSpacing: CGFloat = 10

        affectedRoutesStackView = UIStackView()
        var routesCopy = alert.routes
        for _ in 0..<rowCount(alert: alert) {
            var subviews = [BusIcon]()
            for _ in 0..<maxIconsPerRow where !routesCopy.isEmpty {
                let route = routesCopy.removeFirst()
                subviews.append(BusIcon(type: .directionSmall, number: route))
            }
            let rowStackView = UIStackView(arrangedSubviews: subviews)
            rowStackView.axis = .horizontal
            rowStackView.spacing = busIconHorizontalSpacing
            rowStackView.alignment = .top
            affectedRoutesStackView?.addArrangedSubview(rowStackView)
        }

        guard let stackView = affectedRoutesStackView else { return }
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = busIconVerticalSpacing
        contentView.addSubview(stackView)
    }

    private func setupTopSeparator() {

        topSeparator = UIView()
        topSeparator?.backgroundColor = Colors.backgroundWash

        contentView.addSubview(topSeparator!)
    }

    private func descriptionLabelConstraints(topConstraint: UIView) {
        descriptionLabel.snp.remakeConstraints { (make) in
            if topConstraint == contentView {
                make.top.equalToSuperview().inset(borderInset)
            } else {
                make.top.equalTo(topConstraint.snp.bottom).offset(12)
            }
            make.leading.trailing.equalToSuperview().inset(borderInset)
            if let text = descriptionLabel.text {
                let width = contentView.frame.width - (CGFloat)(2 * borderInset)
                let heightValue = ceil(text.heightWithConstrainedWidth(width: width, font: descriptionLabel.font))
                make.height.equalTo(ceil(heightValue))
            } else {
                make.height.equalTo(descriptionLabel.intrinsicContentSize.height)
            }
        }
    }

    private func timeSpanLabelConstraints(topConstraint: UIView) {
        timeSpanLabel.snp.remakeConstraints { (make) in
            if topConstraint == contentView {
                make.top.equalToSuperview().inset(borderInset)
            } else {
                make.top.equalTo(topConstraint.snp.bottom).offset(12)
            }
            make.leading.trailing.equalToSuperview().inset(borderInset)
            make.height.equalTo(timeSpanLabel.intrinsicContentSize.height)
        }
    }

    private func topSeparatorConstraints() {
        let topSeparatorHeight = 8
        if let topSeparator = topSeparator {
            topSeparator.snp.remakeConstraints { (make) in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(topSeparatorHeight)
            }
        }
    }

    override func updateConstraints() {
        let stackViewTopOffset = 24
        if let topSeparator = topSeparator, timeSpanLabel.isDescendant(of: contentView) {
            // Both topSeparator and timeSpanLabel exist
            topSeparatorConstraints()
            timeSpanLabelConstraints(topConstraint: topSeparator)
            descriptionLabelConstraints(topConstraint: timeSpanLabel)
        } else if timeSpanLabel.isDescendant(of: contentView) {
            // Only timeSpanLabel, no topSeparator
            timeSpanLabelConstraints(topConstraint: contentView)
            descriptionLabelConstraints(topConstraint: timeSpanLabel)
        } else if let topSeparator = topSeparator {
            // Only topSeparator, no timeSpanLabel
            topSeparatorConstraints()
            descriptionLabelConstraints(topConstraint: topSeparator)
        } else {
            // Neither
            descriptionLabelConstraints(topConstraint: contentView)
        }

        if let stackView = affectedRoutesStackView, let affectedRoutesLabel = affectedRoutesLabel {
            // When both a separator view and stackView are required
            affectedRoutesLabel.snp.remakeConstraints { (make) in
                make.leading.equalTo(descriptionLabel)
                make.top.equalTo(descriptionLabel.snp.bottom).offset(stackViewTopOffset)
                make.size.equalTo(affectedRoutesLabel.intrinsicContentSize)
            }
            stackView.snp.remakeConstraints { (make) in
                make.top.equalTo(affectedRoutesLabel.snp.bottom).offset(8)
                make.leading.equalTo(descriptionLabel)
                make.bottom.equalToSuperview().inset(borderInset)
            }
        } else {
            descriptionLabel.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().inset(borderInset)
            }
        }
        super.updateConstraints()
    }

    private func formatTimeString(_ fromDate: String, toDate: String) -> String {

        let newformatter = DateFormatter()
        newformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sZZZZ"
        newformatter.locale = Locale(identifier: "en_US_POSIX")

        let fromDate = newformatter.date(from: fromDate)
        let toDate = newformatter.date(from: toDate)

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE M/d"

        if let unWrappedFromDate = fromDate, let unWrappedToDate = toDate {
            let formattedFromDate = formatter.string(from: unWrappedFromDate)
            let formattedToDate = formatter.string(from: unWrappedToDate)

            return "\(formattedFromDate) - \(formattedToDate)"
        }

        timeSpanLabel.removeFromSuperview()
        return "Time: Unknown"
    }

    private func rowCount(alert: ServiceAlert) -> Int {
        if alert.routes.count > maxIconsPerRow {
            let addExtra = alert.routes.count % maxIconsPerRow > 0 ? 1 : 0
            let rowCount = alert.routes.count / maxIconsPerRow

            return rowCount + addExtra
        } else {
            return 1
        }
    }

    private func getDayOfWeek(_ today: Date) -> Int? {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: today)
        return weekDay
    }

    override func prepareForReuse() {
        if let stackView = affectedRoutesStackView {
            stackView.removeFromSuperview()
            affectedRoutesStackView = nil
        }

        if let routesLabel = affectedRoutesLabel {
            routesLabel.removeFromSuperview()
            affectedRoutesLabel = nil
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
