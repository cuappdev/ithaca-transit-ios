//
//  OptionsViewController.swift
//  TCAT
//
//  Created by Monica Ong on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

/* N2SELF:
  * format date to "Today, Tomorrow, Next Tuesday" (after next week stuff don't need any more custom string)
  * stop date picker from going back in time, restrict ot next 6 days
  * fix navigation color = set it to not clear
 */

class OptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //View
    var routeSelection: RouteSelectionView!
    var datePickerView: DatePickerView!
    var datePickerOverlay: UIView!
    var routeResults: UITableView!
    let identifier: String = "Route cell"
    
    //Data
    var routes: [Route] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up navigation bar
        title = "Route Options"
        //Set up route selection view
        routeSelection = RouteSelectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 150))
        routeSelection.backgroundColor = .lineColor
        routeSelection.positionAndAddViews()
        var newRSFrame = routeSelection.frame
        newRSFrame.size.height =  routeSelection.lineWidth + routeSelection.fromToView.frame.height + routeSelection.lineWidth + routeSelection.timeButton.frame.height
        routeSelection.frame = newRSFrame
        
        view.addSubview(routeSelection)
        
        //Set up datepicker
        routeSelection.timeButton.addTarget(self, action: #selector(self.showDatePicker), for: .touchUpInside)
        datePickerView = DatePickerView(frame: CGRect(x: 0, y: self.view.frame.height, width: view.frame.width, height: 305.5))
        datePickerView.positionAndAddViews()
        datePickerView.backgroundColor = .white
        datePickerView.cancelButton.addTarget(self, action: #selector(self.dismissDatePicker), for: .touchUpInside)
        datePickerView.doneButton.addTarget(self, action: #selector(self.saveDatePickerDate), for: .touchUpInside)
        
        datePickerOverlay = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        datePickerOverlay.backgroundColor = .black
        datePickerOverlay.alpha = 0
        datePickerOverlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissDatePicker)))
        
        view.addSubview(datePickerOverlay)
        view.sendSubview(toBack: datePickerOverlay)
        
        //Set up table view
        routeResults = UITableView(frame: CGRect(x: 0, y: routeSelection.frame.maxY, width: view.frame.width, height: view.frame.height - routeSelection.frame.height - (navigationController?.navigationBar.frame.height ?? 0) - UIApplication.shared.statusBarFrame.height))
        routeResults.delegate = self
        routeResults.dataSource = self
        routeResults.separatorStyle = .none
        routeResults.allowsSelection = false
        routeResults.backgroundColor = .tableBackgroundColor
        routeResults.alwaysBounceVertical = false //so table view doesn't scroll over top & bottom
        view.addSubview(routeResults)
        view.addSubview(datePickerView)//so datePicker can go ontop of other views

        
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
    
    override func viewDidAppear(_ animated: Bool) {
        Loader.addLoaderTo(routeResults)
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.loaded), userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Loader functionality
    func loaded()
    {
        Loader.removeLoaderFrom(routeResults)
    }
    
    //MARK: Datepicker functionality
    func showDatePicker(sender: UIButton){
        view.bringSubview(toFront: datePickerOverlay)
        view.bringSubview(toFront: datePickerView)
        UIView.animate(withDuration: 0.5) { 
            self.datePickerView.center.y = self.view.frame.height - (self.datePickerView.frame.height/2)
            self.datePickerOverlay.alpha = 0.7
        }
    }
    
    func dismissDatePicker(sender: UIButton){
        UIView.animate(withDuration: 0.5, animations: { 
            self.datePickerView.center.y = self.view.frame.height + (self.datePickerView.frame.height/2)
            self.datePickerOverlay.alpha = 0.0
        }) { (true) in
            self.view.sendSubview(toBack: self.datePickerOverlay)
            self.view.sendSubview(toBack: self.datePickerView)
        }
    }
    
    func saveDatePickerDate(sender: UIButton){
        let date = datePickerView.datePicker.date
        let dateString = Time.fullString(from: date)
        let segmentedControl = datePickerView.arriveDepartBar
        let action = (segmentedControl?.titleForSegment(at: segmentedControl?.selectedSegmentIndex ?? 0)) ?? ""
        var title = ""
        //Customize string based on date
        if(Calendar.current.isDateInToday(date) || Calendar.current.isDateInTomorrow(date)){
            let removePreposition = action.capitalizingFirstLetter().components(separatedBy: " ").first! //Use simply,"arrive" or "leave"
            let day = Calendar.current.isDateInToday(date) ? "" : " tomorrow" //if today don't put day
            title = "\(removePreposition)\(day) at \(Time.string(from: date))"
        }else{
            let customAction = (action.lowercased().contains("arrive")) ? action.capitalizingFirstLetter() : "\(action.capitalizingFirstLetter().components(separatedBy: " ").first!) on" //Use "arrive by" or "leave on"
            title = "\(customAction) \(dateString)"
        }

        routeSelection.timeButton.setTitle(title, for: .normal)
        
        //dismiss datepicker view
        dismissDatePicker(sender: sender)
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
        header.contentView.backgroundColor = .tableBackgroundColor
        header.textLabel?.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        header.textLabel?.textColor = UIColor.secondaryTextColor
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
