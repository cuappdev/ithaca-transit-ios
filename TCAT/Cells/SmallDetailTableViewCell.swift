//
//  RouteDetailTableView.swift
//  TCAT
//
//  Created by Matthew Barker on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class SmallDetailTableViewCell: UITableViewCell {

    private var iconView = DetailIconView()
    private var titleLabel = UILabel()

    private var iconViewFrame: CGRect = CGRect()
    private let cellHeight: CGFloat = RouteDetailCellSize.smallHeight
    private let cellWidth: CGFloat = RouteDetailCellSize.regularWidth

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(iconView)

        titleLabel.font = .getFont(.regular, size: 14)
        titleLabel.textColor = Colors.primaryText
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)

        setupConstraints()
    }

    func configure(for direction: Direction, isFirstStep: Bool, isLastStep: Bool) {

        iconView.setData(for: direction, isFirstStep: isFirstStep, isLastStep: isLastStep)

        let titleLabelBoldFont: UIFont = .getFont(.semibold, size: 14)

        if direction.type == .arrive {
            // Arrive Direction
            titleLabel.attributedText = direction.name.bold(in: direction.locationNameDescription,
                                                            from: titleLabel.font,
                                                            to: titleLabelBoldFont)
        } else {
            // Walk Direction
            var walkString = direction.locationNameDescription
            if direction.travelDistance > 0 {
                walkString += " (\(direction.travelDistance.roundedString))"
            }
            titleLabel.attributedText = direction.name.bold(in: walkString,
                                                            from: titleLabel.font,
                                                            to: titleLabelBoldFont)
        }
    }

    func setupConstraints() {
        let detailIconViewWidth = 114
        let titleLabelLeadingOffset = 6
        let titleLabelTrailingInset = 20
        let titleLabelHeight = 20

        iconView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(detailIconViewWidth)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconView.snp.trailing).offset(titleLabelLeadingOffset)
            make.trailing.equalToSuperview().inset(titleLabelTrailingInset)
            make.height.equalTo(titleLabelHeight)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
