//
//  LiveIndicator.swift
//  TCAT
//
//  Created by Matthew Barker on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class LiveIndicator: UIView {
    
    fileprivate var dot: UIView!
    fileprivate var smallArcLayer: CAShapeLayer!
    fileprivate var largeArcLayer: CAShapeLayer!
    
    fileprivate var views: [Any]!
    
    static let INTERVAL: TimeInterval = 4.0
    
    fileprivate let DURATION: TimeInterval = 0.2
    fileprivate let START_DELAY: TimeInterval = 0.0
    fileprivate let END_DELAY: TimeInterval = 0.0 // 0.25
    fileprivate let DIM_OPACITY: CGFloat = 0.5
    fileprivate let INTERVAL: TimeInterval = LiveIndicator.INTERVAL
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        
        super.init(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        
        dot = UIView(frame: CGRect(x: 0 , y: frame.maxY - 3, width: 3, height: 3))
        dot.layer.cornerRadius = dot.frame.width / 2
        dot.clipsToBounds = true
        dot.backgroundColor = .white
        addSubview(dot)
        
        let arcOrigin = CGPoint(x: 1, y: frame.maxY - 1)
        let constant: CGFloat = 2
        
        smallArcLayer = createTopToLeftArc(origin: arcOrigin, radius: 7, lineWidth: constant)
        self.layer.addSublayer(smallArcLayer)
        
        largeArcLayer = createTopToLeftArc(origin: arcOrigin, radius: 7 + 2 * constant, lineWidth: constant)
        self.layer.addSublayer(largeArcLayer)
        
        views = [dot, smallArcLayer, largeArcLayer]
        self.startAnimation()
        
    }
    
    private func createTopToLeftArc(origin: CGPoint, radius: CGFloat, lineWidth: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(arcCenter: origin, radius: radius, startAngle: .pi * (3 / 2), endAngle: 0, clockwise: true)
        let pathLayer = CAShapeLayer()
        pathLayer.path = path.cgPath
        pathLayer.strokeColor = UIColor.white.cgColor
        pathLayer.fillColor = UIColor.clear.cgColor
        pathLayer.lineWidth = lineWidth
        pathLayer.lineCap = kCALineCapRound
        return pathLayer
    }
    
    /// Being animating the live view
    func startAnimation() {
        
        var timeInterval: TimeInterval = 0
        
        for element : Any in [dot, smallArcLayer, largeArcLayer] {
            if let view = element as? UIView {
                let timer = Timer(fireAt: Date().addingTimeInterval(timeInterval), interval: INTERVAL, target: self,
                                  selector: #selector(self.animate(view:)), userInfo: view, repeats: true)
                RunLoop.main.add(timer, forMode: .commonModes)
            }
            if let layer = element as? CAShapeLayer {
                let timer = Timer(fireAt: Date().addingTimeInterval(timeInterval), interval: INTERVAL, target: self,
                                  selector: #selector(self.animate(layer:)), userInfo: layer, repeats: true)
                RunLoop.main.add(timer, forMode: .commonModes)
            }
            timeInterval += DURATION
        }
        
    }
    
    @objc private func execute(timer: Timer) {
        (timer.userInfo as? Timer)?.fire()
    }
    
    /// Stop live view animation
    func stopAnimation() {
        for element : Any in [dot, smallArcLayer, largeArcLayer] {
            if let view = element as? UIView {
                view.layer.removeAllAnimations()
            }
            if let layer = element as? CAShapeLayer {
                layer.removeAllAnimations()
            }
        }
    }
    
    /// Dim, wait, and un-dim a UIView
    @objc private func animate(view timer: Timer) {
        
        guard let view = timer.userInfo as? UIView
            else { return }
        
        UIView.animate(withDuration: DURATION, delay: START_DELAY, options: .overrideInheritedOptions, animations: {
            view.alpha = self.DIM_OPACITY
        }, completion: { (completed) in
            UIView.animate(withDuration: self.DURATION, delay: self.END_DELAY, options: .overrideInheritedOptions, animations: {
                view.alpha = 1.0
            })
        })
        
    }
    
    /// Dim, wait, and un-dim a CAShapeLayer
    @objc private func animate(layer timer: Timer) {
        
        guard let layer = timer.userInfo as? CAShapeLayer
            else { return }
        
        let fadeOutAnimation = CAKeyframeAnimation(keyPath: "opacity")
        fadeOutAnimation.beginTime = START_DELAY
        fadeOutAnimation.duration = DURATION
        fadeOutAnimation.keyTimes = [0, 1]
        fadeOutAnimation.values = [1.0, DIM_OPACITY]
        fadeOutAnimation.autoreverses = true
        fadeOutAnimation.fillMode = kCAFillModeForwards
        fadeOutAnimation.isRemovedOnCompletion = true
        layer.add(fadeOutAnimation, forKey: "fadeOut")
        
    }
    
}
