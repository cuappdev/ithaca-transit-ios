//
//  RouteDiagram.swift
//  TCAT
//
//  Created by Monica Ong on 7/2/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class RouteDiagramElement: NSObject {

    var stopLabel: UILabel
    
    var stopDot: Circle
    var icon: UIView?
    var stayOnBusCoverUpView: UIView?
    var routeLine: RouteLine?
    
    init(stopLabel: UILabel, stopDot: Circle, icon: UIView?, routeLine: RouteLine?) {
        self.stopLabel = stopLabel
        self.stopDot = stopDot
        self.icon = icon
        self.routeLine = routeLine
    }
    
}

class RouteDiagram: UIView {

    // MARK:  View vars

    var routeDiagramElements: [RouteDiagramElement] = []

    // MARK: Spacing vars

    let stopDotLeftSpaceFromSuperview: CGFloat = 77.0
    static let walkLineHeight: CGFloat = 20.0
    static let busLineHeight: CGFloat = 28.0
    let busIconLeftSpaceFromSuperview: CGFloat = 16.0
    let walkIconAndRouteLineHorizontalSpace: CGFloat = 36.0
    let stopDotAndStopLabelHorizontalSpace: CGFloat = 14.0
    let stopLabelAndDistLabelHorizontalSpace: CGFloat = 5.5

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK:  Reuse

    func prepareForReuse() {
        for routeDiagramElement in routeDiagramElements {
            routeDiagramElement.stopLabel.removeFromSuperview()

            routeDiagramElement.stopDot.removeFromSuperview()
            routeDiagramElement.icon?.removeFromSuperview()
            routeDiagramElement.stayOnBusCoverUpView?.removeFromSuperview()
            routeDiagramElement.routeLine?.removeFromSuperview()
        }

        routeDiagramElements.removeAll()
    }

    // MARK: Set Data

    func setData(withDirections directions: [Direction], withTravelDistance travelDistance: Double, withWalkingRoute isWalkingRoute: Bool) {
        var first = 0
        var stayOnBusForTransfer = false
        
        for (index, direction) in directions.enumerated() {
            // if not walking route, skip first walking direction
            if !isWalkingRoute && index == first && direction.type == .walk {
                first += 1
                continue
            }
            
            // if route is not walking route and if on first stop in route, will have travel distance in stop label
            let stopLabel = getStopLabel(withName: direction.name, withStayOnBusForTranfer: stayOnBusForTransfer, withDistance: !isWalkingRoute && index == first ? travelDistance : nil)
            let stopDot = getStopDot(fromDirections: directions, atIndex: index, withWalkingRoute: isWalkingRoute)
            let icon = getIcon(fromDirections: directions, atIndex: index, withDistance: isWalkingRoute && index == first ? travelDistance: nil)
            let routeLine = getRouteLine(fromDirections: directions, atIndex: index, withWalkingRoute: isWalkingRoute)
            
            let routeDiagramElement = RouteDiagramElement(stopLabel: stopLabel, stopDot: stopDot, icon: icon, routeLine: routeLine)
            
            if stayOnBusForTransfer {
                routeDiagramElement.stayOnBusCoverUpView = getStayOnBusCoverUpView()
            }
            stayOnBusForTransfer = direction.stayOnBusForTransfer
            
            routeDiagramElements.append(routeDiagramElement)
        }
    }

    // MARK: Get data from route ojbect
    
