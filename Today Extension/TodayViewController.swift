//
//  TodayViewController.swift
//  Today Extension
//
//  Created by Yana Sang on 12/1/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit
import NotificationCenter
import SnapKit

 @objc(TodayViewController) class TodayViewController: UIViewController, NCWidgetProviding {

    var routes: UITableView = UITableView()
    var favorites: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        extensionContext?.widgetLargestAvailableDisplayMode = .expanded

        favorites = TodayExtensionManager.shared.retrieveFavoritesNames(for: Constants.UserDefaults.favorites)

        setUpRoutesTableView()
        view.addSubview(routes)
        createConstraints()
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        // called to update the widget

        // update bus info?
        print("widgetPerformUpdate")

        setUpRoutesTableView() // routes.reloadData()?

        completionHandler(NCUpdateResult.newData)
    }

    /// Called in response to the user tapping the “Show More” or “Show Less” buttons
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        // change height to 110.0 * numberOfFavorites
        preferredContentSize = expanded ? CGSize(width: maxSize.width, height: 110.0 * CGFloat(favorites.count)) : maxSize
    }

    func createConstraints() {
        routes.snp.makeConstraints {(make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(110.0*5)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        routes.reloadData()
        createConstraints()
    }

}

extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    private func setUpRoutesTableView() {
        routes.delegate = self
        routes.dataSource = self
        routes.register(TodayExtensionCell.self, forCellReuseIdentifier: "todayExtensionCell")
        routes.register(NoFavoritesCell.self, forCellReuseIdentifier: "noFavoritesCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // change 5 to number of favorites
        return (extensionContext?.widgetActiveDisplayMode == .compact) ? 1 : (favorites.isEmpty) ? 1 : favorites.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (favorites.count != 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "todayExtensionCell", for: indexPath) as! TodayExtensionCell
            cell.setUpCell(destinationText: favorites[indexPath.row])
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "noFavoritesCell", for: indexPath) as! NoFavoritesCell
        return cell
    }
    
}
