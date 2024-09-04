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

    // MARK: ~ View vars
    private let collapsedRevealHeight: CGFloat = 54
    private let partialRevealHeight: CGFloat = 400

    // MARK: ~ View vars
    private var ecoFacilityCollectionView: UICollectionView!
    private var ecoFilterCollectionView: UICollectionView!
    private let titleLabel = UILabel()
    private let tabView = UIView()
    private let tabSize = CGSize(width: 32, height: 4)

    private let shownCells: [Facility] = [.eatery(DummyData.Betha), .eatery(DummyData.Okenshields)]
    private let allEateries: [Eatery] = []
    private let allGyms: [Gym] = []
    private let filterColors = [UIColor(hex: "D82D4D"), UIColor(hex: "E79C20"), UIColor(hex: "079DDC")]
    private let filterSymbols = ["FavoriteFilter", "dumbbell", "EateryLogo"]
    private let filterNames = ["Favorites", "Gyms", "Eateries"]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        setupLabels()
        setupFacilityCollectionView()
        setupFilterCollectionView()
        setupConstraints()
        ecoFacilityCollectionView.reloadData()
    }

    private func setupLabels() {
        titleLabel.text = "Near You"
        titleLabel.textColor = .black
        titleLabel.font = .getFont(.medium, size: 24)
        view.addSubview(titleLabel)
    }

    private func setupFacilityCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16

        ecoFacilityCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        ecoFacilityCollectionView.register(EateryCollectionViewCell.self, forCellWithReuseIdentifier: EateryCollectionViewCell.reuse)
        //        ecoCollectionView.register(FeedPostCollectionViewCell.self, forCellWithReuseIdentifier: FeedPostCollectionViewCell.reuse)
        ecoFacilityCollectionView.delegate = self
        ecoFacilityCollectionView.dataSource = self
        ecoFacilityCollectionView.showsVerticalScrollIndicator = false
        ecoFacilityCollectionView.translatesAutoresizingMaskIntoConstraints = false
        ecoFacilityCollectionView.backgroundColor = .clear
        view.addSubview(ecoFacilityCollectionView)
    }

    private func setupFilterCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 24
        layout.minimumInteritemSpacing = 24

        ecoFilterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        ecoFilterCollectionView.register(EcoFilterCollectionViewCell.self, forCellWithReuseIdentifier: EcoFilterCollectionViewCell.reuse)
        ecoFilterCollectionView.delegate = self
        ecoFilterCollectionView.dataSource = self
        ecoFilterCollectionView.showsHorizontalScrollIndicator = false
        ecoFilterCollectionView.translatesAutoresizingMaskIntoConstraints = false
        ecoFilterCollectionView.backgroundColor = .clear
        view.addSubview(ecoFilterCollectionView)
    }

    private func setupConstraints() {

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalToSuperview().inset(20)
        }

        ecoFacilityCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.trailing.equalToSuperview().inset(24)
            make.top.equalToSuperview().offset(172)
            make.bottom.equalToSuperview()
        }

        ecoFilterCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.trailing.equalToSuperview().inset(24)
            make.top.equalToSuperview().offset(64)
            make.bottom.equalTo(ecoFacilityCollectionView.snp.top)
        }

    }

}

extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == ecoFacilityCollectionView {
            return shownCells.count
        } else {
            return filterNames.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == ecoFacilityCollectionView {
            switch shownCells[indexPath.row] {
            case .eatery(let eatery):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EateryCollectionViewCell.reuse, for: indexPath) as? EateryCollectionViewCell else { return UICollectionViewCell() }

                cell.configure(eatery: eatery)
                return cell
            case .gym(let gym):
                //            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EateryCollectionViewCell.reuse, for: indexPath) as? EateryCollectionViewCell else { return UICollectionViewCell() }
                //
                //            cell.configure(eatery: eatery)
                //            return cell
                return UICollectionViewCell()
            }
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EcoFilterCollectionViewCell.reuse, for: indexPath) as? EcoFilterCollectionViewCell else { return UICollectionViewCell() }

            cell.configure(filterColor: filterColors[indexPath.row], filtername: filterNames[indexPath.row], filterSymbol: filterSymbols[indexPath.row])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == ecoFacilityCollectionView {
            return CGSize(width: 344, height: 200)
        } else {
            return CGSize(width: 64, height: 92)
        }
    }

}

extension FavoritesViewController: PulleyDrawerViewControllerDelegate {

    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return bottomSafeArea + partialRevealHeight
    }

    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return bottomSafeArea + collapsedRevealHeight
    }

    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.collapsed, .partiallyRevealed]
    }

    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        let totalHeight = partialRevealHeight - collapsedRevealHeight
        let collapsedHeight = collapsedRevealHeight + bottomSafeArea
        let opacity = (distance - collapsedHeight) / totalHeight
        ecoFacilityCollectionView.alpha = opacity
    }

}
