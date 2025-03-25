//
//  SettingsSupportViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/26/22.
//

import Combine
import SwiftUI
import UIKit

class SettingsSupportViewController: UIViewController {

    private lazy var hostingController: UIHostingController<SettingsSupportView> = {
        let hostingController = UIHostingController(rootView: SettingsSupportView())
        return hostingController
    }()

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Track Analytics
        let payload = SettingsSupportPageOpenedPayload()
        TransitAnalytics.shared.log(payload)

        setUpNavigationItem()
        setUpView()
        setUpConstraints()
    }

    private func setUpNavigationItem() {
        navigationItem.title = "Support"
    }

    private func setUpView() {
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }

    private func setUpConstraints() {
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}
