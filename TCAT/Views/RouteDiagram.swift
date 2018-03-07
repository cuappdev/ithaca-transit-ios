//
//  RouteDiagram.swift
//  TCAT
//
//  Created by Monica Ong on 7/2/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class RouteDiagramElement: NSObject {

    var stopLabel: UILabel = UILabel()
    var travelDistanceLabel: UILabel?
    var stayOnBusLabel: UILabel?
    
    var stopDot: Circle = Circle(size: .small, color: .tcatBlueColor, style: .solid)
    var icon: UIView?
    var routeLine: RouteLine?
    
}

class RouteDiagram: UIView {

    // MARK:  View vars

    var routeDiagramElements: [RouteDiagramElement] = []

    // MARK: Spacing vars

    let stopDotLeftSpaceFromSuperview: CGFloat = 77.0
    static let routeLineHeight: CGFloat = 20.0
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
            routeDiagramElement.travelDistanceLabel?.removeFromSuperview()
            routeDiagramElement.stayOnBusLabel?.removeFromSuperview()

            routeDiagramElement.stopDot.removeFromSuperview()
            routeDiagramElement.icon?.removeFromSuperview()
            routeDiagramElement.routeLine?.removeFromSuperview()
        }

        routeDiagramElements.removeAll()
    }

    // MARK: Set Data

    func setData(withDirections directions: [Direction], withTravelDistance travelDistance: Double, withWalkingRoute isWalkingRoute: Bool) {
        var first = 0
        for index in directions.indices {
            // if not walking route, skip first walking direction
            if !isWalkingRoute && index == first && directions[first].type == .walk {
                first += 1
                continue
            }

            let routeDiagramElement = RouteDiagramElement()
            // if first stop in route and is not walking route, will have travel distance
            if (!isWalkingRoute && index == first) {
                routeDiagramElement.travelDistanceLabel = getTravelDistanceLabel(withDistance: travelDistance, withWalkingRoute: isWalkingRoute)
            }
            
            routeDiagramElement.stopLabel = getStopLabel(withName: directions[index].name)
            routeDiagramElement.stopDot = getStopDot(fromDirections: directions, atIndex: index, withWalkingRoute: isWalkingRoute)
            routeDiagramElement.icon = getIcon(fromDirections: directions, atIndex: index, withTravelDistanceLabel: isWalkingRoute && index == first ? getTravelDistanceLabel(withDistance: travelDistance, withWalkingRoute: isWalkingRoute) : nil)
            routeDiagramElement.routeLine = getRouteLine(fromDirections: directions, atIndex: index, withWalkingRoute: isWalkingRoute)

            routeDiagramElements.append(routeDiagramElement)
        }
    }

    // MARK: Get data from route ojbect

    private func getTravelDistanceLabel(withDistance distance: Double, withWalkingRoute isWalkingRoute: Bool) -> UILabel {
        let travelDistanceLabel = UILabel()
        travelDistanceLabel.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 12.0)
        travelDistanceLabel.textColor = .mediumGrayColor
        
        if distance > 0  {
            travelDistanceLabel.text = isWalkingRoute ? "\(roundedString(distance))" : "\(roundedString(distance)) away"
            travelDistanceLabel.sizeToFit()
        }
        
        return travelDistanceLabel
    }
    
    private func getStopLabel(withName name: String) -> UILabel {
        let yPos: CGFloat = 101
        let rightSpaceFromSuperview: CGFloat = 16
        let width: CGFloat = UIScreen.main.bounds.width - yPos - rightSpaceFromSuperview

        let stopLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 17))
        
        stopLabel.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 14.0)
        stopLabel.textColor = .primaryTextColor
        stopLabel.allowsDefaultTighteningForTruncation = true
        stopLabel.lineBreakMode = .byWordWrapping
        stopLabel.numberOfLines = 0
        
        stopLabel.text = name
        stopLabel.sizeToFit()

        return stopLabel
    }

    private func getStopDot(fromDirections directions: [Direction], atIndex index: Int, withWalkingRoute isWalkingRoute: Bool) -> Circle {
        let directionType = directions[index].type
        var pin: Circle
        let destinationDot = directions.count - 1

        switch directionType {

            case .walk:

                if(index == destinationDot) {
                    let framedGreyCircle = Circle(size: .large, color: .mediumGrayColor, style: .bordered)
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
                        let framedGreyCircle = Circle(size: .large, color: .mediumGrayColor, style: .bordered)
                        framedGreyCircle.backgroundColor = .white

                        pin = framedGreyCircle
                    } else {
                        let framedBlueCircle = Circle(size: .large, color: .tcatBlueColor, style: .bordered)
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

    private func getIcon(fromDirections directions: [Direction], atIndex index: Int, withTravelDistanceLabel travelDistanceLabel: UILabel?) -> UIView? {
        if let travelDistanceLabel = travelDistanceLabel {
            let walkIcon = UIImageView(image: #imageLiteral(resourceName: "walk"))
            walkIcon.contentMode = .scaleAspectFit
            walkIcon.tintColor = .mediumGrayColor
            
            return WalkWithDistanceIcon(walkIcon: walkIcon, travelDistanceLabel: travelDistanceLabel)
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
            let greyRouteLine = SolidLine(height: RouteDiagram.routeLineHeight, color: .mediumGrayColor)

            return greyRouteLine
        }

        let directionType = directions[index].type
        switch directionType {

            case .depart:
                let solidBlueRouteLine = SolidLine(height: RouteDiagram.routeLineHeight, color: .tcatBlueColor)

                return solidBlueRouteLine

            default:
                let dashedGreyRouteLine = DottedLine(height: RouteDiagram.routeLineHeight, color: .mediumGrayColor)

                return dashedGreyRouteLine

        }

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
            
            if let travelDistanceLabel = routeDiagramElements[i].travelDistanceLabel {
                positionTravelDistanceLabel(travelDistanceLabel, usingStopLabel: routeDiagramElements[i].stopLabel)
            }
            
            if let routeLine = routeDiagramElements[i].routeLine {
                positionRouteLine(routeLine, usingStopDot: stopDot)
            }

            if let routeLine = routeDiagramElements[i].routeLine,
               let icon = routeDiagramElements[i].icon {
                positionIcon(icon, usingRouteLine: routeLine)
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
            stopDot.center.y = (previousRouteLine?.frame.maxY ?? (previousStopDot.frame.maxY + RouteDiagram.routeLineHeight)) + (stopDot.frame.height/2)

        }

    }

    private func positionFirstStopLabelHorizontally(_ stopLabel: UILabel, usingStopDot stopDot: Circle) {
        let oldFrame = stopLabel.frame
        let newFrame = CGRect(x: stopDot.frame.maxX + stopDotAndStopLabelHorizontalSpace, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height)

        stopLabel.frame = newFrame
    }

    private func positionStopLabelVertically(_ stopLabel: UILabel, usingStopDot stopDot: Circle) {
        stopLabel.center.y = stopDot.center.y
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

            if let travelDistanceLabel = routeDiagramElement.travelDistanceLabel {
                addSubview(travelDistanceLabel)
            }
            
            if let routeLine = routeDiagramElement.routeLine {
                addSubview(routeLine)
            }

            if let icon = routeDiagramElement.icon {
                addSubview(icon)
            }
        }

    }

    private func resizeHeight() {
        let firstStopDot = routeDiagramElements[0].stopDot
        let lastStopDot = routeDiagramElements[routeDiagramElements.count - 1].stopDot

        let resizedHeight = lastStopDot.frame.maxY - firstStopDot.frame.minY

        let oldFrame = frame
        let newFrame = CGRect(x: oldFrame.minX, y: oldFrame.minY, width: oldFrame.width, height: resizedHeight)

        frame = newFrame
    }
}
