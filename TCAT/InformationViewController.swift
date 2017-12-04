//
//  InformationViewController.swift
//  TCAT
//
//  Created by Ji Hwan Seung on 19/11/2017.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import SafariServices

class InformationViewController: UIViewController {
    
    var titleLabel = UILabel()
    var appDevImage = UIImageView()
    var appDevTitle = UILabel()
    var descriptionLabel = UILabel()
    var tcatQuoteText = UILabel()
    var tcatImage = UIImageView()
    var sendFeedbackButton = UIButton()
    var visitWebsiteButton = UIButton()
    var cancelButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "About Us"
        
        view.backgroundColor = UIColor.tableBackgroundColor
        
        view.addSubview(titleLabel)
        view.addSubview(appDevImage)
        view.addSubview(appDevTitle)
        view.addSubview(descriptionLabel)
        view.addSubview(sendFeedbackButton)
        view.addSubview(tcatImage)
        view.addSubview(tcatQuoteText)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        let attributedString = NSMutableAttributedString(string: "Cancel")
        attributedString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0.3, range: NSMakeRange(0, attributedString.length))
        cancelButton.setAttributedTitle(attributedString, for: .normal)
        cancelButton.sizeToFit()
        let cancelButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.setLeftBarButton(cancelButtonItem, animated: false)
        
        tcatImage.image = UIImage(named: "tcatbus")
        tcatImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(32)
            make.bottom.equalTo(titleLabel.snp.top).offset(-28)
            make.width.equalTo(tcatImage.snp.height).multipliedBy(2)
        }
        
        titleLabel.font = UIFont(name: FontNames.SanFrancisco.Medium, size: 16)
        titleLabel.textColor = UIColor.primaryTextColor
        titleLabel.text = "Made by AppDev"
        titleLabel.backgroundColor = .clear
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-12)
        }
        
        descriptionLabel.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 14)
        descriptionLabel.textColor = UIColor.primaryTextColor
        descriptionLabel.text = "Cornell University\nApp Development Project Team"
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.textAlignment = .center
        descriptionLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.centerY).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        sendFeedbackButton.addTarget(self, action: #selector(openBugReportForm), for: .touchUpInside)
        sendFeedbackButton.setTitle("Send feedback", for: .normal)
        sendFeedbackButton.setTitleColor(.white, for: .normal)
        sendFeedbackButton.titleLabel?.font = UIFont(name: FontNames.SanFrancisco.Medium, size: 16)
        sendFeedbackButton.backgroundColor = UIColor.tcatBlueColor
        sendFeedbackButton.layer.cornerRadius = 5.0
        sendFeedbackButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-85)
            make.width.equalTo(135)
            make.height.equalTo(44)
        }
        
        appDevTitle.font = UIFont(name: FontNames.SanFrancisco.Medium, size: 10)
        appDevTitle.textColor = UIColor.secondaryTextColor
        appDevTitle.text = "Created by Cornell App Development"
        appDevTitle.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview().offset(15)
            make.width.equalTo(180)
            make.height.equalTo(appDevImage.snp.height)
        }
        
        appDevImage.image = UIImage(named: "appdev_logo")
        appDevImage.snp.makeConstraints { (make) in
            make.bottom.equalTo(appDevTitle.snp.bottom)
            make.trailing.equalTo(appDevTitle.snp.leading).offset(-10)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
    }
    
    @objc func cancelButtonClicked() {
        self.dismiss(animated: true, completion: nil)
        
//        let transition: CATransition = CATransition()
//        transition.duration = 0.5
//        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromBottom
//        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
//        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func openBugReportForm() {
        let betaFormURL = "https://goo.gl/forms/u2shinl8ddNyFuZ23"
        let safariViewController = SFSafariViewController(url: URL(string: betaFormURL)!)
        UIApplication.shared.keyWindow?.presentInApp(safariViewController)
    }
    
}
