//
//  LiveIndicator.swift
//  
//
//  Created by Monica Ong on 4/8/18.
//

import UIKit

enum LiveIndicatorSize: Double {
    case small = 6.5
    case large = 12
}

class LiveIndicator: UIView {
    
    // MARK: View vars
    
    var circleLayer: CAShapeLayer!
    var smallArcLayer: CAShapeLayer!
    var largeArcLayer: CAShapeLayer!
    
    // MARK: Animation vars
    
    static let INTERVAL: TimeInterval = 4.0
    
    static let DURATION: TimeInterval = 0.2
    let START_DELAY: TimeInterval = 0.0
    let END_DELAY: TimeInterval = 0.0 // 0.25
    let DIM_OPACITY: CGFloat = 0.5
    let INTERVAL: TimeInterval = LiveIndicator.INTERVAL
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(size: LiveIndicatorSize, color: UIColor) {
        super.init(frame: CGRect(x: 0, y: 0, width: size.rawValue, height: size.rawValue))
        
        let lineWidth = bounds.width/4
        
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
        layer.frame = CGRect(x: 0.0, y: y, width: layer.frame.width, height: layer.frame.height)
    }
    
    // MARK: Create views
    
    private func getCircleLayer(color: UIColor) -> CAShapeLayer {
        let circlePath = UIBezierPath(ovalIn: CGRect(x: 0.0, y: bounds.maxY - bounds.size.height/4, width: bounds.size.width/4, height: bounds.size.height/4))
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = color.cgColor
        
        return circleLayer
    }
    
    private func getLargeArcLayer(color: UIColor, lineWidth: CGFloat) -> CAShapeLayer {
        let radius = bounds.size.height + lineWidth/2
        
        let largeArcpath = UIBezierPath(arcCenter: CGPoint(x: 0, y: bounds.maxY),
                                        radius: radius,
                                        startAngle:  .pi * (3 / 2) + asin((lineWidth/2) / (radius + (lineWidth/2))),
                                        endAngle: -asin((lineWidth/2) / (radius + (lineWidth/2))),
                                        clockwise: true)
        let largeArcLayer = CAShapeLayer()
        largeArcLayer.path = largeArcpath.cgPath
        largeArcLayer.strokeColor = color.cgColor
        largeArcLayer.fillColor = UIColor.clear.cgColor
        largeArcLayer.lineWidth = bounds.width/4
        largeArcLayer.lineCap = kCALineCapRound
        
        return largeArcLayer
    }
    
    private func getSmallArcLayer(color: UIColor, lineWidth: CGFloat) -> CAShapeLayer {
        let radius = bounds.size.height/2 + lineWidth/2
        
        let smallArcpath = UIBezierPath(arcCenter: CGPoint(x: 0, y: bounds.maxY),
                                        radius: radius,
                                        startAngle:  .pi * (3 / 2) + asin((lineWidth/2) / (radius + (lineWidth/2))),
                                        endAngle: -asin((lineWidth/2) / (radius + (lineWidth/2))),
                                        clockwise: true)
        let smallArcLayer = CAShapeLayer()
        smallArcLayer.path = smallArcpath.cgPath
        smallArcLayer.strokeColor = color.cgColor
        smallArcLayer.fillColor = UIColor.clear.cgColor
        smallArcLayer.lineWidth = bounds.width/4
        smallArcLayer.lineCap = kCALineCapRound
        
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
            let timer = Timer(fireAt: Date().addingTimeInterval(timeInterval), interval: INTERVAL, target: self,
                              selector: #selector(self.animateLayer), userInfo: layer, repeats: true)
            RunLoop.main.add(timer, forMode: .commonModes)
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
        fadeOutAnimation.fillMode = kCAFillModeForwards
        fadeOutAnimation.isRemovedOnCompletion = true
        layer.add(fadeOutAnimation, forKey: "fadeOut")
    }
    
}
