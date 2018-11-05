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
    let topMargin: CGFloat = 16
    let spaceBtnStopDotAndStopLabel: CGFloat = 14
    
    let spaceBtnBusIconAndRouteLine: CGFloat = 19.5
    let spaceBtnWalkIconAndRouteLine: CGFloat = 38
    let spaceBtnWalkWithDistanceIconAndRouteLine: CGFloat = 24
    
    let spaceBtnWalkIconAndSuperview: CGFloat = 20
    
    let busIconType: BusIconType = .directionSmall
    let busIconCornerRadius: CGFloat = BusIconType.directionSmall.cornerRadius

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
        for (index, direction) in directions.enumerated() {
            // if not walking route, skip first walking direction
            if !isWalkingRoute && index == first && direction.type == .walk {
                first += 1
                continue
            }
            
            // if route is not walking route and if on first stop in route, will have travel distance in stop label
            let stopLabel = getStopLabel(withName: direction.name, withStayOnBusForTranfer: direction.stayOnBusForTransfer, withDistance: !isWalkingRoute && index == first ? travelDistance : nil)
            let stopDot = getStopDot(fromDirections: directions, atIndex: index, withWalkingRoute: isWalkingRoute)
            let icon = getIcon(fromDirections: directions, atIndex: index, withDistance: isWalkingRoute && index == first ? travelDistance: nil)
            let routeLine = getRouteLine(fromDirections: directions, atIndex: index, withWalkingRoute: isWalkingRoute, withStopLabel: stopLabel)
            
            let routeDiagramElement = RouteDiagramElement(stopLabel: stopLabel, stopDot: stopDot, icon: icon, routeLine: routeLine)
            
            if direction.stayOnBusForTransfer {
                routeDiagramElement.stayOnBusCoverUpView = getStayOnBusCoverUpView()
            }
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
        
        let stopNameAttrs: [NSAttributedString.Key : Any] = [
            .font : UIFont.style(Fonts.SanFrancisco.regular, size: 14.0),
            .foregroundColor : Colors.primaryText
        ]
        let stopName = NSMutableAttributedString(string: name, attributes: stopNameAttrs)

        if let distance = distance {

            let testStopLabel = getTestStopLabel(withName: name)
            let testDistanceLabel = getTestDistanceLabel(withDistance: distance)
            
            var addLinebreak = false
            if testStopLabel.frame.width + testDistanceLabel.frame.width > width {
                addLinebreak = true
            }
            
            let travelDistanceAttrs: [NSAttributedString.Key : Any] = [
                .font : UIFont.style(Fonts.SanFrancisco.regular, size: 12.0),
                .foregroundColor : Colors.metadataIcon
            ]
            
            let travelDistance = NSMutableAttributedString(string: addLinebreak ? "\n\(distance.roundedString) away" : " \(distance.roundedString) away", attributes: travelDistanceAttrs)
            stopName.append(travelDistance)
        }
        
        if stayOnBusForTranfer {
            let stayOnBusAttrs: [NSAttributedString.Key : Any] = [
                .font : UIFont.style(Fonts.SanFrancisco.regular, size: 12.0),
                .foregroundColor : Colors.metadataIcon
            ]
            let stayOnBus = NSMutableAttributedString(string:"\nStay on board", attributes: stayOnBusAttrs)
            stopName.append(stayOnBus)
        }
        
        stopLabel.attributedText = stopName
        stopLabel.sizeToFit()
        
        return stopLabel
    }
    
    private func getTestStopLabel(withName name: String) -> UILabel {
        let testStopLabel = UILabel()
        testStopLabel.font = .style(Fonts.SanFrancisco.regular, size: 14.0)
        testStopLabel.textColor = Colors.primaryText
        testStopLabel.text = name
        testStopLabel.sizeToFit()
    
        return testStopLabel
    }
    
    private func getTestDistanceLabel(withDistance distance: Double) -> UILabel {
        let testDistanceLabel = UILabel()
        testDistanceLabel.font = .style(Fonts.SanFrancisco.regular, size: 12.0)
        testDistanceLabel.textColor = Colors.metadataIcon
        testDistanceLabel.text = " \(distance.roundedString) away"
        testDistanceLabel.sizeToFit()
        
        return testDistanceLabel
    }
    
    private func isStopLabelOneLine(_ stopLabel: UILabel) -> Bool {
        let oneLineStopLabel = getStopLabel(withName: "Testing", withStayOnBusForTranfer: false, withDistance: 0.0)
        
        return stopLabel.intrinsicContentSize.height <= oneLineStopLabel.intrinsicContentSize.height
    }

    private func getStopDot(fromDirections directions: [Direction], atIndex index: Int, withWalkingRoute isWalkingRoute: Bool) -> Circle {
        let directionType = directions[index].type
        var pin: Circle
        let destinationDot = directions.count - 1

        switch directionType {

            case .walk:

                if index == destinationDot {
                    let framedGreyCircle = Circle(size: .medium, style: .bordered, color: Colors.metadataIcon)
                    framedGreyCircle.backgroundColor = Colors.white
                    pin = framedGreyCircle
                } else {
                    let solidGreyCircle = Circle(size: .small, style: .solid, color: Colors.metadataIcon)
                    pin = solidGreyCircle
                }

            default:

                if index == destinationDot {
                    if isWalkingRoute {
                        // walking route destination should always be grey no matter what direction type
                        let framedGreyCircle = Circle(size: .medium, style: .bordered, color: Colors.metadataIcon)
                        framedGreyCircle.backgroundColor = Colors.white
                        pin = framedGreyCircle
                    } else {
                        let framedBlueCircle = Circle(size: .medium, style: .bordered, color: Colors.tcatBlue)
                        framedBlueCircle.backgroundColor = Colors.white
                        pin = framedBlueCircle
                    }
                } else {
                    let solidBlueCircle = Circle(size: .small, style: .solid, color: Colors.tcatBlue)
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
                let busIcon = BusIcon(type: busIconType, number: busNum)
                return busIcon

            default:
                let walkIcon = UIImageView(image: #imageLiteral(resourceName: "walk"))
                walkIcon.contentMode = .scaleAspectFit
                walkIcon.tintColor = Colors.metadataIcon
                return walkIcon

        }

    }

    private func getRouteLine(fromDirections directions: [Direction], atIndex index: Int, withWalkingRoute isWalkingRoute: Bool, withStopLabel stopLabel: UILabel) -> RouteLine? {
        let last = directions.count - 1
        if index == last {
            return nil
        }
        
        let isStopLabelSingleLine = isStopLabelOneLine(stopLabel)

        if isWalkingRoute {
            let greyRouteLine = isStopLabelSingleLine ? SolidLine(color: Colors.metadataIcon) : SolidLine(height: RouteLine.extendedHeight, color: Colors.metadataIcon)

            return greyRouteLine
        }

        let directionType = directions[index].type
        switch directionType {

            case .depart:
                let solidBlueRouteLine = isStopLabelSingleLine ? SolidLine(color: Colors.tcatBlue) : SolidLine(height: RouteLine.extendedHeight, color: Colors.tcatBlue)

                return solidBlueRouteLine

            default:
                let dashedGreyRouteLine = isStopLabelSingleLine ? DottedLine(color: Colors.metadataIcon) : DottedLine(height: RouteLine.extendedHeight, color: Colors.metadataIcon)

                return dashedGreyRouteLine

        }

    }
    
    private func getStayOnBusCoverUpView() -> UIView {
        let busIconWidth: CGFloat = 48
        let spaceBtnBusIcons: CGFloat = 15.0
        
        let stayOnBusCoverUpView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: busIconWidth, height: spaceBtnBusIcons + 6)))
        stayOnBusCoverUpView.backgroundColor = Colors.tcatBlue
        
        return stayOnBusCoverUpView
    }

    // MARK: Activate constraints
    
    func activateConstraints() {
        setTranslatesAutoresizingMaskIntoConstraints()
        setDebugIdentifiers()
        
        if let first = routeDiagramElements.first {
            let stopDot = first.stopDot
            let stopLabel = first.stopLabel
            
            activateFirst(stopDot, stopLabel)
            
            if let routeLine = first.routeLine {
                activateFirst(routeLine, with: stopDot)
            }
            
            if let icon = first.icon, let routeLine = first.routeLine {
                activateFirst(icon, with: routeLine)
            }
        }
        
        let first = 0
        for (i, current) in routeDiagramElements.enumerated() {
            if i == first {
                continue
            }
            
            let prev = routeDiagramElements[i-1]
            
            let stopDot = current.stopDot
            
            if let prevRouteLine = prev.routeLine {
                activate(stopDot, with: prevRouteLine)
            }
            
            let stopLabel = current.stopLabel
            
            activate(stopLabel, with: stopDot, with: prev.stopLabel)
            
            if let routeLine = current.routeLine {
                activate(routeLine, with: stopDot)
            }
            
            if let icon = current.icon, let routeLine = current.routeLine {
                activate(icon, with: routeLine, with: prev)
            }
            
            if let stayOnBusCoverUpView = current.stayOnBusCoverUpView, let icon = current.icon {
                activate(stayOnBusCoverUpView, with: icon, with: prev)
            }
        }
        
        if let stopLabel = routeDiagramElements.last?.stopLabel {
            activateLast(stopLabel)
        }
    }
    
    private func activateFirst(_ stopDot: Circle, _ stopLabel: UILabel) {
        NSLayoutConstraint.activate([
            stopLabel.topAnchor.constraint(equalTo: topAnchor, constant: topMargin),
            stopLabel.leadingAnchor.constraint(equalTo: stopDot.trailingAnchor, constant: spaceBtnStopDotAndStopLabel),
            
            stopDot.topAnchor.constraint(equalTo: stopLabel.topAnchor),
        ])
    }
    
    private func activateFirst(_ routeLine: RouteLine, with stopDot: Circle) {
        NSLayoutConstraint.activate([
            routeLine.centerXAnchor.constraint(equalTo: stopDot.centerXAnchor),
            routeLine.topAnchor.constraint(equalTo: stopDot.bottomAnchor),
        ])
    }
    
    private func activateFirst(_ icon: UIView, with routeLine: RouteLine) {
        let spaceBtnIconAndRouteLine = icon is UIImageView ? spaceBtnWalkIconAndRouteLine : (icon is WalkWithDistanceIcon ? spaceBtnWalkWithDistanceIconAndRouteLine : spaceBtnBusIconAndRouteLine)
        let spaceBtnIconAndSuperview = icon is UIImageView ? spaceBtnWalkIconAndSuperview : 0
        
        NSLayoutConstraint.activate([
            icon.centerYAnchor.constraint(equalTo: routeLine.centerYAnchor),
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spaceBtnIconAndSuperview),
            icon.trailingAnchor.constraint(equalTo: routeLine.leadingAnchor, constant: -spaceBtnIconAndRouteLine)
        ])
    }
    
    private func activate(_ stopDot: Circle, with prevRouteLine: RouteLine) {
        NSLayoutConstraint.activate([
            stopDot.topAnchor.constraint(equalTo: prevRouteLine.bottomAnchor),
            stopDot.centerXAnchor.constraint(equalTo: prevRouteLine.centerXAnchor)
        ])
    }
    
    private func activate(_ stopLabel: UILabel, with stopDot: Circle, with prevStopLabel: UILabel) {
        NSLayoutConstraint.activate([
            stopLabel.leadingAnchor.constraint(equalTo: prevStopLabel.leadingAnchor),
            stopLabel.topAnchor.constraint(equalTo: stopDot.topAnchor)
        ])
    }
    
    private func activate(_ routeLine: RouteLine, with stopDot: Circle) {
        NSLayoutConstraint.activate([
            routeLine.topAnchor.constraint(equalTo: stopDot.bottomAnchor),
            routeLine.centerXAnchor.constraint(equalTo: stopDot.centerXAnchor)
        ])
    }
    
    private func activate(_ icon: UIView, with routeLine: RouteLine, with prev: RouteDiagramElement) {
        NSLayoutConstraint.activate([
            icon.centerYAnchor.constraint(equalTo: routeLine.centerYAnchor)
            ])
        
        if let prevIcon = prev.icon {
            NSLayoutConstraint.activate([
                icon.centerXAnchor.constraint(equalTo: prevIcon.centerXAnchor)
                ])
        }
    }
    
    private func activate(_ stayOnBusCoverUpView: UIView, with icon: UIView, with prev: RouteDiagramElement) {
        NSLayoutConstraint.activate([
            stayOnBusCoverUpView.centerXAnchor.constraint(equalTo: icon.centerXAnchor),
            stayOnBusCoverUpView.bottomAnchor.constraint(equalTo: icon.topAnchor, constant: busIconCornerRadius),
            stayOnBusCoverUpView.widthAnchor.constraint(equalToConstant: icon.intrinsicContentSize.width),
            ])
        
        if let prevIcon = prev.icon {
            NSLayoutConstraint.activate([
                stayOnBusCoverUpView.topAnchor.constraint(equalTo: prevIcon.bottomAnchor, constant: -busIconCornerRadius),
                ])
        }
    }
    
    private func activateLast(_ stopLabel: UILabel) {
        NSLayoutConstraint.activate([
            stopLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setTranslatesAutoresizingMaskIntoConstraints() {
        for routeDiagramElement in routeDiagramElements {
            routeDiagramElement.stopLabel.translatesAutoresizingMaskIntoConstraints = false
            routeDiagramElement.stopDot.translatesAutoresizingMaskIntoConstraints = false
            
            routeDiagramElement.icon?.translatesAutoresizingMaskIntoConstraints = false
            routeDiagramElement.stayOnBusCoverUpView?.translatesAutoresizingMaskIntoConstraints = false
            routeDiagramElement.routeLine?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    /// For debugging constraint errors
    private func setDebugIdentifiers() {
        for (i, routeDiagramElement) in routeDiagramElements.enumerated() {
            routeDiagramElement.stopLabel.accessibilityIdentifier = "stopLabel\(i)"
            routeDiagramElement.stopDot.accessibilityIdentifier = "stopDot\(i)"
            
            routeDiagramElement.icon?.accessibilityIdentifier = "icon\(i)"
            routeDiagramElement.stayOnBusCoverUpView?.accessibilityIdentifier = "stayOnBusCoverUpView\(i)"
            routeDiagramElement.routeLine?.accessibilityIdentifier = "routeLine\(i)"
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
        
        if let firstStopDot = routeDiagramElements.first?.stopDot,
            let lastStopDot = routeDiagramElements.last?.stopDot {
            let resizedHeight = lastStopDot.frame.maxY - firstStopDot.frame.minY
            let oldFrame = frame
            let newFrame = CGRect(x: oldFrame.minX, y: oldFrame.minY, width: oldFrame.width, height: resizedHeight)
            frame = newFrame
        }
        
    }
}
