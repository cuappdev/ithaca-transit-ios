//
//  InformationViewController.swift
//  TCAT
//
//  Created by Ji Hwan Seung on 19/11/2017.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import MessageUI
import SafariServices
import UIKit

class InformationViewController: UIViewController {

    private let appDevImage = UIImageView()
    private let appDevTitle = UILabel()
    private let descriptionLabel = UILabel()
    private let dismissButton = UIButton(type: .system)
    private var headerView: UIView!
    private let hiddenLabel = UILabel()
    private let sendFeedbackButton = UIButton()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let tcatImage = UIImageView()
    private let tcatQuoteText = UILabel()
    private let titleLabel = UILabel()
    private let visitWebsiteButton = UIButton()

    private var content: [[(name: String, action: Selector)]] = [

        [ // Section 0
            (name: Constants.InformationView.serviceAlerts, action: #selector(showServiceAlerts))
        ],

        [ // Section 1
            (name: Constants.InformationView.onboarding, action: #selector(presentOnboarding)),
            (name: Constants.InformationView.sendFeedback, action: #selector(sendFeedback))
        ],

        [ // Section 2
            (name: Constants.InformationView.moreApps, action: #selector(showMoreApps)),
            (name: Constants.InformationView.website, action: #selector(openTeamWebsite))
        ]

    ]

    private let descriptionLabelSize = CGSize(width: 167, height: 34)
    private let descriptionLabelTopOffset: CGFloat = 12
    private let headerWidth = UIScreen.main.bounds.width
    /** Represents the total height of the headerView given the width of the phone screen. Most of the variables
     used are static except for the tcat image height, which is dependent on the width of the user's screen.
     The extra 37 is used for bottom inset padding for the headerView, but I felt it would be unnecessary to
     create a variable for it */
    private var headerHeight: CGFloat {
        return tcatImageTopOffset + tcatImageSize.height + titleLabelTopOffset + titleLabelSize.height + descriptionLabelTopOffset + descriptionLabelSize.height + 37
    }
    private var tcatImageSize: CGSize { return CGSize(width: headerWidth-80, height: (headerWidth - 80) * 0.4) }
    private let tcatImageTopOffset: CGFloat = 44
    private let titleLabelSize = CGSize(width: 240, height: 20)
    private let titleLabelTopOffset: CGFloat = 44

    override func viewDidLoad() {
        super.viewDidLoad()

        let payload = AboutPageOpenedPayload()
        Analytics.shared.log(payload)

        title = Constants.Titles.aboutUs

        view.backgroundColor = Colors.backgroundWash
        navigationController?.navigationBar.tintColor = Colors.primaryText

        setupTableView()

        setupConstraints()
    }

    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cells.informationCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Colors.backgroundWash
        tableView.separatorColor = Colors.dividerTextField
        tableView.showsVerticalScrollIndicator = false

        setupHeaderView()
        tableView.tableHeaderView = headerView

        view.addSubview(tableView)
    }

    func setupHeaderView() {
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: headerWidth, height: headerHeight))

        setupDismissButton()
        setupHiddenLabel()
        setupTcatImage()
        setupTitleLabel()
        setupDescriptionLabel()

        setupHeaderViewConstraints()
    }

    func setupDismissButton() {
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        dismissButton.setTitle(Constants.Buttons.done, for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            CustomNavigationController.buttonTitleTextAttributes, for: .normal
        )
        let backButtonItem = UIBarButtonItem(customView: dismissButton)
        navigationItem.setRightBarButton(backButtonItem, animated: false)
    }

    func setupHiddenLabel() {
        hiddenLabel.font = .getFont(.regular, size: 16)
        hiddenLabel.textColor = Colors.primaryText
        hiddenLabel.text = Constants.InformationView.magicSchoolBus
        hiddenLabel.textAlignment = .center
        hiddenLabel.backgroundColor = .clear
        headerView.addSubview(hiddenLabel)
    }

    func setupTcatImage() {
        tcatImage.image = UIImage(named: "tcat")
        tcatImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(busTapped)))
        tcatImage.isUserInteractionEnabled = true
        headerView.addSubview(tcatImage)
    }

    func setupTitleLabel() {
        titleLabel.font = .getFont(.medium, size: 16)
        titleLabel.textColor = Colors.primaryText
        titleLabel.text = Constants.InformationView.madeBy
        titleLabel.backgroundColor = .clear
        headerView.addSubview(titleLabel)
    }

    func setupDescriptionLabel() {
        descriptionLabel.font = .getFont(.regular, size: 14)
        descriptionLabel.textColor = Colors.primaryText
        descriptionLabel.text = Constants.InformationView.appDevDescription
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.textAlignment = .center
        headerView.addSubview(descriptionLabel)
    }

    func setupHeaderViewConstraints() {
        hiddenLabel.snp.makeConstraints { make in
            make.center.equalTo(tcatImage)
            make.size.equalTo(hiddenLabel.intrinsicContentSize)
        }

        tcatImage.snp.makeConstraints { make in
            make.top.equalTo(headerView).offset(tcatImageTopOffset)
            make.size.equalTo(tcatImageSize)
            make.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(tcatImage.snp.bottom).offset(titleLabelTopOffset)
            make.centerX.equalToSuperview()
            make.size.equalTo(titleLabelSize)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(descriptionLabelTopOffset)
            make.size.equalTo(descriptionLabelSize)
            make.centerX.equalToSuperview()
        }
    }

