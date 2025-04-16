//
//  EcosystemViewController.swift
//  TCAT
//
//  Created by Asen Ou on 4/9/25.
//  Copyright © 2025 Cornell AppDev. All rights reserved.
//

import Pulley
import SnapKit
import UIKit

struct Ball {
    let name: String
    let image: UIImage
}

enum CardType {
    case normal
    case favorite
}

class EcosystemViewController: UIViewController {

    // MARK: - Properties (views)
    private let tabView = UIView()
    private let titleLabel = UILabel()
    private let filterCollView = UICollectionView()
    private let customSeparator = UIImageView()
    private let cardsTableView = UITableView()

    // MARK: - Properties (data)
    private let tabSize = CGSize(width: 32, height: 4)
    private let separatorSize = CGSize(width: 32, height: 4)
    private var currentTab = "Favorites"
    private let balls: [Ball] = [
        Ball(name: "Favorites", image: UIImage()),
        Ball(name: "Gyms", image: UIImage()),
        Ball(name: "Eateries", image: UIImage()),
        Ball(name: "Libraries", image: UIImage()),
        Ball(name: "Printers", image: UIImage())
    ]
    private let allCardModels: [Any] = []

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
        
        // Fetch cards

        // Add subviews
        setupTabView()
        view.addSubview(tabView)

        setupTitleLabel()
        view.addSubview(titleLabel)
        
        setupFilterBalls()
        view.addSubview(filterCollView)
        
        setupCustomSeparator()
        view.addSubview(customSeparator)
        
        setupCards()
        view.addSubview(cardsTableView)
    }

    private func setupTabView() {
        tabView.backgroundColor = Colors.metadataIcon
        tabView.layer.cornerRadius = tabSize.height / 2
        tabView.clipsToBounds = true
    }

    private func setupTitleLabel() {
        titleLabel.text = "Near You"
        titleLabel.textColor = .lightGray
        titleLabel.font = .preferredFont(forTextStyle: .title1)
    }

    private func setupFilterBalls() {
        filterCollView.delegate = self
        filterCollView.dataSource = self
    }
    
    private func setupCustomSeparator() {
    }
    
    private func setupCards() {
        cardsTableView.delegate = self
        cardsTableView.dataSource = self
    }

    // MARK: - Constraints
    private func setupConstraints() {
        // constants
        let titleLabelInset = 25
        let separatorPadding = 20

        tabView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(5)
            make.size.equalTo(tabSize)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(titleLabelInset)
            make.left.equalToSuperview().inset(titleLabelInset)
            make.right.equalToSuperview()
            make.height.equalTo(20)
        }

        filterCollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(390)
        }

        customSeparator.snp.makeConstraints { make in
            make.top.equalTo(filterCollView.snp.bottom).inset(separatorPadding)
            make.left.right.equalToSuperview()
            make.size.equalTo(separatorSize)
        }

        cardsTableView.snp.makeConstraints { make in
            make.top.equalTo(customSeparator.snp.bottom).inset(separatorPadding)
            make.left.right.bottom.equalToSuperview()
        }
    }

}

extension EcosystemViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

extension EcosystemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
