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
    
    var color: UIColor {
        switch self {
        case .beforeBoardingConfirmation, .busArriving, .delayConfirmation:
            return Colors.tcatBlue
        case .busDelay:
            return Colors.lateRed
        }
    }
    
    var title: String {
        switch self {
        case .beforeBoardingConfirmation:
            return Constants.Notification.beforeBoardingConfirmation
        case .delayConfirmation:
            return Constants.Notification.delayConfirmation
        case .busArriving:
            return Constants.Notification.arrivalNotification
        case .busDelay:
            return Constants.Notification.delayNotification
        }
    }
}

class NotificationBannerView: RoundShadowedView {
    
    private var type: NotificationType

    private let notificationLabel = UILabel()
    
    init(notificationType: NotificationType) {
        let cornerRadius: CGFloat = 10
        
        self.type = notificationType
        super.init(cornerRadius: cornerRadius)
        
        layer.shadowOpacity = 1

        containerView.backgroundColor = type.color
        
        notificationLabel.text = type.title
        notificationLabel.textColor = Colors.white
        notificationLabel.font = .getFont(.regular, size: 14)
        containerView.addSubview(notificationLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let notificationLabelInset = 15
        
        containerView.snp.remakeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
        }
        
        notificationLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(notificationLabelInset)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


