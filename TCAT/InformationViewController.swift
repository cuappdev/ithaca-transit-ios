//
//  InformationViewController.swift
//  TCAT
//
//  Created by Ji Hwan Seung on 19/11/2017.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import SafariServices
import SwiftRegister

class InformationViewController: UIViewController {
    
    var titleLabel = UILabel()
    var appDevImage = UIImageView()
    var appDevTitle = UILabel()
    var descriptionLabel = UILabel()
    var tcatQuoteText = UILabel()
    var someLabel = UILabel()
    var tcatImage = UIImageView()
    var sendFeedbackButton = UIButton()
    var visitWebsiteButton = UIButton()
    var dismissButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "About Us"
        
        let scrollView = UIScrollView(frame: view.frame)
        scrollView.contentSize = view.frame.size
        view = scrollView
        
        view.backgroundColor = UIColor.tableBackgroundColor
        navigationController?.navigationBar.tintColor = .primaryTextColor
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(sendFeedbackButton)
        view.addSubview(visitWebsiteButton)
        view.addSubview(someLabel)
        view.addSubview(tcatImage)
        
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        dismissButton.setTitle("Done", for: .normal)
        guard let buttonAttributes = (navigationController as? CustomNavigationController)?.buttonTitleTextAttributes
            else { return }
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(buttonAttributes, for: .normal)
        let backButtonItem = UIBarButtonItem(customView: dismissButton)
        navigationItem.setRightBarButton(backButtonItem, animated: false)
        
        someLabel.font = UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 16)
        someLabel.textColor = .primaryTextColor
        someLabel.text = "Walker wuz here"
        someLabel.textAlignment = .center
        someLabel.backgroundColor = .clear
        someLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(86)
            make.centerX.equalToSuperview()
            make.height.equalTo(19)
        }
        
        tcatImage.image = UIImage(named: "tcatbus")
        tcatImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(busTapped)))
        tcatImage.isUserInteractionEnabled = true
        tcatImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(44)
            make.width.equalTo(tcatImage.snp.height).multipliedBy(2.5)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
        
        titleLabel.font = UIFont(name: Constants.Fonts.SanFrancisco.Medium, size: 16)
        titleLabel.textColor = UIColor.primaryTextColor
        titleLabel.text = "Made by Cornell App Development"
        titleLabel.backgroundColor = .clear
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tcatImage.snp.bottom).offset(44)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-12)
            make.height.equalTo(19)
        }
        
        descriptionLabel.font = UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 14)
        descriptionLabel.textColor = UIColor.primaryTextColor
        descriptionLabel.text = "An Engineering Project Team\nat Cornell University"
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.textAlignment = .center
        descriptionLabel.snp.makeConstraints { (make) in
            make.height.equalTo(34)
            // make.bottom.equalTo(view.snp.centerY).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        sendFeedbackButton.addTarget(self, action: #selector(openBugReportForm), for: .touchUpInside)
        sendFeedbackButton.setTitle("Send Feedback", for: .normal)
        sendFeedbackButton.setTitleColor(UIColor.tcatBlueColor, for: .normal)
        sendFeedbackButton.titleLabel?.font = UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 14)
        sendFeedbackButton.backgroundColor = .white
        sendFeedbackButton.layer.borderColor = UIColor.lineDotColor.cgColor
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
        visitWebsiteButton.titleLabel?.font = UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 14)
        visitWebsiteButton.backgroundColor = .white
        visitWebsiteButton.layer.borderColor = UIColor.lineDotColor.cgColor
        visitWebsiteButton.layer.borderWidth = 0.5
        visitWebsiteButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.leading.equalTo(sendFeedbackButton)
            make.trailing.equalTo(sendFeedbackButton)
            make.height.equalTo(44)
            make.top.equalTo(sendFeedbackButton.snp.bottom).offset(-0.5)
        }
    }
    
    @objc func dismissTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func openBugReportForm() {
        let safariViewController = SFSafariViewController(url: URL(string: Constants.App.feedbackLink)!)
        UIApplication.shared.keyWindow?.presentInApp(safariViewController)
    }
    
    @objc func openTeamWebsite() {
        let siteURL = "http://www.cornellappdev.com"
        let safariViewController = SFSafariViewController(url: URL(string: siteURL)!)
        UIApplication.shared.keyWindow?.presentInApp(safariViewController)
    }
    
    @objc func busTapped() {
        
        let constant: CGFloat = UIScreen.main.bounds.width
        let duration: TimeInterval = 1.5
        let delay: TimeInterval = 0
        let damping: CGFloat = 0.6
        let velocity: CGFloat = 0
        let options: UIViewAnimationOptions = .curveEaseInOut
        
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping,
                       initialSpringVelocity: velocity, options: options, animations: {
                        
            self.tcatImage.frame.origin.x += constant
                        
        }) { (completed) in
            
            self.tcatImage.frame.origin.x -= 2 * constant
            
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping,
                           initialSpringVelocity: velocity, options: options, animations: {
                            
                self.tcatImage.frame.origin.x += constant
                            
            })
            
        }
        
        let _ = RegisterSession.shared?.logEvent(event: InformationViewControllerTappedEventPayload().toEvent())
        
    }
    
}
