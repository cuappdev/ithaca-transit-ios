//
//  BusStopTableViewCell.swift
//  TCAT
//
//  Created by Matthew Barker on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class BusStopTableViewCell: UITableViewCell {

    private let connectorBottom = UIView()
    private let connectorTop = UIView()
    private let statusCircle = Circle(size: .small, style: .outline, color: Colors.tcatBlue)
    private let titleLabel = UILabel()
    private let hairline = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.font = .getFont(.regular, size: 14)
        titleLabel.textColor = Colors.secondaryText
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)

        connectorTop.backgroundColor = Colors.tcatBlue
        contentView.addSubview(connectorTop)

        connectorBottom.backgroundColor = Colors.tcatBlue
        contentView.addSubview(connectorBottom)

        contentView.addSubview(statusCircle)

        setupConstraints()
    }

    private func setupConstraints() {
        let cellHeight: CGFloat = RouteDetailCellSize.smallHeight
        let cellWidth: CGFloat = RouteDetailCellSize.indentedWidth
        let connectorSize = CGSize(width: 4, height: cellHeight / 2)
        let statusCircleLeadingInset = DetailIconView.width - 16 - (statusCircle.frame.width / 2)
        let titleLabelSize = CGSize(width: UIScreen.main.bounds.width - cellWidth - 20, height: 20)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(cellWidth)
            make.centerY.equalToSuperview()
            make.size.equalTo(titleLabelSize)
        }

        connectorTop.snp.makeConstraints { make in
            make.centerX.equalTo(statusCircle)
            make.top.equalToSuperview()
            make.size.equalTo(connectorSize)
        }

        connectorBottom.snp.makeConstraints { make in
            make.centerX.equalTo(statusCircle)
            make.top.equalTo(connectorTop.snp.bottom)
            make.size.equalTo(connectorSize)
        }

        statusCircle.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(statusCircleLeadingInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(statusCircle.intrinsicContentSize)
        }
    }

    private func setupConfigDependentConstraints() {
        hairline.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.bottom.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    func configure(for name: String) {
        titleLabel.text = name

        hairline.backgroundColor = Colors.tableViewSeparator
        contentView.addSubview(hairline)

        setupConfigDependentConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
