//
//  RouteTableViewCell.swift
//  TCAT
//
//  Created by Monica Ong on 2/13/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import FutureNova
import SwiftyJSON
import UIKit

protocol TravelDistanceDelegate: NSObjectProtocol {
    func travelDistanceUpdated(withDistance distance: Double)
}

class RouteTableViewCell: UITableViewCell {

    // MARK: Data vars
    static let identifier: String = "routeCell"

    private var route: Route?
    private let fileName: String = "RouteTableViewCell"
    private let networking: Networking = URLSession.shared.request

    // MARK: Log vars
    private var rowNum: Int?

    // MARK: View vars
    private let containerView = UIView()

    private var timesStackView: UIStackView!
    private var travelTimeLabel = UILabel()

    private var arrowImageView = UIImageView(image: #imageLiteral(resourceName: "side-arrow"))
    private var departureStackView: UIStackView!
    private var departureTimeLabel = UILabel()

    private var liveIndicatorView = LiveIndicator(size: .small, color: .clear)
    private var liveLabel = UILabel()
    private var liveStackView: UIStackView!

    private var routeDiagram: RouteDiagram!
    private var verticalStackView: UIStackView!

    // MARK: Spacing vars

    private let cellMargin: CGFloat = 12
    private let verticalStackViewLayoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 12)

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        departureStackView = UIStackView(arrangedSubviews: [departureTimeLabel, arrowImageView])
        timesStackView = UIStackView(arrangedSubviews: [travelTimeLabel, departureStackView])
        liveStackView = UIStackView(arrangedSubviews: [liveLabel, liveIndicatorView])
        verticalStackView = UIStackView(arrangedSubviews: [timesStackView])

        styleCellBackground()
        styleVerticalStackView()

        contentView.addSubview(containerView)
        containerView.addSubview(verticalStackView)

        setupConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: cellMargin, right: 0)
        contentView.frame = contentView.frame.inset(by: padding)
    }

    // MARK: Style

    private func styleCellBackground() {
        let cornerRadius: CGFloat = 16

        layer.backgroundColor = UIColor.clear.cgColor
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        containerView.backgroundColor = Colors.white
        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.masksToBounds = true
    }

    private func styleVerticalStackView() {
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 8
        verticalStackView.alignment = .leading
        verticalStackView.layoutMargins = verticalStackViewLayoutMargins
        verticalStackView.isLayoutMarginsRelativeArrangement = true

        styleTimesStackView()
        styleLiveStackView()
    }

    private func styleTimesStackView() {
        timesStackView.axis = .horizontal
        timesStackView.alignment = .firstBaseline
        timesStackView.distribution = .equalSpacing

        travelTimeLabel.font = .getFont(.semibold, size: 16)
        travelTimeLabel.textColor = Colors.primaryText

        styleDepartureStackView()
    }

    private func styleDepartureStackView() {
        let spaceBtnDepartureElements: CGFloat = 4

        departureStackView.axis = .horizontal
        departureStackView.spacing = spaceBtnDepartureElements

        departureTimeLabel.font = .getFont(.semibold, size: 14)
        departureTimeLabel.textColor = Colors.primaryText
        arrowImageView.tintColor = Colors.metadataIcon
    }

    private func styleLiveStackView() {
        let liveStackViewFrameInset = UIEdgeInsets(top: -4, left: 0, bottom: -4, right: 0)
        let spaceBtnLiveElements: CGFloat = 4

        liveStackView.axis = .horizontal
        liveStackView.spacing = spaceBtnLiveElements
        liveStackView.frame = liveStackView.frame.inset(by: liveStackViewFrameInset)

        liveLabel.font = .getFont(.semibold, size: 14)
    }

    private func setupConstraints() {
        let arrowImageViewSize = CGSize(width: 6, height: 11.5)

        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(cellMargin)
            make.top.bottom.equalToSuperview()
        }

        verticalStackView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }

        arrowImageView.snp.makeConstraints { make in
            make.size.equalTo(arrowImageViewSize)
        }
        arrowImageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        timesStackView.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-(verticalStackViewLayoutMargins.right + verticalStackViewLayoutMargins.left))
        }
    }

    // MARK: Get Data

    private func getDepartureAndArrivalTimes(fromRoute route: Route) -> (departureTime: Date, arrivalTime: Date) {
        return (departureTime: route.departureTime, arrivalTime: route.arrivalTime)
    }

    private func getDelayState(fromRoute route: Route) -> DelayState {
        if let firstDepartDirection = route.getFirstDepartRawDirection() {

            let departTime = firstDepartDirection.startTime

            if let delay = firstDepartDirection.delay {
                let delayedDepartTime = departTime.addingTimeInterval(TimeInterval(delay))
                // Our live tracking only updates once every 30 seconds, so we want to show buses that are delayed by < 120 as on time in order to be more accurate about the status of slightly delayed buses. This way riders get to a bus stop earlier rather than later when trying to catch such buses.
                if Time.compare(date1: departTime, date2: delayedDepartTime) == .orderedAscending { // bus is delayed
                    if (delayedDepartTime >= Date() || delay >= 120) {
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

    // MARK: Reuse

    override func prepareForReuse() {
        routeDiagram.removeFromSuperview()
        liveStackView.removeFromSuperview()

        hideLiveElements(animate: false)
    }

    // MARK: Set Data
    func configure(for route: Route, rowNum: Int) {
        self.route = route
        self.rowNum = rowNum

        let (departureTime, arrivalTime) = getDepartureAndArrivalTimes(fromRoute: route)
        setTravelTime(withDepartureTime: departureTime, withArrivalTime: arrivalTime)

        setDepartureTimeAndLiveElements(withRoute: route)
        routeDiagram = RouteDiagram(withDirections: route.rawDirections, withTravelDistance: route.travelDistance, withWalkingRoute: route.isRawWalkingRoute())

        verticalStackView.addArrangedSubview(routeDiagram)

        routeDiagram.snp.remakeConstraints { make in
            make.height.equalTo(routeDiagram.calculateHeight())
        }
    }

    private func setDepartureTimeAndLiveElements(withRoute route: Route) {
        let isWalkingRoute = route.isRawWalkingRoute()

        if isWalkingRoute {
            setDepartureTimeToWalking()
            return
        }

        verticalStackView.addArrangedSubview(liveStackView)
        let delayState = getDelayState(fromRoute: route)
        setDepartureTime(withStartTime: Date(), withDelayState: delayState)
        setLiveElements(withDelayState: delayState)
    }

    @objc func updateLiveElementsWithDelay() {
        if let route = route,
            let direction = route.getFirstDepartRawDirection(),
            let tripId = direction.tripIdentifiers?.first,
            let stopId = direction.stops.first?.id {

            getDelay(tripId: tripId, stopId: stopId).observe(with: { [weak self] result in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .value (let delayResponse):
                        guard (delayResponse.data != nil), let delay = delayResponse.data else {
                            self.setDepartureTimeAndLiveElements(withRoute: route)
                            return
                        }

                        let isNewDelayValue = (route.getFirstDepartRawDirection()?.delay != delay)
                        if isNewDelayValue {
                            JSONFileManager.shared.logDelayParemeters(timestamp: Date(), stopId: stopId, tripId: tripId)
                            JSONFileManager.shared.logURL(timestamp: Date(), urlName: "Delay requestUrl", url: Endpoint.getDelayUrl(tripId: tripId, stopId: stopId))
                            if let data = try? JSONEncoder().encode(delayResponse) {
                                do { try JSONFileManager.shared.saveJSON(JSON.init(data: data), type: .delayJSON(rowNum: self.rowNum ?? -1)) } catch let error {
                                    let fileName = "RouteTableViewCell"
                                    let line = "\(fileName) \(#function): \(error.localizedDescription)"
                                    print(line)
                                }
                            }
                        }

                        let departTime = direction.startTime
                        let delayedDepartTime = departTime.addingTimeInterval(TimeInterval(delay))

                        let isLateDelay = (Time.compare(date1: delayedDepartTime, date2: departTime) == .orderedDescending)
                        if isLateDelay {
                            let delayState = DelayState.late(date: delayedDepartTime)
                            self.setDepartureTime(withStartTime: Date(), withDelayState: delayState)
                            self.setLiveElements(withDelayState: delayState)
                        } else {
                            let delayState = DelayState.onTime(date: departTime)
                            self.setDepartureTime(withStartTime: Date(), withDelayState: delayState)
                            self.setLiveElements(withDelayState: delayState)
                        }

                        route.getFirstDepartRawDirection()?.delay = delay

                    case .error(let error):
                        print("\(self.fileName) \(#function) error: \(error.localizedDescription)")
                        self.setDepartureTimeAndLiveElements(withRoute: route)
                    }
                }
            })
        } else {
            if let route = route {
                setDepartureTimeAndLiveElements(withRoute: route)
            }
        }
    }

    private func getDelay(tripId: String, stopId: String) -> Future<Response<Int?>> {
        return networking(Endpoint.getDelay(tripID: tripId, stopID: stopId)).decode()
    }

    private func setLiveElements(withDelayState delayState: DelayState) {

        switch delayState {

        case .late(date: let delayedDepartureTime):
            liveLabel.textColor = Colors.lateRed
            liveLabel.text = "Late - \(Time.timeString(from: delayedDepartureTime))"
            liveIndicatorView.setColor(to: Colors.lateRed)
            if liveStackView.isHidden {
                showLiveElements()
            }

        case .onTime(date: _):
            liveLabel.textColor = Colors.liveGreen
            liveLabel.text = "On Time"
            liveIndicatorView.setColor(to: Colors.liveGreen)
            if liveStackView.isHidden {
                showLiveElements()
            }

        case .noDelay(date: _):
            if !liveStackView.isHidden {
                hideLiveElements(animate: true)
            }

        }

    }

    private func showLiveElements() {
        UIView.animate(withDuration: 0.3) {
            self.liveStackView.isHidden = false
        }
    }

    private func hideLiveElements(animate: Bool) {
        if animate {
            UIView.animate(withDuration: 0.3) {
                self.liveStackView.isHidden = true
            }
        } else {
            self.liveStackView.isHidden = true
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
        departureTimeLabel.textColor = Colors.metadataIcon
        arrowImageView.tintColor = Colors.metadataIcon
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
