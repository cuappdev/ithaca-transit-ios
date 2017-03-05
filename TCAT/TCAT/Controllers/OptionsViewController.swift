//
//  OptionsViewController.swift
//  TCAT
//
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    let identifier: String = "Route cell"
    var routes: [Route] = []
    
    //Data
    var departureTime: Date?
    var arrivalTime: Date?
    var stops: [String] = [] //mainStops
    var stopNums: [Int] = [] //mainStopsNum, 0 for pins
    var distance: Double? //of first stop
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView = UITableView(frame: view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        self.view.addSubview(tableView)
        
        //Set up test routes
        let date1 = Time.date(from: "3:45 PM")
        let date2 = Time.date(from: "3:52 PM")
        let route1 = Route(departureTime: date1, arrivalTime: date2, directions: [], mainStops: ["Baker Flagpole", "Commons - Seneca Street"], mainStopsNums: [90, 0], travelDistance: 0.1)
        
        let date3 = Time.date(from: "12:12 PM")
        let date4 = Time.date(from: "12:47 PM")
        let route2 = Route(departureTime: date3, arrivalTime: date4, directions: [], mainStops: ["Annabel Taylor Hall", "Commons - Seneca Street"], mainStopsNums: [90, 0], travelDistance: 0.1)
        
        let date5 = Time.date(from: "1:12 PM")
        let date6 = Time.date(from: "1:38 PM")
        let route3 = Route(departureTime: date5, arrivalTime: date6, directions: [], mainStops: ["Baker Flagpole", "Schwartz Center", "Commons - Seneca Street"], mainStopsNums: [90, 32, 0], travelDistance: 0.1)
        
        routes = [route1, route2, route3]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.register(RouteTableViewCell.classForCoder(), forCellReuseIdentifier: identifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Tableview Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return routes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? RouteTableViewCell
        
        if cell == nil {
            cell = RouteTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        
        cell?.departureTime = routes[indexPath.row].departureTime
        cell?.arrivalTime = routes[indexPath.row].arrivalTime
        cell?.stops = routes[indexPath.row].mainStops
        cell?.stopNums = routes[indexPath.row].mainStopsNums
        cell?.distance = routes[indexPath.row].travelDistance
        
        return cell!
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return (section == 1) ? "Route Results" : nil
    
    }
    


}
