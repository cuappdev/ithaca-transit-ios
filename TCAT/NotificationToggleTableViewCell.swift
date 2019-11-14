//
//  NotificationToggleTableViewCell.swift
//  TCAT
//
//  Created by HAIYING WENG on 11/3/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import NotificationBannerSwift
import UIKit

class NotificationToggleTableViewCell: UITableViewCell {
    
    private var title = ""

    private let firstHairline = UIView()
    private let hairline = UIView()
    private let notificationSwitch = UISwitch()
    private let notificationTitleLabel = UILabel()

    private let hairlineHeight = 0.5
    
    private var notificationBanner: NotificationBanner?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        hairline.backgroundColor = Colors.tableViewSeparator
        contentView.addSubview(hairline)

        notificationSwitch.onTintColor = Colors.tcatBlue
        notificationSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        notificationSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        contentView.addSubview(notificationSwitch)

        notificationTitleLabel.font = .getFont(.regular, size: 14)
        notificationTitleLabel.textColor = Colors.primaryText
        contentView.addSubview(notificationTitleLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        let notificationTitleLeadingInset = 16
        let notificationTitleTrailingInset = 10
        let switchTrailingInset = 15

        hairline.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(hairlineHeight)
        }

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
    
    func setupFirstHairline() {
        firstHairline.backgroundColor = Colors.tableViewSeparator
        contentView.addSubview(firstHairline)

        firstHairline.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(hairlineHeight)
        }
    }

    func configure(for notificationTitle: String, isFirst: Bool) {
        title = notificationTitle
        notificationTitleLabel.text = notificationTitle
        if isFirst {
            setupFirstHairline()
        }
    }
    
    @objc func switchValueChanged() {
        if notificationSwitch.isOn {
            if title == Constants.Notification.notifyDelay {
                notificationBanner = NotificationBanner(customView: NotificationBannerView(notificationType: NotificationType.delayConfirmation))
            } else {
                notificationBanner = NotificationBanner(customView: NotificationBannerView(notificationType: NotificationType.beforeBoardingConfirmation))
            }
            notificationBanner?.bannerHeight = 100
            notificationBanner?.show()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
