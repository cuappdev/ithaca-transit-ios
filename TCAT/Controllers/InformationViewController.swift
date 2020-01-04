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
    private let tableView = UITableView(frame: .zero, style: .grouped)

    override func viewDidLoad() {
        super.viewDidLoad()

        let payload = AboutPageOpenedPayload()
        Analytics.shared.log(payload)

        title = Constants.Titles.aboutUs

        view.backgroundColor = Colors.backgroundWash
        navigationController?.navigationBar.tintColor = Colors.primaryText

        setupDismissButton()
        setupTableView()

        setupConstraints()
    }

    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cells.informationCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Colors.backgroundWash
        tableView.separatorColor = Colors.dividerTextField
        tableView.showsVerticalScrollIndicator = false
        let headerView = InformationTableHeaderView()
        headerView.delegate = self
        tableView.tableHeaderView = headerView

        view.addSubview(tableView)
    }

    private func setupDismissButton() {
        let dismissButton = UIButton(type: .system)
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        dismissButton.setTitle(Constants.Buttons.done, for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            CustomNavigationController.buttonTitleTextAttributes, for: .normal
        )
        let backButtonItem = UIBarButtonItem(customView: dismissButton)
        navigationItem.setRightBarButton(backButtonItem, animated: false)
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Functions

    @objc private func dismissTapped() {
        dismiss(animated: true)
    }

    // MARK: - Cell Actions

    @objc private func presentOnboarding() {
        let onboardingViewController = OnboardingViewController(initialViewing: false)
        let navigationController = OnboardingNavigationController(rootViewController: onboardingViewController)
        present(navigationController, animated: true)
    }

    /// Message body of HTML email message
    private func createMessageBody() -> String {
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

    @objc private func showMoreApps() {
        let appStorePage = "https://itunes.apple.com/us/developer/walker-white/id1089672961"
        open(appStorePage, inApp: false)
    }

    @objc private func openTeamWebsite() {
        let homePage = "http://www.cornellappdev.com"
        open(homePage)
    }

    @objc private func showServiceAlerts() {
        let serviceAlertsVC = ServiceAlertsViewController()
        navigationController?.pushViewController(serviceAlertsVC, animated: true)
    }

    @objc private func sendFeedback() {
        let emailAddress = Constants.App.contactEmailAddress
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self

            let subject = "Ithaca Transit Feedback v\(Constants.App.version)"
            let body = createMessageBody()

            mailComposerVC.setToRecipients([emailAddress])
            mailComposerVC.setSubject(subject)
            mailComposerVC.setMessageBody(body, isHTML: true)

            present(mailComposerVC, animated: true)
        } else {
            let title = Constants.Alerts.EmailFailure.title
            let message = Constants.Alerts.EmailFailure.message
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Constants.Alerts.EmailFailure.emailSettings, style: .default, handler: { _ in
                let path = "App-Prefs:"
                if let url = URL(string: path), UIApplication.shared.canOpenURL(url) {
                    self.open(path, inApp: false)
                } else {
                    self.open(UIApplication.openSettingsURLString)
                }
                let payload = FeedbackErrorPayload(description: "Opened Email Settings")
                Analytics.shared.log(payload)
            }))
            alertController.addAction(UIAlertAction(title: Constants.Alerts.EmailFailure.copyEmail, style: .default, handler: { _ in
                UIPasteboard.general.string = Constants.App.contactEmailAddress
                let payload = FeedbackErrorPayload(description: "Copy Address to Clipboard")
                Analytics.shared.log(payload)
            }))
            alertController.addAction(UIAlertAction(title: Constants.Alerts.EmailFailure.cancel, style: .default, handler: { _ in
                let payload = FeedbackErrorPayload(description: "Cancelled")
                Analytics.shared.log(payload)
            }))
            present(alertController, animated: true)
        }
    }

    private func open(_ url: String, inApp: Bool = true) {
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

}

// MARK: - Table View Data Source
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
        if indexPath.section == 1 && indexPath.row == 1 {
            cell.textLabel?.textColor = Colors.tcatBlue
        }

        return cell
    }

}

// MARK: - Table View Delegate
extension InformationViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selector = content[indexPath.section][indexPath.row].action
        performSelector(onMainThread: selector, with: nil, waitUntilDone: false)
    }

}

extension InformationViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Swift.Error?) {
        controller.dismiss(animated: true)
        if let error = error {
            printClass(context: "Mail error", message: error.localizedDescription)
        }
    }
}

extension InformationViewController: InfoHeaderViewDelegate {

    func showFunMessage() {
        let title = Constants.Alerts.MagicBus.title
        let message = Constants.Alerts.MagicBus.message
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Constants.Alerts.MagicBus.action, style: .default, handler: nil))
        present(alertController, animated: true)
    }

}
