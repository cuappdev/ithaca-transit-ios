//
//  BusIcon.swift
//  TCAT
//
//  Created by Matthew Barker on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import CoreLocation
import UIKit

class BusLocationView: UIView {

    private var busIcon: BusIcon!
    private let busLocationBackgroundView = UIImageView(image: #imageLiteral(resourceName: "busBackground"))
    private let circle = UIView()

    private let circleSize = CGSize(width: 7, height: 7)

    init(number: Int, bearing: Int, position: CLLocationCoordinate2D) {
        super.init(frame: .zero)

        frame.size = busLocationBackgroundView.frame.size

        addSubview(busLocationBackgroundView)
        setupBusIcon(number: number)
        setupCircle()

        setupConstraints()
    }

    private func setupBusIcon(number: Int) {
        busIcon = BusIcon(type: .liveTracking, number: number)
        addSubview(busIcon)
    }

    private func setupCircle() {
        circle.clipsToBounds = true
        circle.layer.cornerRadius = circleSize.width / 2
        circle.backgroundColor = Colors.tcatBlue
        addSubview(circle)
    }

    private func setupConstraints() {
        let busIconToBusLocationBackgroundViewTopInset = 6
        let circleToBusLocationBackgroundViewBottomInset = 6

        busLocationBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(busLocationBackgroundView.intrinsicContentSize)
        }

        busIcon.snp.makeConstraints { make in
            make.centerX.equalTo(busLocationBackgroundView)
            make.top.equalToSuperview().inset(busIconToBusLocationBackgroundViewTopInset)
            make.size.equalTo(busIcon.intrinsicContentSize)
        }

        circle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(busLocationBackgroundView).inset(circleToBusLocationBackgroundViewBottomInset)
            make.size.equalTo(circleSize)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
