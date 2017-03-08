//
//  RouteDetailViewController.swift
//  TCAT
//
//  Created by Matthew Barker on 2/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import GoogleMaps

class RouteDetailViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var detailView = UIView()
    var detailTableView: UITableView!
    var summaryView = UIView()
    
    var route: Route!
    var directions: [Direction] = []
    
    let main = UIScreen.main.bounds
    let summaryView_height: CGFloat = 80
    let largeDetailHeight: CGFloat = 80
    var mediumDetailHeight: CGFloat = UIScreen.main.bounds.height / 2
    let smallDetailHeight: CGFloat = UIScreen.main.bounds.height - 80
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parseDirections()
        formatNavigationController()
        initializeDetailView()
    }
    
    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: 1.285, longitude: 103.848, zoom: 12)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: summaryView_height, right: 0)
        view = mapView
    }
    
    func parseDirections() {
        
        let walk = WalkDirection(time: Date(),
                                 place: "my house",
                                 location: CLLocation(latitude: 1, longitude: 1),
                                 travelDistance: 0.2)
        let board = DepartDirection(time: Date().addingTimeInterval(300),
                                    place: "Bus Stop 1",
                                    location: CLLocation(latitude: 1, longitude: 1),
                                    routeNumber: 42,
                                    bound: Bound.inbound,
                                    stops: ["Bus Stop 2", "Bus Stop 3", "Bus Stop 4"],
                                    arrivalTime: Date().addingTimeInterval(600))
        let debark = ArriveDirection(time: Date().addingTimeInterval(600),
                                     place: "Bus Stop 5",
                                     location: CLLocation(latitude: 1, longitude: 1))
        let walk2 = WalkDirection(time: Date().addingTimeInterval(900),
                                  place: "not my house",
                                  location: CLLocation(latitude: 1, longitude: 1),
                                  travelDistance: 0.3)
        
        directions = [walk, board, debark, walk2]
        
        route = Route(departureTime: Date(),
                      arrivalTime: Date().addingTimeInterval(900),
                      directions: directions,
                      mainStops: ["Bus Stop 1", "Bus Stop 5", "not my house"],
                      mainStopsNums: [16, -1, -1],
                      travelDistance: 1.0)
        
    }
    
    func formatNavigationController() {
        
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .darkGray
        
        title = "Route Details"
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAction))
        self.navigationItem.setRightBarButton(cancelButton, animated: true)
        
    }
    
    func cancelAction() {
        
    }
    
    /** Animate detailTableView back onto screen */
    func summaryTapped(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            let isMedium = self.detailView.frame.minY == self.mediumDetailHeight
            let point = CGPoint(x: 0, y: isMedium ? self.smallDetailHeight : self.mediumDetailHeight)
            self.detailView.frame = CGRect(origin: point, size: self.view.frame.size)
        }
    }
    
    func initializeDetailView() {
        
        // Format the Detail View (color, shadow, gestures)
        detailView.backgroundColor = .white
        detailView.frame = CGRect(x: 0, y: mediumDetailHeight, width: main.width, height: main.height - largeDetailHeight)
        detailView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        gesture.delegate = self
        detailView.addGestureRecognizer(gesture)
        
        // Place and format the summary view
        summaryView.backgroundColor = UIColor(red: 248 / 255, green: 248 / 255, blue: 248 / 255, alpha: 1)
        summaryView.frame = CGRect(x: 0, y: 0, width: main.width, height: summaryView_height)
        summaryView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        summaryView.layer.shadowColor = UIColor.black.cgColor
        summaryView.layer.shadowOpacity = 0.5
        summaryView.layer.shadowOffset = CGSize.zero
        summaryView.layer.shadowRadius = 16
        summaryView.layer.shadowPath = UIBezierPath(rect: detailView.bounds).cgPath
        let summaryTapGesture = UITapGestureRecognizer(target: self, action: #selector(summaryTapped))
        summaryTapGesture.delegate = self
        summaryView.addGestureRecognizer(summaryTapGesture)
        detailView.addSubview(summaryView)
        
        // Create puller tab
        let puller = UIView(frame: CGRect(x: 0, y: 6, width: 32, height: 4))
        puller.center.x = summaryView.center.x
        puller.backgroundColor = UIColor(red: 155 / 255, green: 155 / 255, blue: 155 / 255, alpha: 1)
        puller.layer.cornerRadius = puller.frame.height / 2
        summaryView.addSubview(puller)
        
        // Create and place all bus routes in Directions
        var center = CGPoint(x: 20 + 36, y: summaryView.frame.height / 2)
        var icon_maxY: CGFloat = 20
        for direction in directions {
            if direction is DepartDirection {
                
                let busIcon = BusIcon(size: .large, number: 16)
                busIcon.center = center
                summaryView.addSubview(busIcon)
                
                center.x += (22 * 2) + 8
                icon_maxY += busIcon.frame.width
            }
        }
        
        // Place and format summary label
        let leftTextLabel = UILabel()
        if let firstDirection = (directions.filter { $0 is DepartDirection }).first {
            if let totalTime = Time.dateComponents(from: route.departureTime, to: route.arrivalTime).minute {
                leftTextLabel.text = "Depart at \(firstDirection.timeDescription) • \(totalTime) min"
            } else {
                leftTextLabel.text = "Depart at \(firstDirection.timeDescription)"
            }
        } else {
            leftTextLabel.text = "Summary Data"
        }
        
        leftTextLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
        leftTextLabel.textColor = UIColor(red: 74 / 255, green: 74 / 255, blue: 74 / 255, alpha: 1)
        leftTextLabel.sizeToFit()
        leftTextLabel.frame.origin.x = icon_maxY + 16
        leftTextLabel.center.y = (summaryView.bounds.height) / 2
        summaryView.addSubview(leftTextLabel)
        
        // Create Detail Table View
        detailTableView = UITableView()
        detailTableView.frame.origin = CGPoint(x: 0, y: summaryView_height)
        detailTableView.frame.size = CGSize(width: main.width, height: detailView.frame.height - summaryView_height)
        detailTableView.bounces = false
        detailTableView.estimatedRowHeight = 96 // 68 walking
        detailTableView.rowHeight = UITableViewAutomaticDimension
        detailTableView.register(SmallDetailTableViewCell.self, forCellReuseIdentifier: "smallCell")
        detailTableView.register(LargeDetailTableViewCell.self, forCellReuseIdentifier: "largeCell")
        detailTableView.register(BusStopTableViewCell.self, forCellReuseIdentifier: "busStopCell")
        detailTableView.dataSource = self
        detailTableView.delegate = self
        detailView.addSubview(detailTableView)
        view.addSubview(detailView)
        
        // Resize and change Detail View / Table View if the view can be smaller (less cells)
        let calculatedTableViewHeight = calculateTableViewHeight()
        if calculatedTableViewHeight < (largeDetailHeight - smallDetailHeight) {
            detailView.frame.size.height = calculatedTableViewHeight + 16
            detailView.frame.origin.y = main.height - detailView.frame.size.height
            mediumDetailHeight = main.height - (calculatedTableViewHeight + 16)
        }
        
    }
    
    func calculateTableViewHeight() -> CGFloat {
        // check what kind of cell from array
        var sum: CGFloat = 0
        for direction in directions {
            if direction is WalkDirection || direction is ArriveDirection {
                sum += SmallDetailTableViewCell().getCellHeight()
            } else {
                sum += LargeDetailTableViewCell().getCellHeight()
            }
        }
        return sum
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let direction = directions[indexPath.row]
        return direction is WalkDirection || direction is ArriveDirection ? 68 : 96
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let direction = directions[indexPath.row]
        let isBusStopCell = direction is ArriveDirection && direction.location.coordinate.latitude == 0.0
        
        if isBusStopCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "busStopCell")! as! BusStopTableViewCell
            cell.setCell(direction.place)
            cell.selectionStyle = .none
            cell.layoutMargins = UIEdgeInsets(top: 0, left: main.width, bottom: 0, right: 0)
            return cell
        }
        else if direction is WalkDirection || direction is ArriveDirection {
            let cell = tableView.dequeueReusableCell(withIdentifier: "smallCell")! as! SmallDetailTableViewCell
            cell.setCell(direction, busEnd: direction is ArriveDirection,
                         firstStep: indexPath.row == 0,
                         lastStep: indexPath.row == directions.count - 1)
            cell.selectionStyle = .none
            cell.layoutMargins = UIEdgeInsets(top: 0, left: 140, bottom: 0, right: 0)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "largeCell")! as! LargeDetailTableViewCell
            cell.setCell(direction, firstStep: indexPath.row == 0)
            cell.selectionStyle = .none
            cell.layoutMargins = UIEdgeInsets(top: 0, left: 140, bottom: 0, right: 0)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let direction = directions[indexPath.row]
        
        // Check if cell starts a bus direction, and should be expandable
        if direction is DepartDirection {
            
            let cell = tableView.cellForRow(at: indexPath) as! LargeDetailTableViewCell
            cell.chevron.layer.removeAllAnimations()
            
            UIView.animate(withDuration: TimeInterval(0.2), animations: {
                cell.chevron.transform = cell.chevron.transform.rotated(by: CGFloat(M_PI))
            })
            
            /*
             func flip() {
             let transitionOptionsOne: UIViewAnimationOptions = [.transitionFlipFromTop, .showHideTransitionViews]
             UIView.transition(with: cell.chevron, duration: 0.5, options: transitionOptionsOne, animations: {
             cell.chevron.isHidden = true
             })
             let transitionOptionsTwo: UIViewAnimationOptions = [.transitionFlipFromBottom, .showHideTransitionViews]
             UIView.transition(with: cell.chevron, duration: 0.5, options: transitionOptionsTwo, animations: {
             cell.chevron.isHidden = false
             })
             }
             */
            
            cell.isExpanded = !cell.isExpanded
            
            // Prepare bus stop data to be inserted / deleted into Directions array
            var busStops: [Direction] = []
            for stop in (direction as! DepartDirection).stops {
                let stopAsDirection = ArriveDirection(time: Date(), place: stop, location: CLLocation())
                busStops.append(stopAsDirection)
            }
            var indexPathArray: [IndexPath] = []
            let busStopRange = (indexPath.row + 1)..<(indexPath.row + 1) + busStops.count
            for i in busStopRange {
                indexPathArray.append(IndexPath(row: i, section: 0))
            }
            
            tableView.beginUpdates()
            
            // Insert or remove bus stop data based on selection
            if cell.isExpanded {
                directions.insert(contentsOf: busStops, at: indexPath.row + 1)
                tableView.insertRows(at: indexPathArray, with: .automatic)
            } else {
                directions.replaceSubrange(busStopRange, with: [])
                tableView.deleteRows(at: indexPathArray, with: .automatic)
            }
            
            tableView.endUpdates()
            
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
            
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.detailView)
        let velocity = recognizer.velocity(in: self.detailView)
        let y = self.detailView.frame.minY
        
        if y + translation.y >= largeDetailHeight && y + translation.y <= smallDetailHeight {
            self.detailView.frame = CGRect(x: 0, y: y + translation.y, width: detailView.frame.width, height: detailView.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.detailView)
        }
        
        if recognizer.state == .ended {
            
            let visibleScreen = self.main.height - UIApplication.shared.statusBarFrame.height - self.navigationController!.navigationBar.frame.height
            
            var duration = Double(abs(visibleScreen - y)) / Double(abs(velocity.y))
            duration = duration > 1.3 ? 1 : duration
            print("duration: \(duration)")
            
            UIView.animate(withDuration: duration) {
                
                var point = CGPoint()
                
                if y <= self.mediumDetailHeight + visibleScreen / 4 && y >= self.mediumDetailHeight - visibleScreen / 4 {
                    point = CGPoint(x: 0, y: velocity.y >= 0 ? self.smallDetailHeight : self.largeDetailHeight)
                } else {
                    if y > self.mediumDetailHeight + visibleScreen / 4 {
                        if velocity.y > 0 {
                            point = CGPoint(x: 0, y: self.smallDetailHeight)
                        } else {
                            point = CGPoint(x: 0, y: velocity.y <= -1000 ? self.largeDetailHeight : self.mediumDetailHeight)
                        }
                    } else {
                        if velocity.y < 0 {
                            point = CGPoint(x: 0, y: self.largeDetailHeight)
                        } else {
                            point = CGPoint(x: 0, y: velocity.y >= 1000 ? self.smallDetailHeight : self.mediumDetailHeight)
                        }
                    }
                }
                
                print("translation: \(translation)")
                print("velocity: \(velocity)")
                print("point: \(point)")
                
                self.detailView.frame = CGRect(origin: point, size: self.view.frame.size)
            }
        }
        
    }
    
}
