//
//  RouteLine.swift
//  TCAT
//
//  Created by Monica Ong on 5/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class RouteLine: UIView {

    // MARK: Size vars

    let width: CGFloat = 4
    var height: CGFloat = 20

    static let extendedHeight: CGFloat = 28

    // MARK: Constraint vars

    override var intrinsicContentSize: CGSize {
        return CGSize(width: width, height: height)
    }

    // MARK: Init

    init(x: CGFloat, y: CGFloat, height: CGFloat) {
        self.height = height
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
    }

    init(x: CGFloat, y: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

class SolidLine: RouteLine {

    // MARK: Init

    init(x: CGFloat, y: CGFloat, height: CGFloat, color: UIColor) {
        super.init(x: x, y: y, height: height)

        backgroundColor = color
    }

    init(color: UIColor) {
        super.init(x: 0, y: 0)

        backgroundColor = color
    }

    convenience init(height: CGFloat, color: UIColor) {
        self.init(x: 0, y: 0, height: height, color: color)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class DottedLine: RouteLine {

    // MARK: Init

    init(x: CGFloat, y: CGFloat, height: CGFloat, color: UIColor) {
        super.init(x: x, y: y, height: height)

        let dashHeight: CGFloat = 3.75
        let dashSpace: CGFloat = 4

        var nextDashYPos: CGFloat = dashSpace
        while nextDashYPos <= height - dashHeight {
            let line = CALayer()

            line.frame = CGRect(x: 0, y: nextDashYPos, width: frame.width, height: dashHeight)
            line.backgroundColor = color.cgColor
            line.cornerRadius = dashHeight / 2

            layer.addSublayer(line)
            nextDashYPos += line.frame.height + dashSpace
        }
    }

    init(color: UIColor) {
        super.init(x: 0, y: 0)

        let dashHeight: CGFloat = 3.75
        let dashSpace: CGFloat = 4

        var nextDashYPos: CGFloat = dashSpace
        for _ in 0..<2 {
            let line = CALayer()

            line.frame = CGRect(x: 0, y: nextDashYPos, width: frame.width, height: dashHeight)
            line.backgroundColor = color.cgColor
            line.cornerRadius = dashHeight / 2

            layer.addSublayer(line)
            nextDashYPos += line.frame.height + dashSpace
        }
    }

    convenience init(height: CGFloat, color: UIColor) {
        self.init(x: 0, y: 0, height: height, color: color)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
