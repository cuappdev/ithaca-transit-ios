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
    
    let identifier: String = "Route cell"
    var route: Route?
    
    // MARK: Network vars
    
    var timer: Timer?

    // MARK: View vars

    var travelTimeLabel: UILabel = UILabel()
    var liveIndicatorView = LiveIndicator(size: .small, color: .white)
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
        positionLiveLabel(usingTravelTime: travelTimeLabel)
        positionLiveIndicatorViewVertically(usingLiveLabel: liveLabel)
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
        
        // make live elements invisible
        setLiveElements(withStartTime: nil, withDelay: nil)
        
        // stop timer
        timer?.invalidate()
    }

    // MARK: Set Data

    func setData(_ route: Route) {
        self.route = route
        
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateLiveElementsWithDelay as () -> Void), userInfo: nil, repeats: true)
        
        let isWalkingRoute = route.isWalkingRoute()
        
        let firstDepartDirection = route.getFirstDepartDirection()

        if let firstDepartDirection = firstDepartDirection, let lastArriveDirection = route.getLastArriveDirection(){
            setTravelTime(withDepartureTime: firstDepartDirection.startTime, withArrivalTime: lastArriveDirection.endTime)
        }
        else {
            setTravelTime(withDepartureTime: route.departureTime, withArrivalTime: route.arrivalTime)
        }
        
        if let firstDepartDirection = firstDepartDirection {
            setDepartureTime(withTime: firstDepartDirection.startTime.addingTimeInterval(TimeInterval(firstDepartDirection.delay!)), withWalkingRoute: isWalkingRoute)
            setLiveElements(withStartTime: firstDepartDirection.startTime, withDelay: firstDepartDirection.delay)
        }
        else {
            setDepartureTime(withTime: route.departureTime, withWalkingRoute: isWalkingRoute)
        }
        
        routeDiagram.setData(withDirections: route.directions, withTravelDistance: route.travelDistance, withWalkingRoute: isWalkingRoute)
    }
    
    @objc func updateLiveElementsWithDelay() {
        if let route = route, let direction = route.getFirstDepartDirection(), let tripId = direction.tripIdentifiers?.first, let stopId = direction.stops.first?.id  {
            Network.getDelay(tripId: tripId, stopId: stopId).perform(withSuccess: { (json) in
                if json["success"].boolValue {
                    self.setLiveElements(withStartTime: direction.startTime, withDelay: json["data"]["delay"].int)
                }
                else {
                    self.setLiveElements(withStartTime: nil, withDelay: nil)
                }
            }, failure: { (error) in
                print("RouteTableViewCell setLiveElements(withStartTime:, withDelay:) error: \(error.errorDescription ?? "") Request url: \(error.request?.url?.absoluteString ?? "")")
                self.setLiveElements(withStartTime: nil, withDelay: nil)
            })
        }
        else {
            self.setLiveElements(withStartTime: nil, withDelay: nil)
        }
        
    }

    private func setLiveElements(withStartTime startTime: Date?, withDelay delay: Int?) {
        if let delay = delay, let startTime = startTime {
            if delay > 0 {
                liveLabel.textColor = .liveRedColor
                liveLabel.text = "Late - \(Time.timeString(from: startTime.addingTimeInterval(TimeInterval(delay))))"
                liveIndicatorView.setColor(to: .liveRedColor)
                
                let time = Time.timeString(from: Date(), to: startTime.addingTimeInterval(TimeInterval(delay)))
                departureTimeLabel.text = "Board in \(time)"
                departureTimeLabel.textColor = .liveRedColor
            } else {
                liveLabel.textColor = .liveGreenColor
                liveLabel.text = "On Time"
                liveIndicatorView.setColor(to:.liveGreenColor)
                
                departureTimeLabel.textColor = .liveGreenColor
            }
            liveLabel.sizeToFit()
            positionLiveIndicatorViewHorizontally(usingLiveLabel: liveLabel)
        } else {
            liveIndicatorView.setColor(to:.white)
            liveLabel.textColor = .white
            
            if let route = route {
                setDepartureTime(withTime: route.departureTime, withWalkingRoute: route.isWalkingRoute())
            }
        }
    }


    private func setTravelTime(withDepartureTime departureTime: Date, withArrivalTime arrivalTime: Date){
        travelTimeLabel.text = "\(Time.timeString(from: departureTime)) - \(Time.timeString(from: arrivalTime))"
        travelTimeLabel.sizeToFit()
    }

    private func setDepartureTime(withTime departureTime: Date, withWalkingRoute isWalkingRoute: Bool){
        if isWalkingRoute {
            departureTimeLabel.text = "Directions"
            departureTimeLabel.textColor = .mediumGrayColor
            arrowImageView.tintColor = .mediumGrayColor
        } else {
            let time = Time.timeString(from: Date(), to: departureTime)
            departureTimeLabel.text = "Board in \(time)"
            departureTimeLabel.textColor = .primaryTextColor
            arrowImageView.tintColor = .primaryTextColor
        }
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
        // style live elements to be invisible before get live data
        liveIndicatorView = LiveIndicator(size: .small, color: .green)
        liveLabel.font = UIFont(name: Constants.Fonts.SanFrancisco.Semibold, size: 14.0)
        liveLabel.textColor = .white
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
        positionLiveIndicatorViewHorizontally(usingLiveLabel: liveLabel)
        positionLiveIndicatorViewVertically(usingLiveLabel: liveLabel)
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

    private func positionLiveIndicatorViewHorizontally(usingLiveLabel liveLabel: UILabel) {
        liveIndicatorView.frame.origin.x =  liveLabel.frame.maxX + liveLabelHorizontalSpaceFromLiveIndicator
    }
    
    private func positionLiveIndicatorViewVertically(usingLiveLabel liveLabel: UILabel) {
        liveIndicatorView.frame.origin.y = liveLabel.center.y - (liveIndicatorView.frame.height / 2)
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
