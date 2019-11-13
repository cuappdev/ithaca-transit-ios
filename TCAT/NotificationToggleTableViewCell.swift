//
//  NotificationToggleTableViewCell.swift
//  TCAT
//
//  Created by HAIYING WENG on 11/3/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

class NotificationToggleTableViewCell: UITableViewCell {

    private let notificationSwitch = UISwitch()
    private let notificationTitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        notificationSwitch.onTintColor = Colors.tcatBlue
        notificationSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        contentView.addSubview(notificationSwitch)

        notificationTitleLabel.font = .getFont(.regular, size: 14)
        notificationTitleLabel.textColor = Colors.primaryText
        contentView.addSubview(notificationTitleLabel)

        setupHairline(isTop: false)

        setUpConstraints()
    }

    private func setUpConstraints() {
        let notificationTitleLeadingInset = 16
        let notificationTitleTrailingInset = 10
        let switchTrailingInset = 15

        notificationSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-switchTrailingInset)
        }

        notificationTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(notificationTitleLeadingInset)
            make.trailing.equalTo(notificationSwitch.snp.leading).offset(notificationTitleTrailingInset)
        }
    }
    
    func setupHairline(isTop: Bool) {
        let hairline = UIView()
        let hairlineHeight = 0.5

        hairline.backgroundColor = Colors.tableViewSeparator
        contentView.addSubview(hairline)

        hairline.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(hairlineHeight)
            if isTop {
                make.top.equalToSuperview()
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }

    func configure(for notificationTitle: String, isFirst: Bool) {
        notificationTitleLabel.text = notificationTitle
        if isFirst {
            setupHairline(isTop: true)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