    func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
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

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Swift.Error?) {
        controller.dismiss(animated: true)
        if let error = error {
            print("Mail Error:", error)
        }
    }

    /// Retrieve
    func retrieveLogs() -> Data? {
        if let fileURL = JSONFileManager.shared.getZipURL() {
            return try? Data(contentsOf: fileURL)
        }
        return nil
    }

    /// Message body of HTML email message
    func createMessageBody(didRetrieveLog: Bool) -> String {

        var html = ""
        html += "<!DOCTYPE html>"
        html += "<html>"
        html += "<body>"

        html += "<h2>Ithaca Transit Feedback Form</h2>"

        html += "<b>General Feedback</b>"
        html += "<br><br><br><br>"

        html += "</body>"
        html += "</html>"

        return html

    }

    @objc func showMoreApps() {
        let appStorePage = "https://itunes.apple.com/us/developer/walker-white/id1089672961"
        open(appStorePage, inApp: false)
    }

    @objc func openTeamWebsite() {
        let homePage = "http://www.cornellappdev.com"
        open(homePage)
    }

    @objc func showServiceAlerts() {
        let serviceAlertsVC = ServiceAlertsViewController()
        navigationController?.pushViewController(serviceAlertsVC, animated: true)
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
        let options: UIView.AnimationOptions = .curveEaseInOut

        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping,
                       initialSpringVelocity: velocity, options: options, animations: {

                        self.tcatImage.frame.origin.x += constant

        }, completion: { (_) in

            self.tcatImage.frame.origin.x -= 2 * constant

            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping,
                           initialSpringVelocity: velocity, options: options, animations: {

                            self.tcatImage.frame.origin.x += constant

            }, completion: { (_) in

                let title = Constants.Alerts.MagicBus.title
                let message = Constants.Alerts.MagicBus.message
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: Constants.Alerts.MagicBus.action, style: .default, handler: nil))
                self.present(alertController, animated: true)

            })

        })

        let payload = BusTappedEventPayload()
        Analytics.shared.log(payload)

    }

}

// MARK: Table View Data Source
extension InformationViewController: UITableViewDataSource {
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
        cell.backgroundColor = Colors.white
        cell.textLabel?.textColor = Colors.primaryText
        cell.textLabel?.font = .getFont(.regular, size: 14)
        cell.textLabel?.textAlignment = .center

        // Set cell content
        cell.textLabel?.text = content[indexPath.section][indexPath.row].name

        // Set custom formatting based on cell
        switch (indexPath.section, indexPath.row) {

        case (1, 1): // Send Feedback
            cell.textLabel?.textColor = Colors.tcatBlue
        default:
            break

        }

        return cell

    }
}

// MARK: Table View Delegate
extension InformationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selector = content[indexPath.section][indexPath.row].action
        performSelector(onMainThread: selector, with: nil, waitUntilDone: false)
    }
}

extension InformationViewController: MFMailComposeViewControllerDelegate {
    @objc func sendFeedback() {

        let emailAddress = Constants.App.contactEmailAddress

        if MFMailComposeViewController.canSendMail() {

            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            var didRetrieveLog = false

            if let logs = retrieveLogs() {
                mailComposerVC.addAttachmentData(logs, mimeType: "application/zip", fileName: "Logs.zip")
                didRetrieveLog = true
                JSONFileManager.shared.deleteZip()
            }

            let subject = "Ithaca Transit Feedback v\(Constants.App.version)"
            let body = createMessageBody(didRetrieveLog: didRetrieveLog)

            mailComposerVC.setToRecipients([emailAddress])
            mailComposerVC.setSubject(subject)
            mailComposerVC.setMessageBody(body, isHTML: true)

            present(mailComposerVC, animated: true)

        } else {

            let title = Constants.Alerts.EmailFailure.title
            let message = Constants.Alerts.EmailFailure.message
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Constants.Alerts.EmailFailure.emailSettings, style: .default, handler: { (_) in
                let path = "App-Prefs:"
                if let url = URL(string: path), UIApplication.shared.canOpenURL(url) {
                    self.open(path, inApp: false)
                } else {
                    self.open(UIApplication.openSettingsURLString)
                }
                let payload = FeedbackErrorPayload(description: "Opened Email Settings")
                Analytics.shared.log(payload)
            }))
            alertController.addAction(UIAlertAction(title: Constants.Alerts.EmailFailure.copyEmail, style: .default, handler: { (_) in
                UIPasteboard.general.string = Constants.App.contactEmailAddress
                let payload = FeedbackErrorPayload(description: "Copy Address to Clipboard")
                Analytics.shared.log(payload)
            }))
            alertController.addAction(UIAlertAction(title: Constants.Alerts.EmailFailure.cancel, style: .default, handler: { (_) in
                let payload = FeedbackErrorPayload(description: "Cancelled")
                Analytics.shared.log(payload)
            }))
            present(alertController, animated: true)

        }

    }
}
