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
    case large = 18
    case medium = 16
    case small = 12
}

class Circle: UIView {

    // MARK: Data vars

    let diameter: CGFloat

    // MARK: Constraint vars

    override var intrinsicContentSize: CGSize {
        return CGSize(width: diameter, height: diameter)
    }

    // MARK: Init

    init(size: CircleSize, style: CircleStyle, color: UIColor) {
        diameter = CGFloat(size.rawValue)
        super.init(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))

        layer.cornerRadius = frame.width / 2
        clipsToBounds = true

        switch style {

        case .solid:

            backgroundColor = color

        case .bordered:

            backgroundColor = Colors.white
            layer.borderColor = color.cgColor
            layer.borderWidth = 2.0

            let solidCircle = CALayer()
            let solidCircleDiameter: CGFloat = size == .medium ? 6 : 8
            solidCircle.frame = CGRect(x: 0, y: 0, width: solidCircleDiameter, height: solidCircleDiameter)

            solidCircle.position = center
            solidCircle.cornerRadius = solidCircle.frame.height / 2
            solidCircle.backgroundColor = color.cgColor
            layer.addSublayer(solidCircle)

        case .outline:

            backgroundColor = Colors.white
            layer.borderColor = color.cgColor
            layer.borderWidth = 2.0

        }
    }

    required init?(coder aDecoder: NSCoder) {
        diameter = CGFloat(CircleSize.small.rawValue)
        super.init(coder: aDecoder)
    }
}
