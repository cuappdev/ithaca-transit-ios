//
//  NotificationBannerView.swift
//  TCAT
//
//  Created by HAIYING WENG on 11/13/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

enum NotificationType {
    
    case beforeBoardingConfirmation, busArriving, busDelay, delayConfirmation
    
    var bannerColor: UIColor {
        switch self {
        case .beforeBoardingConfirmation, .busArriving, .delayConfirmation:
            return Colors.tcatBlue
        case .busDelay:
            return Colors.lateRed
        }
    }

}

class NotificationBannerView: RoundShadowedView {

    private var type: NotificationType

    private let notificationLabel = UILabel()

    init(busAttachment: NSTextAttachment, notificationType: NotificationType) {
        let cornerRadius: CGFloat = 10

        self.type = notificationType
        super.init(cornerRadius: cornerRadius)

        layer.shadowOpacity = 0.8

        containerView.backgroundColor = type.bannerColor

        notificationLabel.attributedText = formatTitleLabel(attachment: busAttachment)
        notificationLabel.font = .getFont(.regular, size: 14)
        notificationLabel.textColor = Colors.white
        notificationLabel.lineBreakMode = .byWordWrapping
        notificationLabel.numberOfLines = 0
        containerView.addSubview(notificationLabel)
        
        setupConstraints()
    }

    private func setupConstraints() {
        let containerViewInset = 8
        let notificationLabelInset = 15
        let topPadding = 5

        containerView.snp.remakeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(containerViewInset)
            make.top.equalToSuperview().inset(topPadding)
        }

        notificationLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(notificationLabelInset)
            make.top.bottom.equalToSuperview().inset(notificationLabelInset)
        }
    }

    private func formatTitleLabel(attachment: NSTextAttachment) -> NSMutableAttributedString {
 
        var beginningText: String {
            switch type {
            case .beforeBoardingConfirmation:
                return Constants.Notification.beforeBoardingConfirmation
            case .delayConfirmation:
                return Constants.Notification.delayConfirmation
            case .busArriving, .busDelay:
                return ""
            }
        }

        let notificationText = NSMutableAttributedString(string: beginningText)
        if type == .delayConfirmation {
            notificationText.append(NSAttributedString(attachment: attachment))
        }

        return notificationText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


