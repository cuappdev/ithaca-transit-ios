//
//  LiveIndicator.swift
//
//  Created by Matt Barker & Monica Ong on 4/8/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit

enum LiveIndicatorSize: CGFloat {
    case large = 12
    case small = 8
}

class LiveIndicator: UIView {

    // MARK: State vars

    private var lineWidth: CGFloat
    private var size: LiveIndicatorSize

    // MARK: View vars

    var circleLayer: CAShapeLayer!
    var largeArcLayer: CAShapeLayer!
    var smallArcLayer: CAShapeLayer!

    // MARK: Animation vars

    let DIM_OPACITY: CGFloat = 0.5
    let END_DELAY: TimeInterval = 0.0
    let START_DELAY: TimeInterval = 0.0
    static let DURATION: TimeInterval = 0.2
    static let INTERVAL: TimeInterval = 4.0

    // MARK: Constraint vars

    override var intrinsicContentSize: CGSize {
        return CGSize(width: CGFloat(size.rawValue) + lineWidth, height: CGFloat(size.rawValue) + lineWidth)
    }

    // MARK: Init

    required init?(coder aDecoder: NSCoder) {
        size = .small
        lineWidth = size.rawValue / 4

        super.init(coder: aDecoder)
    }

    init(size: LiveIndicatorSize, color: UIColor) {
        self.size = size
        lineWidth = size.rawValue / 4

        super.init(frame: .zero)

        circleLayer = getCircleLayer(color: color)
        largeArcLayer = getLargeArcLayer(color: color, lineWidth: lineWidth)
        smallArcLayer = getSmallArcLayer(color: color, lineWidth: lineWidth)

        layer.addSublayer(circleLayer)
        layer.addSublayer(largeArcLayer)
        layer.addSublayer(smallArcLayer)

        startAnimation()

    }

    // MARK: Create views

    private func getCircleLayer(color: UIColor) -> CAShapeLayer {
        let diameter = intrinsicContentSize.height / 5
        let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: intrinsicContentSize.height - diameter, width: diameter, height: diameter))

        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = color.cgColor

        return circleLayer
    }

    private func drawBezierPath(radius: CGFloat, lineWidth: CGFloat) -> UIBezierPath {
        return UIBezierPath(arcCenter: CGPoint(x: 0, y: intrinsicContentSize.height),
                            radius: radius,
                            startAngle: .pi * (3/2) + asin((lineWidth / 2) / (radius + (lineWidth / 2))),
                            endAngle: -asin((lineWidth / 2) / (radius + (lineWidth / 2))),
                            clockwise: true)
    }

    private func getLargeArcLayer(color: UIColor, lineWidth: CGFloat) -> CAShapeLayer {
        let radius = intrinsicContentSize.height - lineWidth / 2
        let largeArcPath = drawBezierPath(radius: radius, lineWidth: lineWidth)
        let largeArcLayer = CAShapeLayer()
        largeArcLayer.path = largeArcPath.cgPath
        largeArcLayer.strokeColor = color.cgColor
        largeArcLayer.fillColor = UIColor.clear.cgColor
        largeArcLayer.lineWidth = lineWidth
        largeArcLayer.lineCap = CAShapeLayerLineCap.round

        return largeArcLayer
    }

    private func getSmallArcLayer(color: UIColor, lineWidth: CGFloat) -> CAShapeLayer {
        let radius = intrinsicContentSize.height * 3 / 5 - lineWidth / 2
        let smallArcPath = drawBezierPath(radius: radius, lineWidth: lineWidth)
        let smallArcLayer = CAShapeLayer()
        smallArcLayer.path = smallArcPath.cgPath
        smallArcLayer.strokeColor = color.cgColor
        smallArcLayer.fillColor = UIColor.clear.cgColor
        smallArcLayer.lineWidth = lineWidth
        smallArcLayer.lineCap = CAShapeLayerLineCap.round

        return smallArcLayer
    }

    // MARK: Set

    func setColor(to color: UIColor) {
        circleLayer.fillColor = color.cgColor
        smallArcLayer.strokeColor = color.cgColor
        largeArcLayer.strokeColor = color.cgColor
    }

    // MARK: Animate

    func startAnimation() {
        var timeInterval: TimeInterval = 0

        for layer in [circleLayer, smallArcLayer, largeArcLayer] {
            let timer = Timer(fireAt: Date().addingTimeInterval(timeInterval), interval: LiveIndicator.INTERVAL, target: self,
                              selector: #selector(self.animateLayer), userInfo: layer, repeats: true)
            RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
            timeInterval += LiveIndicator.DURATION
        }
    }

    func stopAnimation() {
        for element: Any in [circleLayer, smallArcLayer, largeArcLayer] {
            if let view = element as? UIView {
                view.layer.removeAllAnimations()
            }
            if let layer = element as? CAShapeLayer {
                layer.removeAllAnimations()
            }
        }
    }

    /// Dim, wait, and un-dim a CAShapeLayer
    @objc private func animateLayer(_ timer: Timer) {
        guard let layer = timer.userInfo as? CAShapeLayer else {
            return
        }

        let fadeOutAnimation = CAKeyframeAnimation(keyPath: "opacity")
        fadeOutAnimation.beginTime = START_DELAY
        fadeOutAnimation.duration = LiveIndicator.DURATION
        fadeOutAnimation.keyTimes = [0, 1]
        fadeOutAnimation.values = [1.0, DIM_OPACITY]
        fadeOutAnimation.autoreverses = true
        fadeOutAnimation.fillMode = CAMediaTimingFillMode.forwards
        fadeOutAnimation.isRemovedOnCompletion = true
        layer.add(fadeOutAnimation, forKey: "fadeOut")
    }

}
