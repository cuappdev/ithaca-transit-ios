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
    
    var destinationHasBus : Bool?
    var route: Route?
    var busDirection : Direction?
    var showLiveElements : Bool = true
    
    // MARK: Log vars
    
    var rowNum: Int?
    
    // MARK: View vars
    
    var departureLabel = UILabel()
    var destinationLabel = UILabel()
    var liveLabel = UILabel()
    var liveIndicatorView = LiveIndicator(size: .large, color: Colors.liveGreen)
    var busIcon: BusIcon?
    
    // MARK: Spacing vars
    
    let leftMargin: CGFloat =  12
    let verticalMargin: CGFloat = 20 // top & bottom margin
    let rightMargin: CGFloat = 16
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if
            let route = route,
            let departDirection = (route.directions.filter{ $0.type == .depart }).first {
                destinationHasBus = true
                busDirection = departDirection
                busIcon = BusIcon(type: .directionSmall, number: departDirection.routeNumber)
        } else { // THERE IS NO BUS TO THIS DESTINATION! -- how to handle this case?
            destinationHasBus = false
            busIcon = BusIcon(type: .directionSmall, number: 90)
        }
        
        departureLabel.font = .getFont(.medium, size: 16.0)
        
        departureLabel.textColor = Colors.primaryText
        departureLabel.text = "Ithaca Commons at Green Street Station"
        if let direction = busDirection {
            departureLabel.text = direction.name
        }
        departureLabel.numberOfLines = 1
        departureLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        destinationLabel.font = .getFont(.regular, size: 16.0)
        destinationLabel.textColor = Colors.secondaryText
        destinationLabel.numberOfLines = 1
        destinationLabel.text = "11:50 AM to Ithaca Commons at Green Street Station"
        destinationLabel.lineBreakMode = .byTruncatingTail
        
        liveLabel.font = .getFont(.medium, size: 16.0)
        liveLabel.textColor = Colors.primaryText
        liveLabel.text = "Board in 10 mins"
        
        setUpDestinationLabel()
        setUpLiveElements()
        
        contentView.addSubview(departureLabel)
        contentView.addSubview(destinationLabel)
        contentView.addSubview(liveLabel)
        contentView.addSubview(liveIndicatorView)
        if let busIcon = busIcon {
            contentView.addSubview(busIcon)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let busIcon = busIcon {
            busIcon.snp.makeConstraints { (make) in
                make.top.equalTo(verticalMargin)
                make.leading.equalTo(leftMargin)
                make.height.equalTo(24)
                make.width.equalTo(48)
            }
        }
        
        departureLabel.snp.makeConstraints { (make) in
            make.top.equalTo(verticalMargin)
            if let busIcon = busIcon {
                make.leading.equalTo(busIcon.snp.trailing).offset(leftMargin)
            }
            make.trailing.lessThanOrEqualToSuperview().inset(rightMargin)
            make.height.equalTo(departureLabel.intrinsicContentSize.height)
            make.width.equalTo(departureLabel.intrinsicContentSize.width)
        }
        
        destinationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(departureLabel.snp.bottom).offset(2)
            make.leading.equalTo(departureLabel)
            make.trailing.lessThanOrEqualToSuperview().inset(rightMargin)
            make.height.equalTo(destinationLabel.intrinsicContentSize.height)
        }
        
        if showLiveElements {
            liveLabel.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().inset(verticalMargin)
                make.leading.equalTo(departureLabel)
                make.height.equalTo(liveLabel.intrinsicContentSize.height)
                make.width.equalTo(liveLabel.intrinsicContentSize.width)
            }
        
            liveIndicatorView.snp.makeConstraints { (make) in
                make.centerY.equalTo(liveLabel.snp.centerY)
                make.leading.equalTo(liveLabel.snp.trailing).offset(8)
                make.trailing.lessThanOrEqualTo(rightMargin)
                make.width.equalTo(liveIndicatorView.intrinsicContentSize.width)
            }
        }
    }
    
    func setUpData(route: Route, rowNum: Int) {
        self.route = route
        self.rowNum = rowNum
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
        }
        else {
            return .noDelay(date: departTime)
        }
    }
    
    func setUpDestinationLabel() {
        if let route = route, let direction = busDirection {
            let delayState = getDelayState(fromDirection: direction)
            
            switch delayState {
            case .late(date: let delayedDepartureTime):
                destinationLabel.text = "\(delayedDepartureTime) to \(route.endName)"
                
            case .onTime(date: let departureTime), .noDelay(date: let departureTime):
                destinationLabel.text = "\(departureTime) to \(route.endName)"
            }
        } else {
           // there was no route or direction
        }
    }
    
    func setUpLiveElements() {
        if let direction = busDirection {
            let delayState = getDelayState(fromDirection: direction)
            switch delayState {
            case .late(date: let delayedDepartureTime):
                liveLabel.textColor = Colors.lateRed
                let boardTime = Time.timeString(from: direction.startTime, to: delayedDepartureTime)
                liveLabel.text = (boardTime == "0 min" ? "Board now" : "Board in \(boardTime)")
                liveIndicatorView.setColor(to: Colors.lateRed)
                contentView.addSubview(liveLabel)
                contentView.addSubview(liveIndicatorView)
                
            case .onTime(date: let departureTime):
                liveLabel.textColor = Colors.liveGreen
                let boardTime = Time.timeString(from: direction.startTime, to: departureTime)
                liveLabel.text = (boardTime == "0 min" ? "Board now" : "Board in \(boardTime)")
                liveIndicatorView.setColor(to: Colors.liveGreen)
                
                contentView.addSubview(liveLabel)
                contentView.addSubview(liveIndicatorView)
                
            case .noDelay(date: _):
                showLiveElements = false
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
