//
//  TestTableViewController.swift
//  TCAT
//
//  Created by Yana Sang on 11/28/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit

class TestTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
//        tableView.estimatedRowHeight = 110.0
//        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(TodayExtensionCell.self, forCellReuseIdentifier: "todayExtensionCell")
        
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "todayExtensionCell", for: indexPath) as? TodayExtensionCell
        
        if cell == nil {
            cell = TodayExtensionCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "todayExtensionCell")
        }
        
        cell?.layoutSubviews()
        
        return cell!
    }
}
