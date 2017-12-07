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
    var backButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "About Us"
        
        view.backgroundColor = UIColor.tableBackgroundColor
        navigationController?.navigationBar.tintColor = .primaryTextColor
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(sendFeedbackButton)
        view.addSubview(visitWebsiteButton)
        view.addSubview(tcatImage)
        
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        let attributedString = NSMutableAttributedString(string: "  Back")
        attributedString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0.3, range: NSMakeRange(0, attributedString.length))
        backButton.setAttributedTitle(attributedString, for: .normal)
        backButton.sizeToFit()
        let backButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.setLeftBarButton(backButtonItem, animated: false)
        
        tcatImage.image = UIImage(named: "tcatbus")
        tcatImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(44)
            make.width.equalTo(tcatImage.snp.height).multipliedBy(2.5)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
        
        titleLabel.font = UIFont(name: FontNames.SanFrancisco.Medium, size: 16)
        titleLabel.textColor = UIColor.primaryTextColor
        titleLabel.text = "Made by AppDev"
        titleLabel.backgroundColor = .clear
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tcatImage.snp.bottom).offset(44)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-12)
            make.height.equalTo(19)
        }
        
        descriptionLabel.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 14)
        descriptionLabel.textColor = UIColor.primaryTextColor
        descriptionLabel.text = "Cornell University\nApp Development Project Team"
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.textAlignment = .center
        descriptionLabel.snp.makeConstraints { (make) in
            make.height.equalTo(34)
//            make.bottom.equalTo(view.snp.centerY).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        sendFeedbackButton.addTarget(self, action: #selector(openBugReportForm), for: .touchUpInside)
        sendFeedbackButton.setTitle("Send Feedback", for: .normal)
        sendFeedbackButton.setTitleColor(UIColor.tcatBlueColor, for: .normal)
        sendFeedbackButton.titleLabel?.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 14)
        sendFeedbackButton.backgroundColor = .white
        sendFeedbackButton.layer.borderColor = UIColor.lineDarkColor.cgColor
        sendFeedbackButton.layer.borderWidth = 0.5
        sendFeedbackButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(-0.5)
            make.trailing.equalToSuperview().offset(0.5)
            make.height.equalTo(44)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(37)
        }
        
        visitWebsiteButton.addTarget(self, action: #selector(openTeamWebsite), for: .touchUpInside)
        visitWebsiteButton.setTitle("Visit Our Website", for: .normal)
        visitWebsiteButton.setTitleColor(UIColor.primaryTextColor, for: .normal)
        visitWebsiteButton.titleLabel?.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 14)
        visitWebsiteButton.backgroundColor = .white
        visitWebsiteButton.layer.borderColor = UIColor.lineDarkColor.cgColor
        visitWebsiteButton.layer.borderWidth = 0.5
        visitWebsiteButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.leading.equalTo(sendFeedbackButton)
            make.trailing.equalTo(sendFeedbackButton)
            make.height.equalTo(44)
            make.top.equalTo(sendFeedbackButton.snp.bottom).offset(-0.5)
        }
    }
    
    @objc func backButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func openBugReportForm() {
        let betaFormURL = "https://goo.gl/forms/u2shinl8ddNyFuZ23"
        let safariViewController = SFSafariViewController(url: URL(string: betaFormURL)!)
        UIApplication.shared.keyWindow?.presentInApp(safariViewController)
    }
    
    @objc func openTeamWebsite() {
        let siteURL = "http://www.cornellappdev.com"
        let safariViewController = SFSafariViewController(url: URL(string: siteURL)!)
        UIApplication.shared.keyWindow?.presentInApp(safariViewController)
    }
}
