//
//  NotificationToggleTableViewCell.swift
//  TCAT
//
//  Created by HAIYING WENG on 11/3/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

protocol NotificationToggleTableViewDelegate: AnyObject {
    func displayNotificationBanner(type: NotificationBannerType)
}

class NotificationToggleTableViewCell: UITableViewCell {

    private weak var delegate: NotificationToggleTableViewDelegate?

    private var type: NotificationType!

    private let firstHairline = UIView()
    private let hairline = UIView()
    private let notificationSwitch = UISwitch()
    private let notificationTitleLabel = UILabel()

    private var startTime: Int = 0
    private var tripId: String = ""
    private var stopId: String?
    private let hairlineHeight = 0.5

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

    func configure(
        for type: NotificationType,
        isFirst: Bool,
        delegate: NotificationToggleTableViewDelegate? = nil,
        startTime: Int,
        tripId: String,
        stopId: String?
    ) {
        self.startTime = startTime
        self.tripId = tripId
        self.stopId = stopId
        self.delegate = delegate
        self.type = type
        notificationTitleLabel.text = type.title
        notificationSwitch.setOn(isToggleOn(for: type, tripId: tripId), animated: false)
        if isFirst {
            setupFirstHairline()
        }
    }
    
    func setSwitchOn(_ isOn: Bool) {
        notificationSwitch.setOn(isOn, animated: false)
    }
    
    // Build a stable key for persistence
    private func key(for type: NotificationType, tripId: String) -> String {
        let typeKey: String
        switch type {
        case .delay: typeKey = "delay"
        case .beforeBoarding: typeKey = "beforeBoarding"
        // add any other cases here
        }
        return "toggle-\(typeKey)-\(tripId)"
    }

    func isToggleOn(for type: NotificationType, tripId: String) -> Bool {
        let k = key(for: type, tripId: tripId)
        return UserDefaults.standard.bool(forKey: k)
    }

    func setToggle(_ on: Bool, for type: NotificationType, tripId: String) {
        let k = key(for: type, tripId: tripId)
        UserDefaults.standard.set(on, forKey: k)
    }
    

    @objc func switchValueChanged() {

        let isOn = notificationSwitch.isOn
        
        setToggle(isOn, for: type, tripId: tripId)

  

        if isOn {
            switch type {
            case .beforeBoarding:
                let now = Int(Date().timeIntervalSince1970)
                if startTime - now > 600 {
                    delegate?.displayNotificationBanner(type: .beforeBoardingConfirmation)
                    TransitNotificationSubscriber.shared.subscribeToDepartureNotifications(startTime: String(startTime))
                } else {
                    notificationSwitch.setOn(false, animated: true)
                    setToggle(false, for: type, tripId: tripId)
                    delegate?.displayNotificationBanner(type: .unableToConfirmBeforeBoarding)
                }
            case .delay:
                delegate?.displayNotificationBanner(type: .delayConfirmation)
                TransitNotificationSubscriber.shared.subscribeToDelayNotifications(stopID: stopId, tripID: tripId)

            default: break
            }
        } else {
            switch type {
            case .beforeBoarding:
                TransitNotificationSubscriber.shared.unsubscribeFromDepartureNotifications(startTime: String(startTime))

            case .delay:
                TransitNotificationSubscriber.shared.unsubscribeFromDelayNotifications(stopID: stopId, tripID: tripId)

            default: break
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
