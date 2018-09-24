//
//  LiveIndicator.swift
//
//  Created by Matt Barker & Monica Ong on 4/8/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit

enum LiveIndicatorSize: Double {
    case small = 8
    case large = 12
}

class LiveIndicator: UIView {
    
    // MARK: State vars
    
    let size: LiveIndicatorSize
    let lineWidth: CGFloat
    
    // MARK: View vars
    
    var circleLayer: CAShapeLayer!
    var smallArcLayer: CAShapeLayer!
    var largeArcLayer: CAShapeLayer!
    
    // MARK: Animation vars
    
    static let INTERVAL: TimeInterval = 4.0
    static let DURATION: TimeInterval = 0.2
    let START_DELAY: TimeInterval = 0.0
    let END_DELAY: TimeInterval = 0.0
    let DIM_OPACITY: CGFloat = 0.5
    
    // MARK: Constraint vars
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: CGFloat(size.rawValue) + lineWidth, height: CGFloat(size.rawValue) + lineWidth)
    }
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        size = .small
        lineWidth = CGFloat(size.rawValue) / 4

        super.init(coder: aDecoder)
    }
    
    init(size: LiveIndicatorSize, color: UIColor) {
        self.size = size
        self.lineWidth = CGFloat(size.rawValue) / 4
        
        super.init(frame: CGRect(x: 0, y: 0, width: size.rawValue, height: size.rawValue))
        
        circleLayer = getCircleLayer(color: color)
        largeArcLayer = getLargeArcLayer(color: color, lineWidth:  lineWidth)
        smallArcLayer = getSmallArcLayer(color: color, lineWidth:  lineWidth)
        
        layer.addSublayer(circleLayer)
        layer.addSublayer(largeArcLayer)
        layer.addSublayer(smallArcLayer)
        
        resizeFrameToFitLayers(lineWidth: lineWidth)
        
        startAnimation()

    }
    
    // MARK: Resize
    
    private func resizeFrameToFitLayers(lineWidth: CGFloat) {
        frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width + lineWidth, height: frame.height + lineWidth)
        repositionLayer(circleLayer, withY: lineWidth)
        repositionLayer(smallArcLayer, withY: lineWidth)
        repositionLayer(largeArcLayer, withY: lineWidth)
    }
    
    private func repositionLayer(_ layer: CAShapeLayer, withY y: CGFloat) {
        layer.frame = CGRect(x: 0, y: y, width: layer.frame.width, height: layer.frame.height)

    }
    
    // MARK: Create views
    
    private func getCircleLayer(color: UIColor) -> CAShapeLayer {
        let diameter = bounds.size.width / 4
        let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: bounds.maxY - diameter, width: diameter,  height: diameter))
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = color.cgColor
        
        return circleLayer
    }
    
    private func drawBezierPath(radius: CGFloat, lineWidth: CGFloat) -> UIBezierPath {
        return UIBezierPath(arcCenter: CGPoint(x: 0, y: bounds.maxY),
                            radius: radius,
                            startAngle:  .pi * (3/2) + asin((lineWidth / 2) / (radius + (lineWidth / 2))),
                            endAngle: -asin((lineWidth / 2) / (radius + (lineWidth / 2))),
                            clockwise: true)
    }
    
    private func getLargeArcLayer(color: UIColor, lineWidth: CGFloat) -> CAShapeLayer {
        let radius = bounds.size.height + lineWidth / 2
        let largeArcPath = drawBezierPath(radius: radius, lineWidth: lineWidth)
        let largeArcLayer = CAShapeLayer()
        largeArcLayer.path = largeArcPath.cgPath
        largeArcLayer.strokeColor = color.cgColor
        largeArcLayer.fillColor = UIColor.clear.cgColor
        largeArcLayer.lineWidth = bounds.width/4
        largeArcLayer.lineCap = CAShapeLayerLineCap.round
        
        return largeArcLayer
    }
    
    private func getSmallArcLayer(color: UIColor, lineWidth: CGFloat) -> CAShapeLayer {
        let radius = bounds.size.height / 2 + lineWidth / 2
        let smallArcPath = drawBezierPath(radius: radius, lineWidth: lineWidth)
        let smallArcLayer = CAShapeLayer()
        smallArcLayer.path = smallArcPath.cgPath
        smallArcLayer.strokeColor = color.cgColor
        smallArcLayer.fillColor = UIColor.clear.cgColor
        smallArcLayer.lineWidth = bounds.width / 4
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
        for element : Any in [circleLayer, smallArcLayer, largeArcLayer] {
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
