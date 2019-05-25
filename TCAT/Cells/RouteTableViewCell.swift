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

protocol RouteTableViewCellDelegate: class {
    func updateLiveElements(fun: () -> Void)
    func getRowNum(for cell: RouteTableViewCell) -> Int?
}

class RouteTableViewCell: UITableViewCell {

    // MARK: Data vars
    var delegate: RouteTableViewCellDelegate?

    private let fileName: String = "RouteTableViewCell"
    private let networking: Networking = URLSession.shared.request

    // MARK: View vars
    private let containerView = UIView()

    private var travelTimeLabel = UILabel()

    private var arrowImageView = UIImageView(image: #imageLiteral(resourceName: "side-arrow"))
    private var departureStackView: UIStackView!
    private var departureTimeLabel = UILabel()

    private var liveIndicatorView = LiveIndicator(size: .small, color: .clear)
    private var liveLabel = UILabel()
    private var liveContainerView = UIView()

    private var routeDiagram: RouteDiagram!

    // MARK: Spacing vars
    private let spaceBtnDepartureElements: CGFloat = 4
    private let containerViewLayoutInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 12)
    private let liveStackViewFrameInset = UIEdgeInsets(top: -4, left: 0, bottom: -4, right: 0)

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupCellBackground()
        setupDepartureStackView()
        setupTravelTimeLabel()
        setupLiveStackView()

        contentView.addSubview(containerView)

        setupConstraints()
    }

    // MARK: Style

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

    private func setupLiveStackView() {
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
            make.size.equalTo(liveIndicatorView.intrinsicContentSize)
        }

    }

    private func setupDataDependentConstraints() {
        let routeDiagramTopOffset = 8

        routeDiagram.snp.makeConstraints { make in
            make.top.equalTo(liveContainerView.snp.bottom).offset(routeDiagramTopOffset)
            make.height.equalTo(routeDiagram.calculateHeight())
            make.leading.equalTo(travelTimeLabel)
            make.trailing.equalTo(departureStackView)
            make.bottom.equalToSuperview().inset(containerViewLayoutInsets)
        }
    }

    // MARK: Get Data

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
        routeDiagram.snp.removeConstraints()

        hideLiveElements()
    }

    // MARK: Set Data
    func configure(for route: Route, delegate: UIViewController & RouteTableViewCellDelegate) {

        self.delegate = delegate

        setTravelTime(withDepartureTime: route.departureTime, withArrivalTime: route.arrivalTime)

        setDepartureTimeAndLiveElements(withRoute: route)
        routeDiagram = RouteDiagram(withDirections: route.rawDirections, withTravelDistance: route.travelDistance, withWalkingRoute: route.isRawWalkingRoute())

        containerView.addSubview(routeDiagram)

        setupDataDependentConstraints()
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

    @objc func updateLiveElementsWithDelay(for route: Route) {
        if !route.isRawWalkingRoute(),
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
                                do { try JSONFileManager.shared.saveJSON(JSON.init(data: data), type: .delayJSON(rowNum: self.delegate?.getRowNum(for: self) ?? -1)) } catch let error {
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
            setDepartureTimeAndLiveElements(withRoute: route)
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
            showLiveElements()

        case .onTime(date: _):
            liveLabel.textColor = Colors.liveGreen
            liveLabel.text = "On Time"
            liveIndicatorView.setColor(to: Colors.liveGreen)
            showLiveElements()

        case .noDelay(date: _):
            hideLiveElements()
        }

    }

    private func showLiveElements() {
        delegate?.updateLiveElements {
            liveContainerView.addSubview(liveIndicatorView)
            liveContainerView.addSubview(liveLabel)
            setLiveIndicatorViewsConstraints()
            layoutIfNeeded()
        }
    }

    private func hideLiveElements() {
        delegate?.updateLiveElements {
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
        departureTimeLabel.textColor = Colors.metadataIcon
        arrowImageView.tintColor = Colors.metadataIcon
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
