//
//  OptionsViewController.swift
//  TCAT
//
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

/* N2SELF:
  * fix spacing of cells
  * turn off cell highlight upon selection
  * stop tableview from scrolling beyond top & bottom 
 */

class OptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //View
    var routeSelection: RouteSelectionView!
    var routeResults: UITableView!
    let identifier: String = "Route cell"
    
    //Data
    var routes: [Route] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up navigation bar
        title = "Route Options"
        //Set up route selection view
        routeSelection = RouteSelectionView(frame: CGRect(x: 0, y: (navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.size.height, width: view.frame.width, height: 150))
        routeSelection.backgroundColor = .lineColor
        routeSelection.positionAndAddViews()
        var newRSFrame = routeSelection.frame
        newRSFrame.size.height =  routeSelection.lineWidth + routeSelection.fromToView.frame.height + routeSelection.lineWidth
        routeSelection.frame = newRSFrame
        view.addSubview(routeSelection)
        
        //Set up table view
        routeResults = UITableView(frame: CGRect(x: 0, y: routeSelection.frame.maxY, width: view.frame.width, height: view.frame.height - routeSelection.frame.height))
        routeResults.delegate = self
        routeResults.dataSource = self
        routeResults.separatorStyle = .none

        view.addSubview(routeResults)
        
        //Set up test data
        let date1 = Time.date(from: "3:45 PM")
        let date2 = Time.date(from: "3:52 PM")
        let route1 = Route(departureTime: date1, arrivalTime: date2, directions: [], mainStops: ["Baker Flagpole", "Commons - Seneca Street"], mainStopsNums: [90, -1], travelDistance: 0.1)
        
        let date3 = Time.date(from: "12:12 PM")
        let date4 = Time.date(from: "12:47 PM")
        let route2 = Route(departureTime: date3, arrivalTime: date4, directions: [], mainStops: ["Annabel Taylor Hall", "Commons - Seneca Street"], mainStopsNums: [90, -1], travelDistance: 0.1)
        
        let date5 = Time.date(from: "1:12 PM")
        let date6 = Time.date(from: "1:38 PM")
        let route3 = Route(departureTime: date5, arrivalTime: date6, directions: [], mainStops: ["Baker Flagpole", "Schwartz Center", "Commons - Seneca Street"], mainStopsNums: [90, 32, -1], travelDistance: 0.1)
        
        routes = [route1, route2, route3]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        routeResults.register(RouteTableViewCell.classForCoder(), forCellReuseIdentifier: identifier)
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
        cell?.setData()
        
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return "Route Results"
    
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        header.textLabel?.textColor = UIColor.headerTitleColor
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let travelTimeHeight: CGFloat = 20.33
        let pinHeight: CGFloat = 33.0
        let arrowHeight: CGFloat = 6.0
        let space: CGFloat = 18.0
        
        let numOfArrows = CGFloat(routes[indexPath.row].mainStopsNums.count-1)
        let numOfPins = CGFloat(routes[indexPath.row].mainStopsNums.count)
        
        let totalPinHeight = numOfPins*pinHeight
        let totalPinSpacingHeight = numOfArrows*space*2
        let totalArrowHeight = numOfArrows*arrowHeight
        
        return space + travelTimeHeight + space + totalPinHeight + totalPinSpacingHeight + totalArrowHeight  + space
    }
    


}
