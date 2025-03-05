//
//  NewInformationViewController.swift
//  TCAT
//
//  Created by Asen Ou on 3/4/25.
//  Copyright © 2025 Cornell AppDev. All rights reserved.
//

import UIKit

class NewInformationViewController: UIViewController {
    
    // Main View Properties
    private let tableView = UITableView()
    
    // Table View Properties
    struct RowItem {
        let image: UIImage?
        let title: String
        let subtitle: String
        let action: () -> Void
    }
    
    private var rows: [RowItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Track Analytics
        let payload = AboutPageOpenedPayload()
        TransitAnalytics.shared.log(payload)
        
        // Populate row items
        setUpRowItems()
        
        // Set up main view
        setUpMainView()
        setUpNavigationItem()
        
        // Set up subviews
        setUpTableView()
    }
    private func setUpRowItems() {
        rows = [
            RowItem(
                image: <#T##UIImage?#>,
                title: "About Transit",
                subtitle: <#T##String#>,
                action: <#T##() -> Void#>),
            RowItem(
                image: <#T##UIImage?#>,
                title: "App Icon",
                subtitle: <#T##String#>,
                action: <#T##() -> Void#>),
            RowItem(
                image: <#T##UIImage?#>,
                title: "Privacy",
                subtitle: <#T##String#>,
                action: <#T##() -> Void#>),
            RowItem(
                image: <#T##UIImage?#>,
                title: "Support",
                subtitle: <#T##String#>,
                action: <#T##() -> Void#>),
            RowItem(
                image: <#T##UIImage?#>,
                title: "Show Onboarding",
                subtitle: <#T##String#>,
                action: <#T##() -> Void#>),
            RowItem(
                image: <#T##UIImage?#>,
                title: "TCAT Service Alerts",
                subtitle: <#T##String#>,
                action: <#T##() -> Void#>),
            
        ]
    }
    
    // MARK: - Main view init
    private func setUpMainView() {
        // Initialize view defaults
        title = Constants.Titles.aboutUs
        view.backgroundColor = Colors.backgroundWash
        navigationController?.navigationBar.tintColor = Colors.primaryText
    }
    
    private func setUpNavigationItem() {
        
    }
}

// MARK: - TableView init
extension NewInformationViewController: UITableViewDataSource, UITableViewDelegate, InfoHeaderViewDelegate {
    // function for InfoHeaderViewDelegate
    func showFunMessage() {
        let title = Constants.Alerts.MagicBus.title
        let message = Constants.Alerts.MagicBus.message
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Constants.Alerts.MagicBus.action, style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
    private func setUpTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cells.informationCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Colors.backgroundWash
        tableView.separatorColor = Colors.dividerTextField
        tableView.showsVerticalScrollIndicator = false
        
        let headerView = InformationTableHeaderView()
        headerView.delegate = self
        tableView.tableHeaderView = headerView
        
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}
