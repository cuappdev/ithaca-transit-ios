//
//  LargeDetailTableViewCell.swift
//  TCAT
//
//  Created by Matthew Barker on 2/13/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

protocol LargeDetailTableViewDelegate: class {
    func collapseCells(on cell: UITableViewCell)
    func expandCells(on cell: UITableViewCell)
}

class LargeDetailTableViewCell: UITableViewCell {

    var chevron: IncreasedTapSizeButton!

    var isExpanded: Bool = false

    private var busIconView: BusIcon!
    private var detailLabel: UILabel!
    private var iconView: DetailIconView!
    private var titleLabel: UILabel!

    private let cellWidth: CGFloat = RouteDetailCellSize.regularWidth
    private let edgeSpacing: CGFloat = 16
    private let labelSpacing: CGFloat = 4
    private let paragraphStyle = NSMutableParagraphStyle()
    private var cellHeight: CGFloat = RouteDetailCellSize.largeHeight
    private var direction: Direction!
    weak var delegate: LargeDetailTableViewDelegate?

    func getChevron() -> IncreasedTapSizeButton {
        let chevron = IncreasedTapSizeButton(frame: .zero, sizeIncrease: .init(width: 30, height: 30))
        chevron.frame.size = CGSize(width: 13.5, height: 8)
        chevron.frame.origin = CGPoint(x: UIScreen.main.bounds.width - 20 - chevron.frame.width, y: 0)
        chevron.setImage(UIImage(named: "arrow"), for: .normal)
        chevron.tintColor = Colors.metadataIcon
        chevron.addTarget(self, action: #selector(chevronButtonPressed), for: .touchUpInside)
        return chevron
    }

    func getTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: cellWidth, y: 0, width: chevron.frame.minX - cellWidth, height: 20)
        titleLabel.font = .getFont(.regular, size: 14)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textColor = Colors.primaryText
        titleLabel.text = direction != nil && direction.type == .transfer ? "Bus becomes" : "Board"
        titleLabel.sizeToFit()
        return titleLabel
    }

    func getDetailLabel() -> UILabel {
        let detailLabel = UILabel()
        detailLabel.frame = CGRect(x: cellWidth, y: 0, width: 20, height: 20)
        detailLabel.font = .getFont(.regular, size: 14)
        detailLabel.textColor = Colors.metadataIcon
        detailLabel.text = "Detail Label"
        detailLabel.lineBreakMode = .byWordWrapping
        detailLabel.sizeToFit()
        return detailLabel
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        chevron = getChevron()
        contentView.addSubview(chevron)

        titleLabel = getTitleLabel()
        contentView.addSubview(titleLabel)

        detailLabel = getDetailLabel()
        contentView.addSubview(detailLabel)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /** Precondition: Direction is BoardDirection */
    func setCell(_ direction: Direction, indexPath: IndexPath) {

        let firstStep = indexPath.row == 0
        self.direction = direction
        cellHeight = height()

        let shouldAddViews = iconView == nil || busIconView == nil ||
            titleLabel == nil || detailLabel == nil

        if shouldAddViews {

            iconView = DetailIconView(direction: direction, height: cellHeight, firstStep: firstStep, lastStep: false)
            contentView.addSubview(iconView!)

            titleLabel = formatTitleLabel(titleLabel)

            busIconView = BusIcon(type: .directionSmall, number: direction.routeNumber)
            busIconView = formatBusIconView(busIconView, titleLabel)
            contentView.addSubview(busIconView)

            detailLabel = formatDetailLabel(detailLabel, titleLabel)

            // Place bus icon and chevron accordingly
            chevron.center.y = cellHeight / 2

        } else {
            iconView?.updateTimes(with: direction)
        }

        if direction.stops.isEmpty {
            chevron.alpha = 0 // .hidden attribute used for animation
        }

    }

    /** Abstracted formatting of content for titleLabel */
    func formatTitleLabel(_ label: UILabel) -> UILabel {

        // Set inital text in label
        label.text = direction.type == .transfer ? "Bus becomes" : "Board"

        // Add correct amount of spacing to create a gap for the busIcon
        // Using constant always returned from
        //      while label.frame.maxX < busIconView.frame.maxX + 8 {
        // because it will occasionally run infinitely because of format func calls
        // TODO: Do this better!
        var accum = 0
        while accum <= (21) {
            accum += 1
            label.text! += " "
            label.sizeToFit()
        }

        // Format and place labels

        let content = label.text! + direction.locationNameDescription
        let labelBoldFont: UIFont = .getFont(.semibold, size: 14)
        let attributedString = direction.name.bold(in: content, from: label.font, to: labelBoldFont)
        label.attributedText = attributedString
        paragraphStyle.lineSpacing = 4

        label.numberOfLines = 0
        label.sizeToFit()
        label.frame.size.width = (chevron.frame.minX - 12) - cellWidth
        label.frame.origin.y = edgeSpacing // - paragraphStyle.lineSpacing

        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle,
                                      range: NSRange(location: 0, length: label.attributedText!.length))
        label.attributedText = attributedString

        return label
    }

    /** Abstracted formatting of content for detailLabel. Needs titleLabel */
    func formatDetailLabel(_ label: UILabel, _ titleLabel: UILabel) -> UILabel {

        label.text = "\(direction.stops.count + 1) stop\(direction.stops.count + 1 == 1 ? "" : "s")"

        // Number of minutes for the bus direction
        var timeString = Time.timeString(from: direction.startTime, to: direction.endTime)
        if timeString == "0 min" {  timeString = "1 min" }
        label.text = label.text! +  " • \(timeString)"

        label.sizeToFit()
        label.frame.origin.y = titleLabel.frame.maxY + labelSpacing
        return label
    }

    /** Abstracted formatting of content for busIconView. Needs initialized titleLabel */
    func formatBusIconView(_ icon: BusIcon, _ titleLabel: UILabel) -> BusIcon {

        let plainLabel = getTitleLabel()
        let originX = titleLabel.frame.minX + plainLabel.frame.size.width + 8
        var originY = titleLabel.frame.minY

        originY += titleLabel.font.lineHeight - icon.frame.size.height / 2 - CGFloat(titleLabel.numberOfLines() * 2)

        icon.frame.origin = CGPoint(x: originX, y: originY)
        return icon
    }

    /** Precondition: setCell must be called before using this function */
    func height() -> CGFloat {
        let titleLabel = formatTitleLabel(getTitleLabel())
        let detailLabel = formatDetailLabel(getDetailLabel(), titleLabel)
        return titleLabel.frame.height + detailLabel.frame.height + labelSpacing + (edgeSpacing * 2)
    }

    @objc func chevronButtonPressed() {
        if isExpanded {
            delegate?.collapseCells(on: self)
        } else {
            delegate?.expandCells(on: self)
        }
    }
}

class IncreasedTapSizeButton: UIButton {

    var verticalInset: CGFloat
    var horizontalInset: CGFloat

    init(frame: CGRect, sizeIncrease: CGSize) {
        verticalInset = sizeIncrease.height / 2
        horizontalInset = sizeIncrease.width / 2
        super.init(frame: frame)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        let largerArea = CGRect(
            x: self.bounds.origin.x - horizontalInset,
            y: self.bounds.origin.y - verticalInset,
            width: self.bounds.size.width + horizontalInset*2,
            height: self.bounds.size.height + verticalInset*2
        )

        return largerArea.contains(point)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
