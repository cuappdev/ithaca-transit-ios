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
    
    var routes : UITableView = UITableView()
    // var favorites: [ItemType] = []!
    var favorites : [String] = ["ITHACA", "TRANSIT", "BY", "CORNELL", "APPDEV"]
        
    override func viewDidLoad() {
        super.viewDidLoad()
    
        extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        
        setUpRoutesTableView()
        view.addSubview(routes)
        createConstraints()
        
        // let extensionWidth = extensionContext?.widgetMaximumSize(for: (extensionContext?.widgetActiveDisplayMode)!).width
        
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        // called to update the widget
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? CGSize(width: maxSize.width, height: 110.0) : maxSize
    }
    
    func createConstraints() {
        routes.snp.makeConstraints{ (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        routes.reloadData()
        createConstraints()
    }
    
}

extension TodayViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (extensionContext?.widgetActiveDisplayMode == NCWidgetDisplayMode.compact) ? 1 : 5
        // need to take into account if 5 will exceed the max size
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let label = UILabel()
        label.text = favorites[indexPath.row]
        cell.addSubview(label)
        
        label.snp.makeConstraints{ (make) in
            make.center.equalToSuperview()
        }
        
        return cell
    }
    
    private func setUpRoutesTableView() {
        routes.delegate = self
        routes.dataSource = self
        // routes.register(TodayExtensionCell.self, forCellReuseIdentifier: "todayExtensionCell")
    }
}
