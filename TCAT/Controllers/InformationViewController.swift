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
import MessageUI

class InformationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    var titleLabel = UILabel()
    var appDevImage = UIImageView()
    var appDevTitle = UILabel()
    var descriptionLabel = UILabel()
    var tcatQuoteText = UILabel()
    var hiddenLabel = UILabel()
    var tcatImage = UIImageView()
    var sendFeedbackButton = UIButton()
    var visitWebsiteButton = UIButton()
    var dismissButton = UIButton(type: .system)
    
    var tableView = UITableView(frame: .zero, style: .grouped)
    
    var content: [[(name: String, action: Selector)]] = [
    
        [ // Section 0
            (name: "Show Onboarding", action: #selector(presentOnboarding)),
            (name: "Send Feedback", action: #selector(sendFeedback)),
        ],
        
        [ // Section 1
            (name: "More Apps", action: #selector(showMoreApps)),
            (name: "Visit Our Website", action: #selector(openTeamWebsite)),
        ],
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "About Us"
        
        view.backgroundColor = .tableBackgroundColor
        navigationController?.navigationBar.tintColor = .primaryTextColor
        UIApplication.shared.statusBarStyle = .default
        
        view.addSubview(hiddenLabel)
        view.addSubview(tcatImage)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(tableView)
        
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        dismissButton.setTitle("Done", for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            CustomNavigationController.buttonTitleTextAttributes, for: .normal
        )
        let backButtonItem = UIBarButtonItem(customView: dismissButton)
        navigationItem.setRightBarButton(backButtonItem, animated: false)
        
        hiddenLabel.font = UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 16)
        hiddenLabel.textColor = .primaryTextColor
        hiddenLabel.text = "Ride on the Magic School Bus"
        hiddenLabel.textAlignment = .center
        hiddenLabel.backgroundColor = .clear
        hiddenLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(86)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
        tcatImage.image = UIImage(named: "tcat")
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
            make.height.equalTo(20)
        }
        
        descriptionLabel.font = UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 14)
        descriptionLabel.textColor = UIColor.primaryTextColor
        descriptionLabel.text = "An Engineering Project Team\nat Cornell University"
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.textAlignment = .center
        descriptionLabel.snp.makeConstraints { (make) in
            make.height.equalTo(34)
            make.centerX.equalToSuperview()
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cells.informationCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .tableBackgroundColor
        tableView.separatorColor = .lineDotColor
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        let payload = AboutPageOpenedPayload()
        RegisterSession.shared?.log(payload)
        
    }
    
    // MARK: Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return content.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Initalize and format cell
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.informationCellIdentifier, for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .primaryTextColor
        cell.textLabel?.font = UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 14)
        cell.textLabel?.textAlignment = .center
        
        // Set cell content
        cell.textLabel?.text = content[indexPath.section][indexPath.row].name
        
        // Set custom formatting based on cell
        switch (indexPath.section, indexPath.row) {
            
        case (0, 1): // Send Feedback
            cell.textLabel?.textColor = .tcatBlueColor
        default:
            break
            
        }
        
        return cell
        
    }
    
    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selector = content[indexPath.section][indexPath.row].action
        performSelector(onMainThread: selector, with: nil, waitUntilDone: false)
    }
    
    // MARK: Functions
    
    @objc func dismissTapped() {
        dismiss(animated: true)
    }
    
    // MARK: Cell Actions
    
    @objc func presentOnboarding() {
        let onboardingViewController = OnboardingViewController(initialViewing: false)
        let navigationController = OnboardingNavigationController(rootViewController: onboardingViewController)
        present(navigationController, animated: true)
    }
    
    @objc func sendFeedback() {
        
        let emailAddress = Constants.App.contactEmailAddress
        let subject = "Ithaca Transit Feedback v\(Constants.App.version)"
        
        let fileName = ""
        let extensionName = ""
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        var logRetreivalFailed = true
        
        // Attach logs
        if let fileURL = Bundle.main.url(forResource: fileName, withExtension: extensionName) {
            do {
                let file = try Data(contentsOf: fileURL)
                mailComposerVC.addAttachmentData(file, mimeType: "text/plain", fileName: fileName)
                logRetreivalFailed = false
            } catch _ { }
        }
        
        // Message body
        var html = ""
        html += "<!DOCTYPE html>"
        html += "<html>"
        html += "<body>"
        
        html += "<h2>Ithaca Transit Feedback Form</h2>"
        
        html += "<b>Problem:</b>"
        html += "<br><br>"
        
        if logRetreivalFailed {
            html += "<b>How to Reproduce:</b>"
            html += "<br><br>"
        }
        
        html += "<b>Other Comments:</b>"
        
        html += "</body>"
        html += "</html>"
        
        mailComposerVC.setToRecipients([emailAddress])
        mailComposerVC.setSubject(subject)
        mailComposerVC.setMessageBody(html, isHTML: true)
        
        if MFMailComposeViewController.canSendMail() {
            present(mailComposerVC, animated: true)
        } else {
            mailComposerError()
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Swift.Error?) {
        controller.dismiss(animated: true)
        if let error = error {
            print("error:", error)
        }
    }
    
    func mailComposerError() {
        
        func showMailAlert() {
            
            let title = "Send Feedback Error"
            let message = "There was an unexpected error while sending feedback. Please email \(Constants.App.contactEmailAddress) and send feedback on this (embarassing) issue and any other feedback."
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                print("action?")
            }))
            present(alertController, animated: true)
            
        }
        
        let address = Constants.App.contactEmailAddress
        let subject = "Ithaca Transit Feedback v\(Constants.App.version)"
        
        let coded = "mailto:\(address)?subject=\(subject)&body=\("")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        if let emailURL = URL(string: coded ?? "") {
            if UIApplication.shared.canOpenURL(emailURL) {
                UIApplication.shared.open(emailURL)
            } else {
                showMailAlert()
            }
        } else {
            showMailAlert()
        }

    }
    
    @objc func showMoreApps() {
        let appStorePage = "https://itunes.apple.com/us/developer/walker-white/id1089672961"
        open(appStorePage, inApp: false)
    }
    
    @objc func openTeamWebsite() {
        let homePage = "http://www.cornellappdev.com"
        open(homePage)
    }
    
    func open(_ url: String, inApp: Bool = true) {
        
        guard let URL = URL(string: url) else {
            return
        }
        
        if inApp {
            let safariViewController = SFSafariViewController(url: URL)
            UIApplication.shared.keyWindow?.presentInApp(safariViewController)
        } else {
            UIApplication.shared.open(URL)
        }
        
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
                            
            }) { (completed) in
                
                let title = "Be-beep be-beep!"
                let message = "says the TCAT bus."
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "✨📚🚌", style: .default, handler: nil))
                self.present(alertController, animated: true)
                
            }
            
        }
        
        let payload = BusTappedEventPayload()
        RegisterSession.shared?.log(payload)
        
    }
    
}
