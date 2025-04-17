//
//  RouteTableViewCell.swift
//  TCAT
//
//  Created by Monica Ong on 2/13/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import SwiftyJSON
import UIKit

class RouteTableViewCell: UITableViewCell {

    // MARK: - View vars
    private let arrowImageView = UIImageView(image: #imageLiteral(resourceName: "side-arrow"))
    private let containerView = UIView()
    private var departureStackView: UIStackView!
    private let departureTimeLabel = UILabel()
    private let liveContainerView = UIView()
    private let liveIndicatorView = LiveIndicator(size: .small, color: .clear)
    private let liveLabel = UILabel()
    private var routeDiagram: RouteDiagram!
    private let travelTimeLabel = UILabel()

    // MARK: - Data vars
    private let containerViewLayoutInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 12)

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerView)

        setupCellBackground()
        setupDepartureStackView()
        setupTravelTimeLabel()
        setupLiveContainerView()

        setupConstraints()
    }

    // MARK: - Style

    private func setupCellBackground() {
        let cornerRadius: CGFloat = 16

        layer.backgroundColor = UIColor.clear.cgColor
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        containerView.backgroundColor = Colors.white
        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.masksToBounds = true
    }

    private func setupDepartureStackView() {
        let spaceBtnDepartureElements: CGFloat = 4

        departureStackView = UIStackView(arrangedSubviews: [departureTimeLabel, arrowImageView])

        departureStackView.axis = .horizontal
        departureStackView.spacing = spaceBtnDepartureElements
        departureStackView.alignment = .center

        departureTimeLabel.font = .getFont(.semibold, size: 14)
        departureTimeLabel.textColor = Colors.primaryText
        arrowImageView.tintColor = Colors.metadataIcon

        containerView.addSubview(departureStackView)
    }

    private func setupTravelTimeLabel() {
        travelTimeLabel.font = .getFont(.semibold, size: 16)
        travelTimeLabel.textColor = Colors.primaryText

        containerView.addSubview(travelTimeLabel)
    }

    private func setupLiveContainerView() {
        liveLabel.font = .getFont(.semibold, size: 14)

        liveContainerView.addSubview(liveLabel)
        liveContainerView.addSubview(liveIndicatorView)

        setLiveIndicatorViewsConstraints()

        containerView.addSubview(liveContainerView)
    }

    private func setupConstraints() {
        let arrowImageViewSize = CGSize(width: 6, height: 11.5)
        let cellMargin: CGFloat = 12

        containerView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview().inset(cellMargin)
            make.top.equalToSuperview()
        }

        arrowImageView.snp.makeConstraints { make in
            make.size.equalTo(arrowImageViewSize)
        }

        travelTimeLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(containerViewLayoutInsets)
        }

        departureStackView.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(containerViewLayoutInsets)
        }

        liveContainerView.snp.makeConstraints { make in
            make.top.equalTo(travelTimeLabel.snp.bottom)
            make.leading.equalTo(travelTimeLabel)
            make.trailing.equalTo(departureStackView)
        }
    }

    private func setLiveIndicatorViewsConstraints() {
        let spaceBtnLiveElements: CGFloat = 4

        liveLabel.snp.remakeConstraints { make in
            make.leading.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        liveIndicatorView.snp.remakeConstraints { make in
            make.leading.equalTo(liveLabel.snp.trailing).offset(spaceBtnLiveElements)
            make.centerY.equalTo(liveLabel)
        }

    }

    private func setupDataDependentConstraints() {
        let routeDiagramTopOffset = 8

        liveContainerView.snp.makeConstraints { make in
            make.bottom.equalTo(routeDiagram.snp.top).offset(-routeDiagramTopOffset)
        }

        // Set trailing and bottom prioirites to .high to surpress constraint errors
        routeDiagram.snp.remakeConstraints { make in
            make.top.equalTo(liveContainerView.snp.bottom).offset(routeDiagramTopOffset)
            make.leading.equalTo(travelTimeLabel)
            make.trailing.equalTo(departureStackView).priority(.high)
            make.bottom.equalToSuperview().inset(containerViewLayoutInsets).priority(.high)
        }
    }

    // MARK: - Set Data

    func configure(for route: Route, delayState: DelayState? = nil) {

        setTravelTime(withDepartureTime: route.departureTime, withArrivalTime: route.arrivalTime)

        setDepartureTimeAndLiveElements(withRoute: route)

        if let delay = delayState {
            setLiveElements(withDelayState: delay)
            setDepartureTime(withStartTime: Date(), withDelayState: delay)
        }

        routeDiagram = RouteDiagram(
            withDirections: route.rawDirections,
            withTravelDistance: route.travelDistance,
            withWalkingRoute: route.isRawWalkingRoute()
        )

        containerView.addSubview(routeDiagram)

        setupDataDependentConstraints()
    }

    // MARK: - Get Data

    private func getDelayState(fromRoute route: Route) -> DelayState {
        if let firstDepartDirection = route.getFirstDepartRawDirection() {

            let departTime = firstDepartDirection.startTime

            if let delay = firstDepartDirection.delay {
                let delayedDepartTime = departTime.addingTimeInterval(TimeInterval(delay))
                // Our live tracking only updates once every 30 seconds, so we want to show 
                // buses that are delayed by < 120 as on time in order to be more accurate 
                // about the status of slightly delayed buses. This way riders get to a bus 
                // stop earlier rather than later when trying to catch such buses.
                if Time.compare(date1: departTime, date2: delayedDepartTime) == .orderedAscending { // bus is delayed
                    if delayedDepartTime >= Date() || delay >= 120 {
                        return .late(date: delayedDepartTime)
                    } else { // delay < 120
                        return .onTime(date: departTime)
                    }
                } else { // bus is not delayed
                    return .onTime(date: departTime)
                }
            } else {
                return .noDelay(date: departTime)
            }
        }
        return .noDelay(date: route.departureTime)
    }

    private func setDepartureTimeAndLiveElements(withRoute route: Route) {
        let isWalkingRoute = route.isRawWalkingRoute()

        if isWalkingRoute {
            setDepartureTimeToWalking()
            return
        }

        let delayState = getDelayState(fromRoute: route)
        setDepartureTime(withStartTime: Date(), withDelayState: delayState)
        setLiveElements(withDelayState: delayState)
    }

    private func setLiveElements(withDelayState delayState: DelayState) {
        switch delayState {
        case .late(date: let delayedDepartureTime):
            liveLabel.textColor = Colors.lateRed
            liveLabel.text = "Late - \(Time.timeString(from: delayedDepartureTime))"
            liveIndicatorView.setColor(to: Colors.lateRed)
            liveContainerView.addSubview(liveIndicatorView)
            liveContainerView.addSubview(liveLabel)
            setLiveIndicatorViewsConstraints()

        case .onTime:
            liveLabel.textColor = Colors.liveGreen
            liveLabel.text = "On Time"
            liveIndicatorView.setColor(to: Colors.liveGreen)
            liveContainerView.addSubview(liveIndicatorView)
            liveContainerView.addSubview(liveLabel)
            setLiveIndicatorViewsConstraints()

        case .noDelay:
            liveLabel.removeFromSuperview()
            liveIndicatorView.removeFromSuperview()
        }
    }

    private func setDepartureTime(withStartTime startTime: Date, withDelayState delayState: DelayState) {
        switch delayState {

        case .late(date: let departureTime):
            let boardTime = Time.timeString(from: startTime, to: departureTime)
            departureTimeLabel.text = boardTime == "0 min" ? "Board now" : "Board in \(boardTime)"

            departureTimeLabel.textColor = Colors.lateRed

        case .onTime(date: let departureTime):
            let boardTime = Time.timeString(from: startTime, to: departureTime)
            departureTimeLabel.text = boardTime == "0 min" ? "Board now" : "Board in \(boardTime)"

            departureTimeLabel.textColor = Colors.liveGreen

        case .noDelay(date: let departureTime):
            let boardTime = Time.timeString(from: startTime, to: departureTime)
            departureTimeLabel.text = boardTime == "0 min" ? "Board now" : "Board in \(boardTime)"

            departureTimeLabel.textColor = Colors.primaryText
        }

        arrowImageView.tintColor = Colors.primaryText
    }

    private func setTravelTime(withDepartureTime departureTime: Date, withArrivalTime arrivalTime: Date) {
        travelTimeLabel.text = "\(Time.timeString(from: departureTime)) - \(Time.timeString(from: arrivalTime))"
    }

    private func setDepartureTimeToWalking() {
        departureTimeLabel.text = "Directions"
        departureTimeLabel.textColor = Colors.lateRed
        arrowImageView.tintColor = Colors.metadataIcon
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        routeDiagram.removeFromSuperview()
        liveLabel.removeFromSuperview()
        liveIndicatorView.removeFromSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