    private func getStopLabel(withName name: String, withStayOnBusForTranfer stayOnBusForTranfer: Bool, withDistance distance: Double?) -> UILabel {
        let yPos: CGFloat = 101
        let rightSpaceFromSuperview: CGFloat = 16
        let width: CGFloat = UIScreen.main.bounds.width - yPos - rightSpaceFromSuperview

        let stopLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 17))
        // allow for multi-line label for long stop names
        stopLabel.allowsDefaultTighteningForTruncation = true
        stopLabel.lineBreakMode = .byWordWrapping
        stopLabel.numberOfLines = 0
        
        let stopNameAttrs = [NSAttributedStringKey.font : UIFont(name: FontNames.SanFrancisco.Regular, size: 14.0), NSAttributedStringKey.foregroundColor : UIColor.primaryTextColor]
        let stopName = NSMutableAttributedString(string: name, attributes: stopNameAttrs)

        if let distance = distance {
            let testStopLabel = getTestStopLabel(withName: name)
            let testDistanceLabel = getTestDistanceLabel(withDistance: distance)
            
            var addLinebreak = false
            if(testStopLabel.frame.width + testDistanceLabel.frame.width > width) {
                addLinebreak = true
            }
            
            let travelDistanceAttrs = [NSAttributedStringKey.font : UIFont(name: FontNames.SanFrancisco.Regular, size: 12.0), NSAttributedStringKey.foregroundColor : UIColor.mediumGrayColor]
            let travelDistance = NSMutableAttributedString(string: addLinebreak ? "\n\(roundedString(distance)) away" : " \(roundedString(distance)) away", attributes: travelDistanceAttrs)
            stopName.append(travelDistance)
        }
        
        if stayOnBusForTranfer {
            let stayOnBusAttrs = [NSAttributedStringKey.font : UIFont(name: FontNames.SanFrancisco.Regular, size: 12.0), NSAttributedStringKey.foregroundColor : UIColor.mediumGrayColor]
            let stayOnBus = NSMutableAttributedString(string:"\nStay on board", attributes: stayOnBusAttrs)
            stopName.append(stayOnBus)
        }
        
        stopLabel.attributedText = stopName
        stopLabel.sizeToFit()
        
        return stopLabel
    }
    
    private func getTestStopLabel(withName name: String) -> UILabel {
        let testStopLabel = UILabel()
        testStopLabel.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 14.0)
        testStopLabel.textColor = .primaryTextColor
        testStopLabel.text = name
        testStopLabel.sizeToFit()
    
        return testStopLabel
    }
    
    private func getTestDistanceLabel(withDistance distance: Double) -> UILabel {
        let testDistanceLabel = UILabel()
        testDistanceLabel.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 12.0)
        testDistanceLabel.textColor = .mediumGrayColor
        testDistanceLabel.text = " \(roundedString(distance)) away"
        testDistanceLabel.sizeToFit()
        
        return testDistanceLabel
    }

    private func getStopDot(fromDirections directions: [Direction], atIndex index: Int, withWalkingRoute isWalkingRoute: Bool) -> Circle {
        let directionType = directions[index].type
        var pin: Circle
        let destinationDot = directions.count - 1

        switch directionType {

            case .walk:

                if(index == destinationDot) {
                    let framedGreyCircle = Circle(size: .medium, color: .mediumGrayColor, style: .bordered)
                    framedGreyCircle.backgroundColor = .white

                    pin = framedGreyCircle
                } else {
                    let solidGreyCircle = Circle(size: .small, color: .mediumGrayColor, style: .solid)

                    pin = solidGreyCircle
                }

            default:

                if(index == destinationDot) {
                    if isWalkingRoute {
                        // walking route destination should always be grey no matter what direction type
                        let framedGreyCircle = Circle(size: .medium, color: .mediumGrayColor, style: .bordered)
                        framedGreyCircle.backgroundColor = .white

                        pin = framedGreyCircle
                    } else {
                        let framedBlueCircle = Circle(size: .medium, color: .tcatBlueColor, style: .bordered)
                        framedBlueCircle.backgroundColor = .white

                        pin = framedBlueCircle
                    }
                } else {
                    let solidBlueCircle = Circle(size: .small, color: .tcatBlueColor, style: .solid)

                    pin = solidBlueCircle
                }

        }

        return pin
    }

    private func getIcon(fromDirections directions: [Direction], atIndex index: Int, withDistance distance: Double?) -> UIView? {
        if let distance = distance {            
            return WalkWithDistanceIcon(withDistance: distance)
        }
        
        let last = directions.count - 1
        if index == last {
            return nil
        }

        let directionType = directions[index].type
        switch directionType {

            case .depart:
                let busNum = directions[index].routeNumber
                let busIcon = BusIcon(type: .directionSmall, number: busNum)
                return busIcon

            default:
                let walkIcon = UIImageView(image: #imageLiteral(resourceName: "walk"))
                walkIcon.contentMode = .scaleAspectFit
                walkIcon.tintColor = .mediumGrayColor
                return walkIcon

        }

    }

    private func getRouteLine(fromDirections directions: [Direction], atIndex index: Int, withWalkingRoute isWalkingRoute: Bool) -> RouteLine? {
        let last = directions.count - 1
        if index == last {
            return nil
        }

        if isWalkingRoute {
            let greyRouteLine = SolidLine(height: RouteDiagram.walkLineHeight, color: .mediumGrayColor)

            return greyRouteLine
        }

        let directionType = directions[index].type
        switch directionType {

            case .depart:
                let solidBlueRouteLine = SolidLine(height: RouteDiagram.busLineHeight, color: .tcatBlueColor)

                return solidBlueRouteLine

            default:
                let dashedGreyRouteLine = DottedLine(height: RouteDiagram.walkLineHeight, color: .mediumGrayColor)

                return dashedGreyRouteLine

        }

    }
    
    private func getStayOnBusCoverUpView() -> UIView {
        let busIconWidth: CGFloat = 48
        let spaceBtnBusIcons: CGFloat = 15.0
        
        let stayOnBusCoverUpView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: busIconWidth, height: spaceBtnBusIcons + 6)))
        stayOnBusCoverUpView.backgroundColor = .tcatBlueColor
        
        return stayOnBusCoverUpView
    }

    // MARK: Position

    func positionSubviews() {

        for i in routeDiagramElements.indices {

            let stopDot = routeDiagramElements[i].stopDot
            let stopLabel = routeDiagramElements[i].stopLabel

            positionStopDot(stopDot, atIndex: i)
            positionStopLabelVertically(stopLabel, usingStopDot: stopDot)

            let first = 0
            if i == first {
                positionFirstStopLabelHorizontally(stopLabel, usingStopDot: stopDot)
            } else{
                let prevStopLabel = routeDiagramElements[i-1].stopLabel
                positionStopLabelHorizontally(stopLabel, usingPrevStopLabel: prevStopLabel)
            }
            
            if let routeLine = routeDiagramElements[i].routeLine {
                positionRouteLine(routeLine, usingStopDot: stopDot)
            }

            if let routeLine = routeDiagramElements[i].routeLine,
               let icon = routeDiagramElements[i].icon {
                positionIcon(icon, usingRouteLine: routeLine)
            }
            
            if let stayOnBusCoverUpView = routeDiagramElements[i].stayOnBusCoverUpView {
                positionStayOnBusCoverUpView(stayOnBusCoverUpView, usingStopDot: routeDiagramElements[i].stopDot)
            }

        }
        
        if let walkWithDistanceIcon = routeDiagramElements.first?.icon as? WalkWithDistanceIcon,
            let routeLine = routeDiagramElements.first?.routeLine {
            positionWalkWithDistanceIcon(walkWithDistanceIcon, usingRouteLine: routeLine, usingNextIcon: routeDiagramElements[1].icon)
        }
        
        resizeHeight()
    }

    private func positionStopDot(_ stopDot: Circle, atIndex index: Int) {
        let firstDot = 0

        if(index == firstDot) {

            stopDot.center.x = stopDotLeftSpaceFromSuperview + (stopDot.frame.width/2)
            stopDot.center.y = (stopDot.frame.height/2)

        }
        else {

            let previousRouteLine = routeDiagramElements[index-1].routeLine
            let previousStopDot = routeDiagramElements[index-1].stopDot

            stopDot.center.x = previousStopDot.center.x
            stopDot.center.y = (previousRouteLine?.frame.maxY ?? (previousStopDot.frame.maxY + RouteDiagram.walkLineHeight)) + (stopDot.frame.height/2)

        }

    }

    private func positionFirstStopLabelHorizontally(_ stopLabel: UILabel, usingStopDot stopDot: Circle) {
        let oldFrame = stopLabel.frame
        let newFrame = CGRect(x: stopDot.frame.maxX + stopDotAndStopLabelHorizontalSpace, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height)

        stopLabel.frame = newFrame
    }

    private func positionStopLabelVertically(_ stopLabel: UILabel, usingStopDot stopDot: Circle) {
        let testStopLabel = getTestStopLabel(withName: stopLabel.text!)
        let oldFrame = stopLabel.frame
        let newFrame = CGRect(x: oldFrame.minX, y: stopDot.center.y - (testStopLabel.frame.height/2), width: oldFrame.width, height: oldFrame.height)
        
        stopLabel.frame = newFrame
    }

    private func positionStopLabelHorizontally(_ stopLabel: UILabel, usingPrevStopLabel prevStopLabel: UILabel) {
        let oldFrame = stopLabel.frame
        let newFrame = CGRect(x: prevStopLabel.frame.minX, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height)

        stopLabel.frame = newFrame
    }
    
    private func positionTravelDistanceLabel(_ travelDistanceLabel: UILabel, usingStopLabel stopLabel: UILabel) {
        let oldFrame = travelDistanceLabel.frame
        let newFrame = CGRect(x: stopLabel.frame.maxX + stopLabelAndDistLabelHorizontalSpace, y: stopLabel.frame.minY, width: oldFrame.width, height: oldFrame.height)
        
        travelDistanceLabel.frame = newFrame
    }

    private func positionRouteLine(_ routeLine: RouteLine, usingStopDot stopDot: Circle) {
        routeLine.center.x = stopDot.center.x

        let oldFrame = routeLine.frame
        let newFrame = CGRect(x: oldFrame.minX, y: stopDot.frame.maxY, width: oldFrame.width, height: oldFrame.height)

        routeLine.frame = newFrame
    }
    
    private func positionIcon(_ icon: UIView, usingRouteLine routeLine: RouteLine) {
        if icon is BusIcon {
            positionBusIcon(icon as! BusIcon, usingRouteLine: routeLine)
        }
        else if icon is UIImageView {
            positionWalkIcon(icon as! UIImageView, usingRouteLine: routeLine)
        }
    }

    private func positionWalkIcon(_ walkIcon: UIImageView, usingRouteLine routeLine: RouteLine) {
        walkIcon.center.x = routeLine.frame.minX - walkIconAndRouteLineHorizontalSpace - (walkIcon.frame.width/2)
        walkIcon.center.y = routeLine.center.y
    }

    private func positionBusIcon(_ busIcon: BusIcon, usingRouteLine routeLine: RouteLine) {
        busIcon.center.x = busIconLeftSpaceFromSuperview + (busIcon.frame.width/2)
        busIcon.center.y = routeLine.center.y
    }
    
    private func positionStayOnBusCoverUpView(_ stayOnBusCoverUpView: UIView, usingStopDot stopDot: Circle) {
        stayOnBusCoverUpView.center.x = busIconLeftSpaceFromSuperview + (stayOnBusCoverUpView.frame.width/2)
        stayOnBusCoverUpView.center.y = stopDot.center.y
    }
    
    private func positionWalkWithDistanceIcon(_ walkWithDistanceIcon: WalkWithDistanceIcon, usingRouteLine routeLine: RouteLine, usingNextIcon nextIcon: UIView?) {
        if let nextIcon = nextIcon {
            walkWithDistanceIcon.center.x = nextIcon.center.x
            walkWithDistanceIcon.center.y = routeLine.center.y
        }
        else {
            let walkWithDistanceIconAndRouteLineHorizontalSpace: CGFloat = 22.0
            
            walkWithDistanceIcon.center.x = routeLine.frame.minX - walkWithDistanceIconAndRouteLineHorizontalSpace - (walkWithDistanceIcon.frame.width/2)
            walkWithDistanceIcon.center.y = routeLine.center.y
        }
    }

    // MARK: Add subviews

    func addSubviews() {

        for routeDiagramElement in routeDiagramElements {
            let stopDot = routeDiagramElement.stopDot
            let stopLabel = routeDiagramElement.stopLabel

            addSubview(stopDot)
            addSubview(stopLabel)
            
            if let routeLine = routeDiagramElement.routeLine {
                addSubview(routeLine)
            }

            if let icon = routeDiagramElement.icon {
                addSubview(icon)
            }
            
            if let stayOnBusCoverUpView = routeDiagramElement.stayOnBusCoverUpView {
                addSubview(stayOnBusCoverUpView)
            }
        }

    }

    private func resizeHeight() {
        if let firstStopLabel = routeDiagramElements.first?.stopLabel, let lastStopLabel = routeDiagramElements.last?.stopLabel {
            let resizedHeight = lastStopLabel.frame.maxY - firstStopLabel.frame.minY
            
            let oldFrame = frame
            let newFrame = CGRect(x: oldFrame.minX, y: oldFrame.minY, width: oldFrame.width, height: resizedHeight)
            
            frame = newFrame
        }
    }
}
