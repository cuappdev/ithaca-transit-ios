//
//  SettingsFaveViewController.swift
//  TCAT
//
//  Created by Asen Ou on 3/12/25.
//  Copyright © 2025 Cornell AppDev. All rights reserved.
//

import SnapKit
import UIKit

class SettingsFaveViewController: UIViewController {

    // MARK: - Properties
    private let centerLabel = UILabel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Configure view
        view.backgroundColor = .white
        title = "Favorites"

        // Configure label
        centerLabel.text = "PLACEHOLDER"
        centerLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        centerLabel.textColor = .black
        centerLabel.textAlignment = .center

        // Add subviews
        view.addSubview(centerLabel)
    }

    // MARK: - Constraints
    private func setupConstraints() {
        centerLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

}
