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


    let favoritesTitle = "Favorites"
    let editTitle = "Edit"
    let favoritesReuseIdentifier = "FavoritesCollectionViewCell"

    var favorites: [String] = ["Collegetown Bagels", "Collegetown Bagels"]

    var favoritesCollectionView: UICollectionView!
    var favoritesTitleLabel: UILabel!
    var editButton: UIButton!

    override func viewDidLoad() {

        super.viewDidLoad()

        favoritesTitleLabel = UILabel()
        favoritesTitleLabel.text = favoritesTitle
        favoritesTitleLabel.textColor = .black
        favoritesTitleLabel.font = .getFont(.medium, size: 24)
        view.addSubview(favoritesTitleLabel)

        editButton = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.getFont(.regular, size: 14.0),
            .foregroundColor: Colors.tcatBlue,
        ]
        let attributedString = NSMutableAttributedString(string: editTitle, attributes: attributes)
        editButton.setAttributedTitle(attributedString, for: .normal)
        view.addSubview(editButton)

        let favoritesFlowLayout = UICollectionViewFlowLayout()
        favoritesFlowLayout.minimumLineSpacing = 12.0
        favoritesFlowLayout.minimumInteritemSpacing = 4.0

        favoritesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: favoritesFlowLayout)
        favoritesCollectionView.delegate = self
        favoritesCollectionView.dataSource = self
        favoritesCollectionView.register(FavoritesCollectionViewCell.self, forCellWithReuseIdentifier: favoritesReuseIdentifier)
        favoritesCollectionView.showsHorizontalScrollIndicator = false
        favoritesCollectionView.backgroundColor = .clear
        view.addSubview(favoritesCollectionView)

        setupConstraints()

    }

    func setupConstraints() {
        favoritesTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(21)
        }

        editButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(21)
        }

        favoritesCollectionView.snp.makeConstraints { make in
            make.leading.equalTo(favoritesTitleLabel)
            make.trailing.equalTo(editButton)
            make.top.equalTo(favoritesTitleLabel.snp.bottom).offset(24)
            make.height.equalTo(120)
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
        return CGSize(width: 80, height: 120)
    }
}

extension FavoritesViewController: PulleyDrawerViewControllerDelegate {

//    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
//        return bottomSafeArea
//    }

    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 200
    }

    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.collapsed, .partiallyRevealed]
    }

}
