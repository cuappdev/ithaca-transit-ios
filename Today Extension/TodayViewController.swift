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
        
        print("viewDidLoad")
    
        // extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
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
        
        print("widgetPerformUpdate")
        
        setUpRoutesTableView()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        guard let maxSize = extensionContext?.widgetMaximumSize(for: activeDisplayMode) else { return }
        preferredContentSize = maxSize

//        let expanded = activeDisplayMode == .expanded
//        preferredContentSize = expanded ? maxSize : CGSize(width: extensionContext.size)
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

extension TodayViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (extensionContext?.widgetActiveDisplayMode == .compact) ? 1 : 5
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
        routes.backgroundColor = UIColor.white
        // routes.register(TodayExtensionCell.self, forCellReuseIdentifier: "todayExtensionCell")
    }
}
