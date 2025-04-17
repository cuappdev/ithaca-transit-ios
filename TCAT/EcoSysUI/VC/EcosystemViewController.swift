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
    let color: UIColor
}

enum CardType {
    case normal
    case favorite
}

class EcosystemViewController: UIViewController {

    // MARK: - Properties (views)
    private let tabView = UIView()
    private let titleLabel = UILabel()
    private var filterCollView: UICollectionView!
    private let customSeparator = UIImageView()
    private let cardsTableView = UITableView()

    // MARK: - Properties (data)
    private let tabSize = CGSize(width: 32, height: 4)
    private let separatorSize = CGSize(width: 32, height: 4)
    private var currentTab = "Favorites"
    private let balls: [Ball] = [
        Ball(
            name: "Favorites",
            image: UIImage(named: "Favorites") ?? UIImage(),
            color: Colors.faveRed
        ),
        Ball(
            name: "Gyms",
            image: UIImage(named: "dumbbell") ?? UIImage(),
            color: Colors.upliftYellow
        ),
        Ball(
            name: "Eateries",
            image: UIImage(named: "Eatery") ?? UIImage(),
            color: Colors.eateryBlue
        ),
        Ball(
            name: "Libraries",
            image: UIImage(named: "Library") ?? UIImage(),
            color: Colors.libraryGreen
        ),
        Ball(
            name: "Printers",
            image: UIImage(named: "Printer") ?? UIImage(),
            color: Colors.printerGrey
        )
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
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 50

        filterCollView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        filterCollView.register(EcosystemFilterBallCollectionViewCell.self, forCellWithReuseIdentifier: EcosystemFilterBallCollectionViewCell.reuse)
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
            make.top.equalToSuperview().offset(5)
            make.size.equalTo(tabSize)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(titleLabelInset)
            make.left.equalToSuperview().offset(titleLabelInset)
            make.right.equalToSuperview()
            make.height.equalTo(20)
        }

        filterCollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(92)
        }

        customSeparator.snp.makeConstraints { make in
            make.top.equalTo(filterCollView.snp.bottom).offset(separatorPadding)
            make.left.right.equalToSuperview()
            make.size.equalTo(separatorSize)
        }

        cardsTableView.snp.makeConstraints { make in
            make.top.equalTo(customSeparator.snp.bottom).offset(separatorPadding)
            make.left.right.bottom.equalToSuperview()
        }
    }

}

// MARK: - Collection View Delegate
extension EcosystemViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return balls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EcosystemFilterBallCollectionViewCell.reuse, for: indexPath) as? EcosystemFilterBallCollectionViewCell else { return UICollectionViewCell() }

        let ballData = balls[indexPath.row]
        cell.configure(
            name: ballData.name,
            icon: ballData.image,
            color: ballData.color
        )
        return cell
    }
}

// MARK: - Table View Delegate
extension EcosystemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
