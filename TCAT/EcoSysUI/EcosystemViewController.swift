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

class EcosystemViewController: UIViewController {

    // MARK: - Properties (views)
    private let titleLabel = UILabel()
    private let tabView = UIView()
    private let filterCollView = UICollectionView()
    private let cardsTableView = UITableView()

    // MARK: - Properties (data)
    private let tabSize = CGSize(width: 32, height: 4)
    private let balls = []
    private let cards = []

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

        // Add subviews
        setupTabView()
        view.addSubview(tabView)

        setupTitleLabel()
        view.addSubview(titleLabel)
        
        setupFilterBalls()
        view.addSubview(filterCollView)
        
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
    
    private func setupCards() {
        cardsTableView.delegate = self
        cardsTableView.dataSource = self
    }

    // MARK: - Constraints
    private func setupConstraints() {
        let titleLabelInset = 25
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(titleLabelInset)
            make.left.equalToSuperview().inset(titleLabelInset)
            make.right.equalToSuperview()
            make.height.equalTo(20)
        }

        tabView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(5)
            make.size.equalTo(tabSize)
        }
    }

}

extension EcosystemViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    
}

extension EcosystemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}
