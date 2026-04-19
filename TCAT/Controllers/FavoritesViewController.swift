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
    private let collapsedRevealHeight: CGFloat = 54
    private let editButton = UIButton()
    private let requestHotspotButton = UIButton()
    private let testHotspotButton = UIButton()
    private let testFunSpotButton = UIButton()
    private var favoritesCollectionView: UICollectionView!
    private let favoritesTitleLabel = UILabel()
    private let partialRevealHeight: CGFloat = 192
    private let tabView = UIView()
    private let tabSize = CGSize(width: 32, height: 4)

    // MARK: - Data vars
    private let favoritesReuseIdentifier = "FavoritesCollectionViewCell"
    private let addFavoritesReuseIdentifier = "AddFavoritesCollectionViewCell"
    private var favoritePlaces: [Place] {
        didSet {
            editButton.isEnabled = !favoritePlaces.isEmpty
            favoritesCollectionView.reloadData()
        }
    }
    private var isEditingFavorites: Bool

    init(isEditing: Bool) {
        isEditingFavorites = isEditing
        favoritePlaces = Global.shared.retrievePlaces(for: Constants.UserDefaults.favorites)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupLabels()
        setupButtons()
        setupFavoritesCollectionView()
        setupTabView()
        setupConstraints()
    }

    private func setupLabels() {
        favoritesTitleLabel.text = "Favorites"
        favoritesTitleLabel.textColor = .black
        favoritesTitleLabel.font = .getFont(.medium, size: 24)
        view.addSubview(favoritesTitleLabel)
    }

    private func setupButtons() {
        let editString = isEditingFavorites ? "Done" : "Edit"
        editButton.setTitle(editString, for: .normal)
        editButton.setTitleColor(Colors.notificationBlue, for: .normal)
        editButton.setTitleColor(Colors.secondaryText, for: .disabled)
        editButton.titleLabel?.font = UIFont.getFont(.regular, size: 14.0)
        editButton.isEnabled = !favoritePlaces.isEmpty
        editButton.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        view.addSubview(editButton)

        requestHotspotButton.setTitle("Request a HotSpot", for: .normal)
        requestHotspotButton.setTitleColor(Colors.notificationBlue, for: .normal)
        requestHotspotButton.titleLabel?.font = UIFont.getFont(.regular, size: 14.0)
        requestHotspotButton.addTarget(self, action: #selector(requestHotspotAction), for: .touchUpInside)
        view.addSubview(requestHotspotButton)

        testHotspotButton.setTitle("Test Hotspot", for: .normal)
        testHotspotButton.setTitleColor(Colors.notificationBlue, for: .normal)
        testHotspotButton.titleLabel?.font = UIFont.getFont(.regular, size: 14.0)
        testHotspotButton.addTarget(self, action: #selector(testHotspotAction), for: .touchUpInside)
        view.addSubview(testHotspotButton)

        testFunSpotButton.setTitle("Test FunSpot", for: .normal)
        testFunSpotButton.setTitleColor(Colors.notificationBlue, for: .normal)
        testFunSpotButton.titleLabel?.font = UIFont.getFont(.regular, size: 14.0)
        testFunSpotButton.addTarget(self, action: #selector(testFunSpotAction), for: .touchUpInside)
        view.addSubview(testFunSpotButton)
    }

    private func setupFavoritesCollectionView() {
        let favoritesFlowLayout = UICollectionViewFlowLayout()
        favoritesFlowLayout.minimumLineSpacing = 12.0
        favoritesFlowLayout.minimumInteritemSpacing = 4.0

        favoritesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: favoritesFlowLayout)
        favoritesCollectionView.delegate = self
        favoritesCollectionView.dataSource = self
        favoritesCollectionView.register(
            FavoritesCollectionViewCell.self,
            forCellWithReuseIdentifier: favoritesReuseIdentifier
        )
        favoritesCollectionView.register(
            AddFavoritesCollectionViewCell.self,
            forCellWithReuseIdentifier: addFavoritesReuseIdentifier
        )
        favoritesCollectionView.backgroundColor = .clear
        view.addSubview(favoritesCollectionView)
    }

    private func setupTabView() {
        tabView.backgroundColor = Colors.metadataIcon
        tabView.layer.cornerRadius = tabSize.height / 2
        tabView.clipsToBounds = true
        view.addSubview(tabView)
    }

    private func setupConstraints() {
        let tabTopInset = 6
        let horizontalPadding = 16
        let titleBarTopPadding = 21
        let favoritesTopPadding = 24
        let favoritesBottomPadding = 18

        favoritesTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(horizontalPadding)
            make.top.equalToSuperview().inset(titleBarTopPadding)
        }

        editButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(horizontalPadding)
            make.top.equalToSuperview().inset(titleBarTopPadding)
        }

        requestHotspotButton.snp.makeConstraints { make in
            make.trailing.equalTo(editButton.snp.leading).offset(-12)
            make.top.equalToSuperview().inset(titleBarTopPadding)
        }

        testHotspotButton.snp.makeConstraints { make in
            make.trailing.equalTo(requestHotspotButton.snp.leading).offset(-12)
            make.top.equalToSuperview().inset(titleBarTopPadding)
        }

        testFunSpotButton.snp.makeConstraints { make in
            make.trailing.equalTo(testHotspotButton.snp.leading).offset(-12)
            make.top.equalToSuperview().inset(titleBarTopPadding)
        }

        favoritesCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(horizontalPadding)
            make.trailing.equalToSuperview().inset(horizontalPadding).priority(.high)
            make.top.equalTo(favoritesTitleLabel.snp.bottom).offset(favoritesTopPadding)
            make.bottom.equalToSuperview().offset(-favoritesBottomPadding).priority(.high)
        }

        tabView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(tabTopInset)
            make.size.equalTo(tabSize)
        }
    }

    private func updateFavorites(newFavoritePlaces: [Place]) {
        favoritePlaces = newFavoritePlaces
    }

    private func updateFavoritesView() {
        let newEditString = isEditingFavorites ? "Done" : "Edit"
        editButton.setTitle(newEditString, for: .normal)
        favoritesCollectionView.reloadData()
    }

    private func presentFavoritePicker() {
        // Current favorites is capped at 3
        if favoritePlaces.count < 3 {
            let favoritesTVC = FavoritesTableViewController()
            favoritesTVC.didAddFavorite = {
                let favorites = Global.shared.retrievePlaces(for: Constants.UserDefaults.favorites)
                self.updateFavorites(newFavoritePlaces: favorites)
            }
            let navController = CustomNavigationController(rootViewController: favoritesTVC)
            present(navController, animated: true, completion: nil)
        } else {
            let title = Constants.Alerts.MaxFavorites.title
            let message = Constants.Alerts.MaxFavorites.message
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let done = UIAlertAction(title: Constants.Alerts.MaxFavorites.action, style: .default)
            alertController.addAction(done)
            present(alertController, animated: true, completion: nil)
        }
    }

    @objc func editAction() {
        isEditingFavorites.toggle()
        updateFavoritesView()
    }

    @objc private func testHotspotAction() {
        guard let pulley = pulleyViewController else { return }

        let drawerView = pulley.drawerContentViewController.view
        let mapVC = pulley.primaryContentViewController as? HomeMapViewController

        UIView.animate(withDuration: 0.25) { drawerView?.alpha = 0 }
        mapVC?.setOptionsCardHidden(true)
        mapVC?.setMapBottomPadding(0, animated: true)

        let sampleHotspot = Hotspot(
            id: "sample-hotspot-1",
            title: "AppDev: Navi Tabling",
            location: "Duffield Atrium | 15 minute walk",
            tags: "Stickers, charms, and bracelets",
            startTime: Date(),
            endTime: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
            isActive: true,
            organizerMessage: "Come and join us for a charm bracelet making session with the team behind Navi.\n\nMore information on our instagram @navicornell",
            shortOrganizerMessage: "Come and join our tabling event! @navicornell",
            moreInfo: ""
        )
        let vc = HotspotDetailViewController(hotspot: sampleHotspot)
        vc.onDismiss = {
            UIView.animate(withDuration: 0.25) { drawerView?.alpha = 1 }
            mapVC?.setOptionsCardHidden(false)
            if let mapVC = mapVC {
                mapVC.setMapBottomPadding(mapVC.defaultMapBottomPadding, animated: true)
            }
        }

        pulley.addChild(vc)
        vc.view.frame = pulley.view.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pulley.view.addSubview(vc.view)
        vc.didMove(toParent: pulley)
    }

    @objc private func testFunSpotAction() {
        guard let pulley = pulleyViewController else { return }

        let drawerView = pulley.drawerContentViewController.view
        let mapVC = pulley.primaryContentViewController as? HomeMapViewController

        UIView.animate(withDuration: 0.25) { drawerView?.alpha = 0 }
        mapVC?.setOptionsCardHidden(true)
        mapVC?.setMapBottomPadding(0, animated: true)

        let sampleFunSpot = FunSpot(
            id: "sample-funspot-1",
            name: "Statler Hotel",
            address: "130 Statler Dr",
            distanceMiles: 0.3,
            category: .hotel,
            about: "The Statler Hotel at Cornell University is a AAA Four Diamond award-winning hotel that serves as both a luxury hotel and a working laboratory for Cornell's hospitality students.",
            quote: "Where hospitality meets education.",
            imageURL: nil,
            isFavorite: false
        )
        let vc = FunSpotCardViewController(funSpot: sampleFunSpot)
        vc.onDismiss = {
            UIView.animate(withDuration: 0.25) { drawerView?.alpha = 1 }
            mapVC?.setOptionsCardHidden(false)
            if let mapVC = mapVC {
                mapVC.setMapBottomPadding(mapVC.defaultMapBottomPadding, animated: true)
            }
        }

        pulley.addChild(vc)
        vc.view.frame = pulley.view.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pulley.view.addSubview(vc.view)
        vc.didMove(toParent: pulley)
    }

    @objc private func requestHotspotAction() {
        let requestVC = RequestHotspotViewController()
        let navController = CustomNavigationController(rootViewController: requestVC)
        present(navController, animated: true, completion: nil)
    }

}

extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isEditingFavorites ? favoritePlaces.count : favoritePlaces.count + 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.item < favoritePlaces.count {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: favoritesReuseIdentifier,
                for: indexPath
            ) as? FavoritesCollectionViewCell else { return UICollectionViewCell() }
            cell.configure(for: favoritePlaces[indexPath.row], isEditing: isEditingFavorites)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: addFavoritesReuseIdentifier,
                for: indexPath
            ) as? AddFavoritesCollectionViewCell else { return UICollectionViewCell() }
            return cell
         }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < favoritePlaces.count {
            let favorite = favoritePlaces[indexPath.row]
            if isEditingFavorites {
                favoritePlaces = Global.shared.deleteFavorite(favorite: favorite, allFavorites: favoritePlaces)
                if favoritePlaces.isEmpty {
                    editAction()
                } else {
                    updateFavorites(newFavoritePlaces: favoritePlaces)
                }
            } else {
                navigationController?.pushViewController(RouteOptionsViewController(searchTo: favorite), animated: true)
            }
        } else {
            presentFavoritePicker()
        }
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 80, height: 95)
    }
}

extension FavoritesViewController: PulleyDrawerViewControllerDelegate {

    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return bottomSafeArea + 192
    }

    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return bottomSafeArea + 54
    }

    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.collapsed, .partiallyRevealed]
    }

    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        let totalHeight = partialRevealHeight - collapsedRevealHeight
        let collapsedHeight = collapsedRevealHeight + bottomSafeArea
        let opacity = (distance - collapsedHeight) / totalHeight
        favoritesCollectionView.alpha = opacity
    }

}
