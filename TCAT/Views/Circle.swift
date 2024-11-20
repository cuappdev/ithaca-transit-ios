//
//  Circle.swift
//  TCAT
//
//  Created by Matthew Barker on 3/1/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

enum CircleStyle {
    /// Thick border and center dot with same color, white donut.
    case bordered
    /// Color is used as border, middle is white.
    case outline
    case solid
}

enum CircleSize: Int {
    case large = 9
    case medium = 8
    case small = 6
}

class Circle: UIView {

    // MARK: - Data vars

    private let radius: CGFloat

    // MARK: - Constraint vars

    override var intrinsicContentSize: CGSize {
        return CGSize(width: radius * 2, height: radius * 2)
    }

    // MARK: - Init

    init(size: CircleSize, style: CircleStyle, color: UIColor) {
        radius = CGFloat(size.rawValue)
        super.init(frame: .zero)

        layer.cornerRadius = radius
        clipsToBounds = true

        switch style {
        case .solid:
            backgroundColor = color

        case .bordered:
            backgroundColor = Colors.white
            layer.borderColor = color.cgColor
            layer.borderWidth = 2.0

            let solidCircle = UIView()
            let solidCircleDiameter: CGFloat = size == .medium ? 6 : 8

            solidCircle.layer.cornerRadius = solidCircleDiameter / 2
            solidCircle.clipsToBounds = true
            solidCircle.backgroundColor = color

            addSubview(solidCircle)

            solidCircle.snp.makeConstraints { make in
                make.centerX.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: solidCircleDiameter, height: solidCircleDiameter))
            }

        case .outline:
            backgroundColor = Colors.white
            layer.borderColor = color.cgColor
            layer.borderWidth = 2.0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        radius = CGFloat(CircleSize.small.rawValue)
        super.init(coder: aDecoder)
    }

}
