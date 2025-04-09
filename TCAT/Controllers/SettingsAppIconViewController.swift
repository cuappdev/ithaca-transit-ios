//
//  SettingsAppIconViewController.swift
//  TCAT
//
//  Created by Asen Ou on 3/10/25.
//  Copyright © 2025 Cornell AppDev. All rights reserved.
//

import SnapKit
import UIKit

struct AppIcon {
    let name: String
    let icon: UIImage?
    var selected: Bool = false
}

class SettingsAppIconViewController: UIViewController {

    // MARK: - Properties (data)
    private let icons: [AppIcon] = [
        // icons go here
        AppIcon(name: "Default", icon: UIImage(named: "AppIcon-Icon-App-20x20@2x"))
    ]

    // MARK: - Properties (view)
    private let collView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationItem()
        setupUI()
        setupConstraints()
    }

    // MARK: - Nav item setup
    private func setUpNavigationItem() {
        let rightBarButton = UIBarButtonItem()
        navigationController?.navigationItem.rightBarButtonItem = rightBarButton
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Configure view
        view.backgroundColor = .white
        title = "App Icons"

        setUpIconsCollectionView()
        view.addSubview(collView)
    }

    private func setUpIconsCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collView.setCollectionViewLayout(layout, animated: true)
        collView.register(SettingsAppIconCollectionViewCell.self, forCellWithReuseIdentifier: SettingsAppIconCollectionViewCell.reuse)
        collView.dataSource = self
        collView.delegate = self
        collView.showsVerticalScrollIndicator = false
        collView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

//        let layout = UICollectionViewFlowLayout()
//        collView.collectionViewLayout = layout
//        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 15
//        
//        collView.register(SettingsAppIconCollectionViewCell.self, forCellWithReuseIdentifier: SettingsAppIconCollectionViewCell.reuse)
//        collView.delegate = self
//        collView.dataSource = self
    }

    // MARK: - Constraints
    private func setupConstraints() {
        collView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension SettingsAppIconViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsAppIconCollectionViewCell.reuse,
            for: indexPath
        ) as? SettingsAppIconCollectionViewCell else { return UICollectionViewCell() }

        let appIcon = icons[indexPath.row]
        cell.configure(image: appIcon.icon, isSelected: appIcon.selected)

        return cell
    }

}
