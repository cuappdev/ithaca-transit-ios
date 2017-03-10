//
//  OptionsViewController.swift
//  TCAT
//
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

/* N2SELF:
  * stop tableview from scrolling beyond top & bottom
  * need to test departure time
  * Route model > change mainStopNums to mainBusNums
  * make font of busIcon = SFU
 */

class OptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //View
    var routeSelection: routeSelectionView!
    var routeResults: UITableView!
    let identifier: String = "Route cell"
    
    //Data
    var routes: [Route] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up navigation bar
        title = "Route Options"
        //Set up route selection view
        routeSelection = routeSelectionView(frame: CGRect(x: 0, y: (navigationController?.navigationBar.frame.height ?? 0) + UIApplication.shared.statusBarFrame.size.height, width: view.frame.width, height: 150))
        routeSelection.backgroundColor = .lineColor
        routeSelection.positionViews()
        var newRSFrame = routeSelection.frame
        newRSFrame.size.height =  routeSelection.lineWidth + routeSelection.fromToView.frame.height + routeSelection.lineWidth + routeSelection.timeView.frame.height
        routeSelection.frame = newRSFrame
        view.addSubview(routeSelection)
        
        //Set up table view
        routeResults = UITableView(frame: CGRect(x: 0, y: routeSelection.frame.maxY, width: view.frame.width, height: view.frame.height - routeSelection.frame.height - (navigationController?.navigationBar.frame.height ?? 0) - UIApplication.shared.statusBarFrame.size.height))
        routeResults.delegate = self
        routeResults.dataSource = self
        routeResults.separatorStyle = .none
        routeResults.allowsSelection = false
        routeResults.backgroundColor = .routeResultsBackColor

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
        
        print("Cell \(indexPath.row)")
        cell?.departureTime = routes[indexPath.row].departureTime
        cell?.arrivalTime = routes[indexPath.row].arrivalTime
        cell?.stops = routes[indexPath.row].mainStops
        cell?.busNums = routes[indexPath.row].mainStopsNums
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
        header.contentView.backgroundColor = .routeResultsBackColor
        header.textLabel?.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        header.textLabel?.textColor = UIColor.headerTitleColor
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let spaceYTimeLabelFromSuperviewTop: CGFloat = 18.0
        let travelTimeHeight: CGFloat = 17.0
        let spaceYTimeLabelAndDot: CGFloat = 26.0
        let heightDot: CGFloat = 8.0
        let lineLengthYBtDots: CGFloat = 21.0
        
        let spaceBtDotAndLineDot: CGFloat = 17.0
        let heightLineDot: CGFloat = 16.0
        let spaceYToCellBorder: CGFloat = 18.0
        let cellBorderWidthY: CGFloat = 0.75
        let cellSpaceWidthY: CGFloat = 4.0
        
        let numOfDots = routes[indexPath.row].mainStops.count - 1 //1 less b/c last dot is line dot
        let numOfLinesBtDots = numOfDots - 1
        
        let  headerHeight = spaceYTimeLabelFromSuperviewTop + travelTimeHeight + spaceYTimeLabelAndDot
        let dotsHeight = CGFloat(numOfDots)*heightDot + CGFloat(numOfLinesBtDots)*lineLengthYBtDots + spaceBtDotAndLineDot + heightLineDot
        let footerHeight = spaceYToCellBorder + cellBorderWidthY + cellSpaceWidthY
        return (headerHeight + dotsHeight + footerHeight)
    }
    


}
