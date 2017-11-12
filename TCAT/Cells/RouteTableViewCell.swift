//
//  RouteTableViewCell.swift
//  TCAT
//
//  Created by Monica Ong on 2/13/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

protocol TravelDistanceDelegate: NSObjectProtocol {
    func travelDistanceUpdated(withDistance distance: Double)
}
class RouteTableViewCell: UITableViewCell, TravelDistanceDelegate {

    // MARK: Data var
    
    var route: Route?
    let identifier: String = "Route cell"
    
    // MARK: View vars
    
    var travelTimeLabel: UILabel = UILabel()
    var departureTimeLabel: UILabel = UILabel()
    var arrowImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "side-arrow"))

    var routeDiagram: RouteDiagram = RouteDiagram()
    
    var topBorder: UIView = UIView()
    var bottomBorder: UIView = UIView()
    var cellSeperator: UIView = UIView()
    
    // MARK: Spacing vars
    
    let timeLabelLeftSpaceFromSuperview: CGFloat = 18.0
    let timeLabelVerticalSpaceFromSuperview: CGFloat = 18.0
    
    let arrowImageViewRightSpaceFromSuperview: CGFloat = 12.0
    let departureLabelSpaceFromArrowImageView: CGFloat = 8.0

    let timeLabelAndRouteDiagramVerticalSpace: CGFloat = 20.5
    
    let cellBorderHeight: CGFloat = 0.75
    let cellSeperatorHeight: CGFloat = 4.0
    
    let routeDiagramAndCellSeparatorVerticalSpace: CGFloat = 16.5
    
    // MARK: Init

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        styleTravelTime()
        styleDepartureTime()
        styleTopBorder()
        
        positionTravelTime()
        positionDepartureTimeVertically()
        positionArrowVertically(usingDepartureTime: departureTimeLabel)
        positionTopBorder()
        
        contentView.addSubview(travelTimeLabel)
        contentView.addSubview(departureTimeLabel)
        contentView.addSubview(arrowImageView)
        contentView.addSubview(topBorder)
    }
    
    init() {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func heightForCell(withNumOfStops numOfStops: Int) -> CGFloat{
        let numOfSolidStopDots = numOfStops - 1
        let numOfRouteLines = numOfSolidStopDots
        
        let timeLabelHeight: CGFloat = 17.0
        
        let headerHeight = timeLabelVerticalSpaceFromSuperview + timeLabelHeight  + timeLabelAndRouteDiagramVerticalSpace
        
        let solidStopDotDiameter: CGFloat = 12.0
        let routeLineHeight: CGFloat = RouteDiagram.routeLineHeight
        let destinationDotHeight: CGFloat = Circle(size: .large, color: .tcatBlueColor, style: .bordered).frame.height
        
        let routeDiagramHeight = (CGFloat(numOfSolidStopDots)*solidStopDotDiameter) +
        (CGFloat(numOfRouteLines)*routeLineHeight) + destinationDotHeight
        
        let footerHeight = routeDiagramAndCellSeparatorVerticalSpace + cellSeperatorHeight
        
        return headerHeight + routeDiagramHeight + footerHeight
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        routeDiagram.prepareForReuse()

        routeDiagram.removeFromSuperview()
        cellSeperator.removeFromSuperview()
        bottomBorder.removeFromSuperview()
    }
    
    // MARK: Travel Distance Delegate
    
    func travelDistanceUpdated(withDistance distance: Double) {
        routeDiagram.setTravelDistance(withDistance: distance)
    }
    
    // MARK: Set Data
        
    func setRouteData(){
        
        guard let departureTime = route?.departureTime,
              let arrivalTime = route?.arrivalTime,
              let isWalkingRoute = route?.isWalkingRoute(),
              let routeSummary = route?.routeSummary
              else{
                print("RouteTableViewCell route object does not have the data needed to fill in the cell")
                return
              }
        
        setTravelTime(withDepartureTime: departureTime, withArrivalTime: arrivalTime)
        setDepartureTime(withTime: departureTime, isWalkingRoute: isWalkingRoute)
        
        routeDiagram.setRouteData(fromRouteSummary: routeSummary, fromTravelDistance: route?.travelDistance)
    }
    
    private func setTravelTime(withDepartureTime departureTime: Date, withArrivalTime arrivalTime: Date){
        travelTimeLabel.text = "\(Time.timeString(from: departureTime)) - \(Time.timeString(from: arrivalTime))"
        travelTimeLabel.sizeToFit()
    }
    
    private func setDepartureTime(withTime departureTime: Date, isWalkingRoute: Bool){
        if isWalkingRoute {
            departureTimeLabel.text = ""
            return
        }
        
        let time = Time.timeString(from: Date(), to: departureTime)
        
        if time == "0 min" {
            departureTimeLabel.text = "Board now"
        } else {
           departureTimeLabel.text = "Board in \(time)"
        }
        departureTimeLabel.sizeToFit()
    }
    
    // MARK: Style
    
    private func styleTravelTime(){
        travelTimeLabel.font = UIFont(name: FontNames.SanFrancisco.Semibold, size: 14.0)
        travelTimeLabel.textColor = .primaryTextColor
    }
    
    private func styleDepartureTime(){
        departureTimeLabel.font = UIFont(name: FontNames.SanFrancisco.Semibold, size: 14.0)
        departureTimeLabel.textColor = .tcatBlueColor
    }
    
    private func styleTopBorder(){
        topBorder.backgroundColor = .lineColor
    }
    
    private func styleBottomBorder(){
        bottomBorder.backgroundColor = .lineColor
    }
    
    private func styleCellSeperator(){
        cellSeperator.backgroundColor = .tableBackgroundColor
    }
    
    // MARK: Positioning
    
    func positionSubviews(){
        
        positionArrowHorizontally()
        positionDepartureTimeHorizontally(usingArrowImageView: arrowImageView)
        positionRouteDiagram(usingTravelTimeLabel: travelTimeLabel)
        
        routeDiagram.positionSubviews()
        
        styleCellSeperator()
        styleBottomBorder()
        
        positionCellSeperator(usingRouteDiagram: routeDiagram)
        positionBottomBorder(usingCellSeperator: cellSeperator)
    }
    
    private func positionTravelTime(){
        travelTimeLabel.frame = CGRect(x: timeLabelLeftSpaceFromSuperview, y: timeLabelVerticalSpaceFromSuperview, width: 135, height: 20)
    }
    
    private func positionDepartureTimeVertically(){
        departureTimeLabel.frame = CGRect(x: 0, y: travelTimeLabel.frame.minY, width: 135, height: 20)
    }
    
    private func positionArrowVertically(usingDepartureTime departueTimeLabel: UILabel) {
        arrowImageView.center.y = departureTimeLabel.center.y
    }
    
    private func positionTopBorder(){
        topBorder.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: cellBorderHeight)
    }
    
    private func positionArrowHorizontally() {
        arrowImageView.center.x = contentView.frame.width - arrowImageViewRightSpaceFromSuperview - (arrowImageView.frame.width/2)
    }
    
    private func positionDepartureTimeHorizontally(usingArrowImageView arrowImageView: UIImageView){
        departureTimeLabel.center.x = arrowImageView.frame.minX - departureLabelSpaceFromArrowImageView - (departureTimeLabel.frame.width/2)
    }
    
    private func positionRouteDiagram(usingTravelTimeLabel travelTimeLabel: UILabel){
        routeDiagram.frame = CGRect(x: 0, y: travelTimeLabel.frame.maxY + timeLabelAndRouteDiagramVerticalSpace, width: UIScreen.main.bounds.width, height: 75)
    }
    
    private func positionCellSeperator(usingRouteDiagram routeDiagram: RouteDiagram){
        cellSeperator.frame = CGRect(x: 0, y: routeDiagram.frame.maxY + routeDiagramAndCellSeparatorVerticalSpace, width: UIScreen.main.bounds.width, height: cellSeperatorHeight)
    }
    
    private func positionBottomBorder(usingCellSeperator cellSeperator: UIView){
        bottomBorder.frame = CGRect(x: 0, y: cellSeperator.frame.minY - cellBorderHeight, width: UIScreen.main.bounds.width, height: cellBorderHeight)
    }
    
    // MARK: Add subviews
    
    func addSubviews(){
        routeDiagram.addSubviews()
        
        contentView.addSubview(routeDiagram)
        contentView.addSubview(cellSeperator)
        contentView.addSubview(bottomBorder)
    }
    
}
