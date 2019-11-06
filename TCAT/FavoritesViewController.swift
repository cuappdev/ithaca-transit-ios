//
//  FavoritesViewController.swift
//  TCAT
//
//  Created by Lucy Xu on 11/4/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import Pulley
import UIKit

class FavoritesViewController: UIViewController {

    // MARK: - View vars

    private var editButton: UIButton!
    private let favoritesBlueColor = UIColor(hex: "08A0E0")
    private var favoritesCollectionView: UICollectionView!
    private var favoritesTitleLabel: UILabel!
    private let tab = UIView()
    private let tabSize = CGSize(width: 32, height: 4)

    // MARK: - Data vars
    private let editTitle = "Edit"
    private let favoritesTitle = "Favorites"
    private let favoritesReuseIdentifier = "FavoritesCollectionViewCell"
    // Temporary Favorites Array
    private var favorites: [String] = ["Collegetown Bagels", "Collegetown Bagels", "Collegetown Bagels", "Collegetown Bagels"]

    override func viewDidLoad() {

        super.viewDidLoad()
        setupLabels()
        setupFavoritesCollectionView()
        setupTab()
        setupConstraints()

    }

    private func setupLabels() {
        favoritesTitleLabel = UILabel()
        favoritesTitleLabel.text = favoritesTitle
        favoritesTitleLabel.textColor = .black
        favoritesTitleLabel.font = .getFont(.medium, size: 24)
        view.addSubview(favoritesTitleLabel)

        editButton = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.getFont(.regular, size: 14.0),
            .foregroundColor: favoritesBlueColor,
        ]
        let attributedString = NSMutableAttributedString(string: editTitle, attributes: attributes)
        editButton.setAttributedTitle(attributedString, for: .normal)
        view.addSubview(editButton)
    }

    private func setupFavoritesCollectionView() {
        let favoritesFlowLayout = UICollectionViewFlowLayout()
        favoritesFlowLayout.minimumLineSpacing = 12.0
        favoritesFlowLayout.minimumInteritemSpacing = 4.0

        favoritesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: favoritesFlowLayout)
        favoritesCollectionView.delegate = self
        favoritesCollectionView.dataSource = self
        favoritesCollectionView.register(FavoritesCollectionViewCell.self, forCellWithReuseIdentifier: favoritesReuseIdentifier)
        favoritesCollectionView.backgroundColor = .clear
        view.addSubview(favoritesCollectionView)
    }

    func setupTab() {
        tab.backgroundColor = Colors.metadataIcon
        tab.layer.cornerRadius = tabSize.height / 2
        tab.clipsToBounds = true
        view.addSubview(tab)
    }

    private func setupConstraints() {

        let tabTopInset: CGFloat = 6
        let horizontalPadding = 16
        let titleBarTopPadding = 21
        let favoritesTopPadding = 24
        let bottomPadding = 18


        favoritesTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(horizontalPadding)
            make.top.equalToSuperview().inset(titleBarTopPadding)
        }

        editButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(horizontalPadding)
            make.top.equalToSuperview().inset(titleBarTopPadding)
        }

        favoritesCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(horizontalPadding)
            make.trailing.equalToSuperview().inset(horizontalPadding).priority(.high)
            make.top.equalTo(favoritesTitleLabel.snp.bottom).offset(favoritesTopPadding)
            make.bottom.equalToSuperview().offset(-bottomPadding).priority(.high)
        }

        tab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(tabTopInset)
            make.size.equalTo(tabSize)
        }


    }

}

extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == favoritesCollectionView {
            return favorites.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == favoritesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: favoritesReuseIdentifier, for: indexPath) as! FavoritesCollectionViewCell
            cell.configure(for: favorites[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }

}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 95)
    }
}

extension FavoritesViewController: PulleyDrawerViewControllerDelegate {

    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 200
    }

    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.collapsed, .partiallyRevealed]
    }

}
