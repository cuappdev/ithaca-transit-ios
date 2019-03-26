//
//  TodayExtensionCell.swift
//  TCAT
//
//  Created by Yana Sang on 11/24/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit

class TodayExtensionCell: UITableViewCell {

    // MARK: Data vars

    var busDirection: Direction?
    var destinationName: String = ""
    var route: Route?
    var showLiveElements: Bool = true

    // MARK: Log vars

    var rowNum: Int?

    // MARK: View vars

    var busIcon: BusIcon?
    var departureLabel = UILabel() // ex: To Baker Flagpole
    var destinationLabel = UILabel() // ex: 10:00 AM at Collegetown Crossing
    var liveLabel = UILabel()
    var liveIndicatorView = LiveIndicator(size: .small, color: .clear)

    // MARK: Spacing vars

    let leftMargin: CGFloat =  12.0
    let rightMargin: CGFloat = 16.0
    let verticalMargin: CGFloat = 20.0 // top & bottom margin

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(departureLabel)
        departureLabel.snp.makeConstraints { make in
            let leading: CGFloat = 74.0
            let bottom: CGFloat = 71.0
            
            make.top.equalToSuperview().inset(verticalMargin)
            make.bottom.equalToSuperview().inset(bottom)
            make.leading.equalToSuperview().inset(leading)
            make.trailing.lessThanOrEqualToSuperview().inset(rightMargin)
        }
        
        contentView.addSubview(destinationLabel)
        destinationLabel.snp.makeConstraints { make in
            let offset: CGFloat = 2.0
            let bottom: CGFloat = 50.0
            
            make.top.equalTo(departureLabel.snp.bottom).offset(offset)
            make.bottom.equalToSuperview().inset(bottom)
            make.leading.equalTo(departureLabel)
            make.trailing.lessThanOrEqualToSuperview().inset(rightMargin)
        }

        contentView.addSubview(liveLabel)
        contentView.addSubview(liveIndicatorView)
        if showLiveElements {
            liveLabel.snp.makeConstraints { make in
                let offset: CGFloat = 9.0
                
                make.top.equalTo(destinationLabel.snp.bottom).offset(offset)
                make.bottom.equalToSuperview().inset(verticalMargin)
                make.leading.equalTo(departureLabel)
                make.trailing.lessThanOrEqualTo(rightMargin)
            }
            
            liveIndicatorView.snp.makeConstraints { make in
                let offset: CGFloat = 8.0
                
                make.centerY.equalTo(liveLabel.snp.centerY)
                make.leading.equalTo(liveLabel.snp.trailing).offset(offset)
                make.trailing.lessThanOrEqualTo(rightMargin)
                make.height.equalTo(liveIndicatorView.intrinsicContentSize.height)
            }
        }
        
    }

    func configure(route: Route?, destination: String) {
        destinationName = destination
        if let route = route {
            self.route = route
            if let departDirection = (route.directions.filter { $0.type == .depart }).first {
                busDirection = departDirection
                busIcon = BusIcon(type: .directionSmall, number: departDirection.routeNumber)
                contentView.addSubview(busIcon!)
                
                if let busIcon = busIcon {
                    let bottom: CGFloat = 66.0
                    busIcon.snp.makeConstraints { make in
                        make.top.equalToSuperview().inset(verticalMargin)
                        make.bottom.equalToSuperview().inset(bottom)
                        make.leading.equalToSuperview().inset(leftMargin)
                        make.width.equalTo(busIcon.intrinsicContentSize.width)
                    }
                }
                
                setUpDepartureLabel()
                setUpDestinationLabel()
                setUpLiveElements()
                
            } else { // there is no bus to this destination (i.e. only walking)
                setUpNoRoute()
            }
        } else { // no route at all
            setUpNoRoute()
        }
    }

    func setUpNoRoute() {
        showLiveElements = false
        let noRouteLabel = UILabel()
        noRouteLabel.font = .getFont(.regular, size: 14.0)
        noRouteLabel.textColor = Colors.primaryText
        noRouteLabel.textAlignment = .center
        noRouteLabel.lineBreakMode = .byTruncatingTail
        noRouteLabel.text = Constants.TodayExtension.noRoutesAvailable + "\(destinationName)."

        contentView.addSubview(noRouteLabel)

        noRouteLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(12.0)
        }
    }

    func setUpDepartureLabel() {
        departureLabel.lineBreakMode = .byTruncatingTail
        departureLabel.font = .getFont(.medium, size: 16.0)
        departureLabel.textColor = Colors.primaryText
        departureLabel.font = .getFont(.medium, size: 16.0)
        departureLabel.textColor = Colors.primaryText
        if let route = route {
            departureLabel.text = "To \(route.endName)"
        }
    }

    private func getDelayState(fromDirection direction: Direction) -> DelayState {
        let departTime = direction.startTime
        if let delay = direction.delay {
            let delayedDepartTime = departTime.addingTimeInterval(TimeInterval(delay))

            if Time.compare(date1: delayedDepartTime, date2: departTime) != .orderedSame {
                return .late(date: delayedDepartTime)
            } else {
                return .onTime(date: departTime)
            }
        } else {
            return .noDelay(date: departTime)
        }
    }

    func setUpDestinationLabel() {
        destinationLabel.font = .getFont(.regular, size: 16.0)
        destinationLabel.textColor = Colors.secondaryText
        destinationLabel.lineBreakMode = .byTruncatingTail

        if let direction = busDirection {
            let delayState = getDelayState(fromDirection: direction)

            switch delayState {
            case .late(date: let delayedDepartureTime):
                destinationLabel.text = Time.timeString(from: delayedDepartureTime) + " at \(direction.name)"
            case .onTime(date: let departureTime), .noDelay(date: let departureTime):
                destinationLabel.text = Time.timeString(from: departureTime) + " at \(direction.name)"
            }
        }
    }

    func setUpLiveElements() {
        liveLabel.font = .getFont(.medium, size: 16.0)
        liveLabel.textColor = Colors.primaryText

        if let direction = busDirection {
            let delayState = getDelayState(fromDirection: direction)
            switch delayState {
            case .late(date: let delayedDepartureTime):
                liveLabel.textColor = Colors.lateRed
                let boardTime = Time.timeString(from: Date(), to: delayedDepartureTime)
                liveLabel.text = (boardTime == "0 min" ? "Board now" : "Board in \(boardTime)")
                liveIndicatorView.setColor(to: Colors.lateRed)
            case .onTime(date: let departureTime):
                liveLabel.textColor = Colors.liveGreen
                let boardTime = Time.timeString(from: Date(), to: departureTime)
                liveLabel.text = (boardTime == "0 min" ? "Board now" : "Board in \(boardTime)")
                liveIndicatorView.setColor(to: Colors.liveGreen)
            case .noDelay(date: _):
                showLiveElements = false
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
