//
//  WalkWithDistanceIcon.swift
//  TCAT
//
//  Created by Monica Ong on 3/7/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit

class WalkWithDistanceIcon: UIView {

    // MARK: View vars

    private let travelDistanceLabel = UILabel()
    private let walkIcon = UIImageView(image: #imageLiteral(resourceName: "walk"))

    // MARK: Spacing vars

    let walkIconAndDistanceLabelVerticalSpace: CGFloat = 2.0

    // MARK: Init

    init(withDistance distance: Double) {
        super.init(frame: .zero)

        travelDistanceLabel.font = .getFont(.regular, size: 12.0)
        travelDistanceLabel.textColor = Colors.metadataIcon

        if distance > 0 {
            travelDistanceLabel.text = "\(distance.roundedString)"
        }

        walkIcon.contentMode = .scaleAspectFit
        walkIcon.tintColor = Colors.metadataIcon

        addSubview(walkIcon)
        addSubview(travelDistanceLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        walkIcon.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(walkIcon.intrinsicContentSize)
        }

        travelDistanceLabel.snp.makeConstraints { make in
            make.top.equalTo(walkIcon.snp.bottom).offset(walkIconAndDistanceLabelVerticalSpace)
            make.centerX.bottom.equalToSuperview()
            make.size.equalTo(travelDistanceLabel.intrinsicContentSize)

        }

        if travelDistanceLabel.text == nil {
            walkIcon.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
            }
        } else {
            travelDistanceLabel.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
