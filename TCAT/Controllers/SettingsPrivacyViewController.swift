//
//  SettingsPrivacyViewController.swift
//  TCAT
//
//  Created by Asen Ou on 3/12/25.
//  Copyright © 2025 Cornell AppDev. All rights reserved.
//
import Combine
import Foundation
import CoreLocation
import SwiftUI

class SettingsPrivacyViewController: UIViewController {

    private lazy var hostingController: UIHostingController<SettingsPrivacyView> = {
        let hostingController = UIHostingController(rootView: SettingsPrivacyView())
        return hostingController
    }()

    private var cancellables: Set<AnyCancellable> = []
    
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationItem()
        setUpView()
        setUpConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Track Analytics
        let payload = SettingsNotifPrivacyPageOpenedPayload()
        TransitAnalytics.shared.log(payload)

        updateView()
    }

    private func setUpNavigationItem() {
        navigationItem.title = "Notifications & Privacy"
    }

    private func setUpView() {
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        hostingController.rootView.viewModel.$isAnalyticsEnabled
            .dropFirst()
            .sink { isAnalyticsEnabled in
                UserDefaults.standard.set(isAnalyticsEnabled, forKey: Constants.UserDefaults.isAnalyticsEnabled)
            }
            .store(in: &cancellables)

        hostingController.rootView.viewModel.$isLocationAllowed
            .dropFirst()
            .sink { isLocationAllowed in
                UserDefaults.standard.set(isLocationAllowed, forKey: Constants.UserDefaults.isLocationAllowed)
            }
            .store(in: &cancellables)
    }

    private func setUpConstraints() {
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    private func updateView() {
        let isLocationAllowed: Bool
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationAllowed = true
        default:
            isLocationAllowed = false
        }
        hostingController.rootView.viewModel.isLocationAllowed = isLocationAllowed

        let isAnalyticsEnabled = UserDefaults.standard.bool(forKey: Constants.UserDefaults.isAnalyticsEnabled)
        hostingController.rootView.viewModel.isAnalyticsEnabled = isAnalyticsEnabled
    }

}
