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

class RouteTableViewCell: UITableViewCell {

    // MARK: Data vars
    
    let identifier: String = "routeCell"
    var route: Route?
    var searchTime: Date?
    var searchTimeType: SearchType?
    
    // MARK: Network vars
    
    var timer: Timer?

    // MARK: View vars

    var travelTimeLabel: UILabel = UILabel()
    var liveIndicatorView: LiveIndicator = LiveIndicator(size: .small, color: .clear)
    var liveLabel: UILabel = UILabel()
    var departureTimeLabel: UILabel = UILabel()
    var arrowImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "side-arrow"))

    var routeDiagram: RouteDiagram = RouteDiagram()

    var topBorder: UIView = UIView()
    var bottomBorder: UIView = UIView()
    var cellSeperator: UIView = UIView()

    // MARK: Spacing vars

    let timeLabelLeftSpaceFromSuperview: CGFloat = 18.0
    let timeLabelVerticalSpaceFromSuperview: CGFloat = 18.0
    
    let liveLabelHorizontalSpaceFromLiveIndicator: CGFloat = 4.0
    
    let arrowImageViewRightSpaceFromSuperview: CGFloat = 12.0
    let departureLabelSpaceFromArrowImageView: CGFloat = 8.0
    
    let timeLabelAndRouteDiagramVerticalSpace: CGFloat = 32.5
    
    let cellBorderHeight: CGFloat = 0.75
    let cellSeparatorHeight: CGFloat = 8.0
    
    let routeDiagramAndCellSeparatorVerticalSpace: CGFloat = 16.5

    // MARK: Init

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        styleTravelTime()
        styleLiveElements()
        styleDepartureTime()
        styleTopBorder()

        positionTravelTime()
        positionLiveLabel(usingTravelTime: travelTimeLabel) // N2SELF: need this?
        positionLiveIndicatorView(usingTravelTime: travelTimeLabel)
        positionDepartureTimeVertically(usingTravelTime: travelTimeLabel)
        positionArrowVertically(usingDepartureTime: departureTimeLabel)
        positionTopBorder()
        
        contentView.addSubview(travelTimeLabel)
        contentView.addSubview(liveIndicatorView)
        contentView.addSubview(liveLabel)
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

    func heightForCell(withNumOfStops numOfStops: Int, withNumOfWalkLines numOfWalkLines: Int) -> CGFloat {
        
        let numOfSolidStopDots = numOfStops - 1
        let numOfRouteLines = numOfSolidStopDots
        let numOfBusLines = numOfRouteLines - numOfWalkLines
        
        let timeLabelHeight: CGFloat = 17.0
        
        let headerHeight = timeLabelVerticalSpaceFromSuperview + timeLabelHeight + timeLabelAndRouteDiagramVerticalSpace
        
        let solidStopDotDiameter: CGFloat = Circle(size: .small, style: .solid, color: .tcatBlueColor).frame.height
        let busLineHeight: CGFloat = RouteDiagram.busLineHeight
        let walkLineHeight: CGFloat = RouteDiagram.walkLineHeight
        let destinationDotHeight: CGFloat = Circle(size: .medium, style: .bordered, color: .tcatBlueColor).frame.height
        
        let routeDiagramHeight = CGFloat(numOfSolidStopDots) * solidStopDotDiameter +
                                 CGFloat(numOfBusLines) * busLineHeight +
                                 CGFloat(numOfWalkLines) * walkLineHeight + destinationDotHeight
        
        let stopLabelHeight: CGFloat = 17.0 // add an extra stop label height for if the last label is two-lined
        let footerHeight = stopLabelHeight + stopLabelHeight + cellSeparatorHeight

        
        return headerHeight + routeDiagramHeight + footerHeight
        
    }

    // MARK: Reuse

    override func prepareForReuse() {
        routeDiagram.prepareForReuse()

        routeDiagram.removeFromSuperview()
        cellSeperator.removeFromSuperview()
        bottomBorder.removeFromSuperview()
        
        hideLiveElements()
        
        // stop timer
        timer?.invalidate()
    }
    
    // MARK: Get Data

    private func getDepartureAndArrivalTimes(fromRoute route: Route) -> (departureTime: Date, arrivalTime: Date) {
        if let firstDepartDirection = route.getFirstDepartRawDirection(), let lastDepartDirection = route.getLastDepartRawDirection(){
            return (departureTime: firstDepartDirection.startTime, arrivalTime: lastDepartDirection.endTime)
        }
            
        return (departureTime: route.departureTime, arrivalTime: route.arrivalTime)
    }
    
    private func getDelayedDepartureTime(fromRoute route: Route) -> Date? {
        if let firstDepartDirection = route.getFirstDepartRawDirection(), let delay = firstDepartDirection.delay {
            return firstDepartDirection.startTime.addingTimeInterval(TimeInterval(delay))
        }
        
        return nil
    }
    
    private func getDepartureTime(fromRoute route: Route) -> Date {
        if let firstDepartDirection = route.getFirstDepartRawDirection() {
            return firstDepartDirection.startTime
        }
        
        return route.departureTime
    }
    
    // Return nil if startTime should be Date()
    private func getStartTime(fromSearchTime searchTime: Date?, fromSearchTimeType searchTimeType: SearchType?) -> Date {
        if let searchTime = searchTime, let searchTimeType = searchTimeType {
            switch searchTimeType {
            case .leaveAt:
                return searchTime
            case .arriveBy:
                return Date()
            }
        }
        
        return Date()
    }

    // MARK: Set Data

    func setData(_ route: Route, withSearchTime searchTime: Date?, withSearchTimeType searchTimeType: SearchType?) {
        self.route = route
        self.searchTime = searchTime
        self.searchTimeType = searchTimeType
        
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateLiveElementsWithDelay as () -> Void), userInfo: nil, repeats: true)
        
        let (departureTime, arrivalTime) = getDepartureAndArrivalTimes(fromRoute: route)
        setTravelTime(withDepartureTime: departureTime, withArrivalTime: arrivalTime)
        
        setDepartureTimeAndLiveElements(withRoute: route, withSearchTime: searchTime, withSearchTimeType: searchTimeType)
        
        routeDiagram.setData(withDirections: route.rawDirections, withTravelDistance: route.travelDistance, withWalkingRoute: route.isRawWalkingRoute())
    }
    
    private func setDepartureTimeAndLiveElements(withRoute route: Route, withSearchTime searchTime: Date?, withSearchTimeType searchTimeType: SearchType?) {
        let isWalkingRoute = route.isRawWalkingRoute()

        if let delayedDepartureTime = getDelayedDepartureTime(fromRoute: route) {
            if isWalkingRoute {
                setDepartureTimeToWalking()
            }
            else {
                setDepartureTime(withStartTime: getStartTime(fromSearchTime: searchTime, fromSearchTimeType: searchTimeType), withDepartureTime: delayedDepartureTime, late: true)
            }
            setLiveElementsToLate(withDepartureTime: delayedDepartureTime)
        }
        else {
            let departureTime = getDepartureTime(fromRoute: route)
            if isWalkingRoute {
                setDepartureTimeToWalking()
            }
            else {
                setDepartureTime(withStartTime: getStartTime(fromSearchTime: searchTime, fromSearchTimeType: searchTimeType), withDepartureTime: departureTime, late: false)
            }
        }
    }
    
    @objc func updateLiveElementsWithDelay() {
        if let route = route,
            let direction = route.getFirstDepartRawDirection(),
            let tripId = direction.tripIdentifiers?.first,
            let stopId = direction.stops.first?.id  {
            Network.getDelay(tripId: tripId, stopId: stopId).perform(withSuccess: { (json) in
                if json["success"].boolValue {
                    guard let delay = json["data"]["delay"].int else {
                        self.hideLiveElements()
                        self.setDepartureTimeAndLiveElements(withRoute: route, withSearchTime: self.searchTime, withSearchTimeType: self.searchTimeType)
                        return
                    }
                    
                    let oneMinute = 60
                    if delay >= oneMinute {
                        let lateTime = direction.startTime.addingTimeInterval(TimeInterval(delay))
                        self.setLiveElementsToLate(withDepartureTime: lateTime)
                        
                        let startTime = self.getStartTime(fromSearchTime: self.searchTime, fromSearchTimeType: self.searchTimeType)
                        self.setDepartureTime(withStartTime: startTime, withDepartureTime: lateTime, late: true)
                    } else {
                        self.setLiveElementsOnTime()
                        self.setDepartureTimeOnTime()
                    }
                }
                else {
                    self.hideLiveElements()
                    self.setDepartureTimeAndLiveElements(withRoute: route, withSearchTime: self.searchTime, withSearchTimeType: self.searchTimeType)                }
            }, failure: { (error) in
                print("RouteTableViewCell setLiveElements(withStartTime:, withDelay:) error: \(error.errorDescription ?? "") Request url: \(error.request?.url?.absoluteString ?? "")")
                self.hideLiveElements()
                self.setDepartureTimeAndLiveElements(withRoute: route, withSearchTime: self.searchTime, withSearchTimeType: self.searchTimeType)
            })
        }
        else {
            self.hideLiveElements()
            if let route = route {
                self.setDepartureTimeAndLiveElements(withRoute: route, withSearchTime: self.searchTime, withSearchTimeType: self.searchTimeType)
            }
        }
    }

    private func hideLiveElements() {
        liveIndicatorView.setColor(to: .clear)
        liveLabel.textColor = .clear
    }
    
    private func setLiveElementsOnTime() {
        liveLabel.textColor = .liveGreenColor
        liveLabel.text = "On Time"
        liveIndicatorView.setColor(to:.liveGreenColor)
        
        liveLabel.sizeToFit()
        positionLiveIndicatorView(usingLiveLabel: liveLabel)
    }
    
    private func setDepartureTimeOnTime() {
        departureTimeLabel.textColor = .liveGreenColor
        arrowImageView.tintColor = .primaryTextColor
    }
    
    private func setLiveElementsToLate(withDepartureTime departureTime: Date) {
        liveLabel.textColor = .liveRedColor
        liveLabel.text = "Late - \(Time.timeString(from: departureTime))"
        liveIndicatorView.setColor(to: .liveRedColor)
        
        liveLabel.sizeToFit()
        positionLiveIndicatorView(usingLiveLabel: liveLabel)
    }
    
    private func setDepartureTime(withStartTime startTime: Date, withDepartureTime departureTime: Date, late: Bool) {
        let boardTime = Time.timeString(from: startTime, to: departureTime)
        departureTimeLabel.text = boardTime == "0 min" ? "Board now" : "Board in \(boardTime)"
        departureTimeLabel.textColor = late ? .liveRedColor : .primaryTextColor
        arrowImageView.tintColor = .primaryTextColor
        
        departureTimeLabel.sizeToFit()
        positionArrowVertically(usingDepartureTime: departureTimeLabel)
    }
    
    private func setTravelTime(withDepartureTime departureTime: Date, withArrivalTime arrivalTime: Date){
        travelTimeLabel.text = "\(Time.timeString(from: departureTime)) - \(Time.timeString(from: arrivalTime))"
        travelTimeLabel.sizeToFit()
    }
    
    private func setDepartureTimeToWalking() {
        departureTimeLabel.text = "Directions"
        departureTimeLabel.textColor = .mediumGrayColor
        arrowImageView.tintColor = .mediumGrayColor
        
        departureTimeLabel.sizeToFit()
        positionArrowVertically(usingDepartureTime: departureTimeLabel)
    }
    
    // MARK: Style

    private func styleTravelTime() {
        travelTimeLabel.font = UIFont(name: Constants.Fonts.SanFrancisco.Semibold, size: 16.0)
        travelTimeLabel.textColor = .primaryTextColor
        travelTimeLabel.sizeToFit()
    }

    private func styleLiveElements() {
        liveLabel.font = UIFont(name: Constants.Fonts.SanFrancisco.Semibold, size: 14.0)
        hideLiveElements()
    }

    private func styleDepartureTime() {
        departureTimeLabel.font = UIFont(name: Constants.Fonts.SanFrancisco.Semibold, size: 14.0)
        departureTimeLabel.textColor = .primaryTextColor
        departureTimeLabel.sizeToFit()
        arrowImageView.tintColor = .primaryTextColor
    }

    private func styleTopBorder() {
        topBorder.backgroundColor = .lineDotColor
    }

    private func styleBottomBorder() {
        bottomBorder.backgroundColor = .lineDotColor
    }

    private func styleCellSeperator() {
        cellSeperator.backgroundColor = .tableBackgroundColor
    }

    // MARK: Positioning

    func positionSubviews() {
        positionLiveLabel(usingTravelTime: travelTimeLabel)
        positionArrowHorizontally()
        positionDepartureTimeHorizontally(usingArrowImageView: arrowImageView)
        positionRouteDiagram(usingTravelTimeLabel: travelTimeLabel)

        routeDiagram.positionSubviews()

        styleCellSeperator()
        styleBottomBorder()

        positionCellSeperator(usingRouteDiagram: routeDiagram)
        positionBottomBorder(usingCellSeperator: cellSeperator)
    }

    private func positionTravelTime() {
        travelTimeLabel.frame = CGRect(x: timeLabelLeftSpaceFromSuperview, y: timeLabelVerticalSpaceFromSuperview, width: 50.5, height: 19)
    }

    private func positionLiveIndicatorView(usingTravelTime travelTimeLabel: UILabel) {
        liveIndicatorView.center.x = travelTimeLabel.frame.minX + (liveIndicatorView.frame.width/2)
        liveIndicatorView.center.y = travelTimeLabel.frame.maxY + liveIndicatorView.frame.height
    }
    
    private func positionLiveIndicatorView(usingLiveLabel liveLabel: UILabel) {
        liveIndicatorView.center.x =  liveLabel.frame.maxX + liveLabelHorizontalSpaceFromLiveIndicator + (liveIndicatorView.frame.width/2)
        liveIndicatorView.center.y = liveLabel.frame.maxY - liveIndicatorView.frame.height - 1
    }
    
    private func positionLiveLabel(usingTravelTime travelTimeLabel: UILabel) {
        liveLabel.frame = CGRect(x: travelTimeLabel.frame.minX, y: travelTimeLabel.frame.maxY, width: liveLabel.frame.width, height: liveLabel.frame.height)
    }

    private func positionDepartureTimeVertically(usingTravelTime travelTimeLabel: UILabel) {
        departureTimeLabel.frame = CGRect(x: 0, y: travelTimeLabel.frame.minY, width: 135, height: 20)
    }

    private func positionArrowVertically(usingDepartureTime departueTimeLabel: UILabel) {
        arrowImageView.center.y = departureTimeLabel.center.y
    }

    private func positionTopBorder() {
        topBorder.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: cellBorderHeight)
    }

    private func positionArrowHorizontally() {
        arrowImageView.center.x = contentView.frame.width - arrowImageViewRightSpaceFromSuperview - (arrowImageView.frame.width/2)
    }

    private func positionDepartureTimeHorizontally(usingArrowImageView arrowImageView: UIImageView) {
        departureTimeLabel.center.x = arrowImageView.frame.minX - departureLabelSpaceFromArrowImageView - (departureTimeLabel.frame.width/2)
    }

    private func positionRouteDiagram(usingTravelTimeLabel travelTimeLabel: UILabel) {
        routeDiagram.frame = CGRect(x: 0, y: travelTimeLabel.frame.maxY + timeLabelAndRouteDiagramVerticalSpace, width: UIScreen.main.bounds.width, height: 75)
    }

    private func positionCellSeperator(usingRouteDiagram routeDiagram: RouteDiagram) {
        cellSeperator.frame = CGRect(x: 0, y: contentView.frame.maxY - cellSeparatorHeight, width: UIScreen.main.bounds.width, height: cellSeparatorHeight)
    }

    private func positionBottomBorder(usingCellSeperator cellSeperator: UIView) {
        bottomBorder.frame = CGRect(x: 0, y: cellSeperator.frame.minY, width: UIScreen.main.bounds.width, height: cellBorderHeight)
    }

    // MARK: Add subviews

    func addSubviews() {
        routeDiagram.addSubviews()
        contentView.addSubview(routeDiagram)
        contentView.addSubview(cellSeperator)
        contentView.addSubview(bottomBorder)
    }

}
