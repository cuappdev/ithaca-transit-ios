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
    
    var titleText = UITextView()
    var appDevImage = UIImageView()
    var appDevTitle = UILabel()
    var descriptionTextView = UITextView()
    var tcatQuoteText = UILabel()
    var tcatImage = UIImageView()
    var submitBugButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "About"
        
        view.backgroundColor = UIColor.tableBackgroundColor
        
        view.addSubview(titleText)
        view.addSubview(appDevImage)
        view.addSubview(appDevTitle)
        view.addSubview(descriptionTextView)
        view.addSubview(submitBugButton)
        view.addSubview(tcatImage)
        view.addSubview(tcatQuoteText)
        
        titleText.font = UIFont(name: FontNames.SanFrancisco.Bold, size: 28)
        titleText.textColor = UIColor.primaryTextColor
//        titleText.text = "Thank you for using TCAT"
        titleText.backgroundColor = .clear
        titleText.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(36)
            make.width.equalTo(250)
            make.height.equalTo(100)
        }
        
        tcatImage.image = UIImage(named: "tcatbus")
        tcatImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleText.snp.bottom).offset(24)
            make.width.equalTo(300)
            make.height.equalTo(120)
        }
        
        tcatQuoteText.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 8)
        tcatQuoteText.textColor = UIColor.secondaryTextColor
        tcatQuoteText.text = "The TCAT bus goes vroom vroom"
        tcatQuoteText.snp.makeConstraints { (make) in
            make.trailing.equalTo(tcatImage.snp.trailing).offset(20)
            make.width.equalTo(150)
            make.height.equalTo(20)
            make.top.equalTo(tcatImage.snp.bottom).offset(4)
        }
        
        submitBugButton.addTarget(self, action: #selector(openBugReportForm), for: .touchUpInside)
        submitBugButton.setTitle("Submit a bug", for: .normal)
        submitBugButton.setTitleColor(.white, for: .normal)
        submitBugButton.titleLabel?.font = UIFont(name: FontNames.SanFrancisco.Medium, size: 16)
        submitBugButton.backgroundColor = UIColor.tcatBlueColor
        submitBugButton.layer.cornerRadius = 5.0
        submitBugButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-85)
            make.width.equalTo(135)
            make.height.equalTo(44)
        }
        
        descriptionTextView.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 16)
        descriptionTextView.textColor = UIColor.secondaryTextColor
        descriptionTextView.text = "TCAT is still in its baby stage. If you discover any bugs, please report them using the button below, and we will promise to squash them. Happy riding!"
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.textAlignment = .center
        descriptionTextView.snp.makeConstraints { (make) in
            make.leading.equalTo(titleText.snp.leading)
            make.bottom.equalTo(submitBugButton.snp.top).offset(-12)
            make.width.equalToSuperview().offset(-30)
            make.height.equalTo(100)
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
    
    @objc func openBugReportForm() {
        let betaFormURL = "https://goo.gl/forms/u2shinl8ddNyFuZ23"
        let safariViewController = SFSafariViewController(url: URL(string: betaFormURL)!)
        UIApplication.shared.keyWindow?.presentInApp(safariViewController)
    }
    
}
