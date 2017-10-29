//
//  LiveIndicator.swift
//  TCAT
//
//  Created by Matthew Barker on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class BearingIndicator: UIView {
    
    fileprivate var arrow: UIImageView!
    fileprivate var triangle: TriangleView!

    static let INTERVAL: TimeInterval = 4.0
    
    fileprivate let DURATION: TimeInterval = 0.2
    fileprivate let START_DELAY: TimeInterval = 0.0
    fileprivate let END_DELAY: TimeInterval = 0.0 // 0.25
    fileprivate let DIM_OPACITY: CGFloat = 0.5
    fileprivate let INTERVAL: TimeInterval = BearingIndicator.INTERVAL
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        
        super.init(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        
        arrow = UIImageView(frame: .zero)
        arrow.image = #imageLiteral(resourceName: "back")
        arrow.frame.size = CGSize(width: 8, height: 8)
        arrow.center = center
        arrow.tintColor = .tcatBlueColor
        // setBearing(90)
        addSubview(arrow)
        
//        triangle = TriangleView(frame: CGRect(x: 0, y: 0, width: 8, height: 6), color: .tcatBlueColor)
//        triangle.center = center
//        addSubview(triangle)
        
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
        backgroundColor = .white
        
        self.startAnimation()
        
    }
    
    /// Being animating the live view
    func startAnimation() {
    
        let timer = Timer(fireAt: Date(), interval: INTERVAL, target: self,
                          selector: #selector(self.animate), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .commonModes)
        
    }
    
    /// Dim, wait, and un-dim the arrow
    @objc private func animate() {
        
        UIView.animate(withDuration: DURATION, delay: START_DELAY, options: .overrideInheritedOptions, animations: {
            self.alpha = self.DIM_OPACITY
        }, completion: { (completed) in
            UIView.animate(withDuration: self.DURATION, delay: self.END_DELAY, options: .overrideInheritedOptions, animations: {
                self.alpha = 1.0
            })
        })
        
    }
    
}
