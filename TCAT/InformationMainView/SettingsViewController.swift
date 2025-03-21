//
//  SettingsViewController.swift
//  TCAT
//
//  Created by Asen Ou on 3/4/25.
//  Copyright © 2025 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit

enum NavigationAction {
    case push(UIViewController)
    case present(UIViewController, [UISheetPresentationController.Detent])
}

struct RowItem {
    let image: UIImage?
    let title: String
    let subtitle: String
    let navAction: NavigationAction
}

class SettingsViewController: UIViewController {
    // MARK: - Main View Properties
    private let tableView = UITableView()

    // MARK: - Table View Properties
    private var rows: [RowItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Track Analytics
        let payload = AboutPageOpenedPayload()
        TransitAnalytics.shared.log(payload)

        // Populate row items
        setUpRowItems()

        // Set up UI
        setUpUI()

        // Set up constraints
        setUpConstraints()
    }

    private func setUpRowItems() {
        rows = [
            RowItem(
                image: UIImage(named: "appDevLogo"),
                title: "About Transit",
                subtitle: "Learn more about the team behind the app",
                navAction: .push(SettingsAboutViewController())
            ),
            RowItem(
                image: UIImage(named: "lightBulb"),
                title: "Show Onboarding",
                subtitle: "Need a refresher? See how to use the app",
                navAction: .present(OnboardingViewController(initialViewing: false), [.large()])
            ),
//            RowItem(
//                image: UIImage(named: "favStar"),
//                title: "Favorites",
//                subtitle: "Manage your favorite stops",
//                navAction: .push(SettingsFaveViewController())
//            ),
            RowItem(
                image: UIImage(named: "settingsBus"),
                title: "App Icon",
                subtitle: "Choose your adventure",
                navAction: .present(SettingsAppIconViewController(), [.medium()])
            ),
            RowItem(
                image: UIImage(named: "lock"),
                title: "Notifications & Privacy",
                subtitle: "Manage permissions and analytics",
                navAction: .push(SettingsPrivacyViewController())
            ),
            RowItem(
                image: UIImage(named: "qMark"),
                title: "Support",
                subtitle: "Report issues and contact Cornell AppDev",
                navAction: .push(SettingsSupportViewController())
            ),
            RowItem(
                image: UIImage(named: "settingsBus"),
                title: "TCAT Service Alerts",
                subtitle: "Find service alerts about routes",
                navAction: .push(ServiceAlertsViewController())
            )
        ]
    }

    // MARK: - UI Set Up
    private func setUpUI() {
        // Set up main view & nav
        setUpMainView()
        setUpNavigationItem()

        // Set up subviews
        setUpTableView()
        view.addSubview(tableView)
    }

    // MARK: - Main View Set Up
    private func setUpMainView() {
        // Initialize view defaults
        title = "Settings"
        view.backgroundColor = Colors.white
    }

    // MARK: - Navigation Item Set Up
    private func setUpNavigationItem() {
        let backButton = UIBarButtonItem(
            image: UIImage(named: "back"),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton

        // a very complicated way of making the nav bar large title blue
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [
            .foregroundColor: Colors.tcatBlue as Any
        ]

        let scrollEdgeAppearance = appearance.copy()
        scrollEdgeAppearance.configureWithTransparentBackground()
        navigationItem.scrollEdgeAppearance = scrollEdgeAppearance

        navigationController?.navigationBar.scrollEdgeAppearance?.shadowColor = .clear
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: - TableView Set Up
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate, InfoHeaderViewDelegate {
    private func setUpTableView() {
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.reuse)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Colors.white
        tableView.separatorColor = Colors.dividerTextField
        tableView.showsVerticalScrollIndicator = false

        tableView.separatorStyle = .none

        let headerView = InformationTableHeaderView()
        headerView.delegate = self
        tableView.tableFooterView = headerView
    }

    // function for InfoHeaderViewDelegate
    func showFunMessage() {
        let title = Constants.Alerts.MagicBus.title
        let message = Constants.Alerts.MagicBus.message
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Constants.Alerts.MagicBus.action, style: .default, handler: nil))
        present(alertController, animated: true)
    }

    private func handleNavigation(action: NavigationAction) {
        switch action {
        case .push(let viewController):
            navigationController?.pushViewController(viewController, animated: true)
        case .present(let viewController, let detents):
            let nav = UINavigationController(rootViewController: viewController)
            nav.modalPresentationStyle = .pageSheet
            nav.navigationBar.prefersLargeTitles = true

            if let sheet = nav.sheetPresentationController {
                sheet.detents = detents
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }

            present(nav, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let rowItem = rows[indexPath.row]
        handleNavigation(action: rowItem.navAction)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsTableViewCell.reuse,
            for: indexPath
        ) as? SettingsTableViewCell else { return UITableViewCell() }

        let rowItem = rows[indexPath.row]
        cell.configure(
            image: rowItem.image,
            title: rowItem.title,
            subtitle: rowItem.subtitle
        )

        if indexPath.row < (rows.count - 1) {
            cell.addSeparator(width: 360)
        }

        return cell
    }

    // MARK: - Constraints Set Up
    private func setUpConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Back button interaction
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}
