//
//  RouteDiagram.swift
//  TCAT
//
//  Created by Monica Ong on 7/2/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class RouteDiagram: UIView {

    // MARK: View vars
    private var routeDiagramSegments: [RouteDiagramSegment] = []

    // MARK: Spacing vars
    let topMargin: CGFloat = 8

    init(withDirections directions: [Direction], withTravelDistance travelDistance: Double, withWalkingRoute isWalkingRoute: Bool) {
        super.init(frame: .zero)

        var first = 0
        for (index, direction) in directions.enumerated() {
            // if not walking route, skip first walking direction
            if !isWalkingRoute && index == first && direction.type == .walk {
                first += 1
                continue
            }

            let routeDiagramSegment = RouteDiagramSegment(for: direction, prev: routeDiagramSegments.last, isWalkingRoute: isWalkingRoute, index: index - first, isDestination: index == directions.count - 1, travelDistance: travelDistance)
            routeDiagramSegments.append(routeDiagramSegment)
        }

        for routeDiagramSegment in routeDiagramSegments {
            addSubview(routeDiagramSegment)
        }

        setupConstraints()
    }

    private func getStayOnBusCoverUpView() -> UIView {
        let busIconWidth: CGFloat = 48
        let spaceBtnBusIcons: CGFloat = 15.0

        let stayOnBusCoverUpView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: busIconWidth, height: spaceBtnBusIcons + 6)))
        stayOnBusCoverUpView.backgroundColor = Colors.tcatBlue

        return stayOnBusCoverUpView
    }

    private func setupConstraints() {

        for (i, current) in routeDiagramSegments.enumerated() {
            let prev = routeDiagramSegments[optional: i-1]
            let isDestination = i == routeDiagramSegments.count - 1
            current.setupConstraints(prev: prev, isLastDirection: isDestination)
            if let prev = prev {
                if isDestination {
                    current.snp.makeConstraints { make in
                        make.bottom.equalToSuperview()
                    }
                }
                current.snp.makeConstraints { make in
                    make.top.equalTo(prev.snp.bottom)
                }
            } else {
                current.snp.makeConstraints { make in
                    make.top.equalToSuperview().inset(topMargin)
                }
            }

            current.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(current.calculateHeight())
            }
        }
    }

    func calculateHeight() -> CGFloat {
        return routeDiagramSegments.reduce(topMargin) { (res, segment) -> CGFloat in return res + segment.calculateHeight() }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
