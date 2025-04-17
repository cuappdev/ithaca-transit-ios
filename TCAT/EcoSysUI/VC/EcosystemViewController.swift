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
    private let customSeparator = UIView()
    private let cardsTableView = UITableView()

    // MARK: - Properties (data)
    private let systemGray = UIColor.systemGray
    private let tabSize = CGSize(width: 32, height: 4)
    private let separatorSize = CGSize(width: 0, height: 1)
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
    private let favorites: [Any] = []
    private let superviewPadding = 24
    private let separatorPadding = 20

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
        tabView.backgroundColor = systemGray
        tabView.layer.cornerRadius = tabSize.height / 2
        tabView.clipsToBounds = true
    }

    private func setupTitleLabel() {
        titleLabel.text = "Near You"
        titleLabel.textColor = systemGray
        titleLabel.font = .preferredFont(forTextStyle: .headline)
    }

    private func setupFilterBalls() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 27
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat(superviewPadding))
        layout.estimatedItemSize = CGSize(width: 64, height: 92)

        filterCollView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        filterCollView.register(EcosystemFilterBallCollectionViewCell.self,
            forCellWithReuseIdentifier: EcosystemFilterBallCollectionViewCell.reuse)
        filterCollView.delegate = self
        filterCollView.dataSource = self
        filterCollView.showsHorizontalScrollIndicator = false
    }

    private func setupCustomSeparator() {
        customSeparator.backgroundColor = systemGray
        customSeparator.layer.cornerRadius = separatorSize.height / 2
        customSeparator.clipsToBounds = true
    }

    private func setupCards() {
        cardsTableView.delegate = self
        cardsTableView.dataSource = self
        cardsTableView.contentInset = UIEdgeInsets(top: -32, left: 0, bottom: 0, right: 0)
    }

    // MARK: - Constraints
    private func setupConstraints() {
        tabView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.size.equalTo(tabSize)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(superviewPadding)
            make.left.equalToSuperview().offset(superviewPadding)
            make.right.equalToSuperview()
            make.height.equalTo(20)
        }

        filterCollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().inset(superviewPadding)
            make.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(92)
        }

        customSeparator.snp.makeConstraints { make in
            make.top.equalTo(filterCollView.snp.bottom).offset(separatorPadding)
            make.left.right.equalToSuperview().inset(superviewPadding)
            make.size.equalTo(separatorSize)
        }

        cardsTableView.snp.makeConstraints { make in
            make.top.equalTo(customSeparator.snp.bottom).offset(separatorPadding)
            make.left.right.bottom.equalToSuperview().inset(superviewPadding)
        }
    }
    // MARK: - Helpers
    private func reloadAllData() {
        filterCollView.reloadData()
        cardsTableView.reloadData()
    }
}

// MARK: - Collection View Delegate
extension EcosystemViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return balls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EcosystemFilterBallCollectionViewCell.reuse,
            for: indexPath
        ) as? EcosystemFilterBallCollectionViewCell else { return UICollectionViewCell() }

        let ballData = balls[indexPath.row]
        cell.configure(
            name: ballData.name,
            icon: ballData.image,
            color: ballData.color,
            isSelected: (ballData.name == currentTab)
        )

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ballData = balls[indexPath.row]
        currentTab = ballData.name
        reloadAllData()
    }
}

// MARK: - Table View Delegate
extension EcosystemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentTab {
        case "Favorites": return favorites.count
        case "Gyms": return 0
        case "Eateries": return 0
        case "Libraries": return 0
        case "Printers": return 0
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if favorites.count > 0 || currentTab != "Favorites" { return nil }

        let headerView = UITableViewHeaderFooterView()

        let titleLabel = UILabel()
        titleLabel.text = "No Favorites"
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)

        let description = UILabel()
        description.text = "Tap the star icon to add places you visit often."
        description.textAlignment = .center
        description.numberOfLines = -1
        headerView.addSubview(description)

//        headerView.snp.makeConstraints { make in
//            make.height.equalTo(100)
//        }

        titleLabel.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalTo(200)
        }

        description.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.width.equalTo(200)
            make.centerX.bottom.equalToSuperview()
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textAlignment = .center
        }
    }
}
