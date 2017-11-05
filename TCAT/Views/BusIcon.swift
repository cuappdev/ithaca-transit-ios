//
//  BusIcon.swift
//  TCAT
//
//  Created by Matthew Barker on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//
import UIKit

enum BusIconType: String {
    case directionSmall
    case directionLarge
    case liveTracking
}

class BusIcon: UIView {
    
    var number: Int = 99
    
    var label: UILabel!
    var image: UIImageView!
    var liveIndicator: LiveIndicator!
    
    init(type: BusIconType, number: Int) {
        
        switch type {
            case .directionSmall: super.init(frame: CGRect(x: 0, y: 0, width: 48, height: 24))
            case .liveTracking : super.init(frame: CGRect(x: 0, y: 0, width: 72, height: 30))
            case .directionLarge : super.init(frame: CGRect(x: 0, y: 0, width: 72, height: 36))
        }
        
        self.number = number
        self.backgroundColor = .clear
        
        let base = UIView(frame: self.frame)
        base.backgroundColor = .tcatBlueColor
        base.layer.cornerRadius = type == .directionLarge ? 8 : 4
        addSubview(base)
        
        image = UIImageView(image: UIImage(named: "bus"))
        let constant: CGFloat = type == .directionSmall ? 0.75 : 1.0
        image.frame.size = CGSize(width: image.frame.width * constant, height: image.frame.height * constant)
        image.tintColor = .white
        image.center.y = base.center.y
        image.frame.origin.x = type == .directionSmall ? 8 : 12
        addSubview(image)
        
        label = UILabel(frame: CGRect(x: image.frame.maxX, y: 0, width: frame.width - image.frame.maxX, height: frame.height))
        label.text = "\(number)"
        label.font = UIFont.systemFont(ofSize: type == .directionLarge ? 20 : 14, weight: UIFontWeightSemibold)
        label.textColor = .white
        label.textAlignment = .center
        label.center.y = base.center.y
        label.frame.size.width = frame.maxX - image.frame.maxX
        label.frame.origin.x = image.frame.maxX
        addSubview(label)
        
        if type == .liveTracking {
            
            label.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
            label.sizeToFit()
            image.frame.origin.x = 8
            let sizeConstant: CGFloat = 0.87
            image.frame.size = CGSize(width: image.frame.width * sizeConstant, height: image.frame.height * sizeConstant)
            label.center.y = base.center.y
            label.frame.origin.x = image.frame.maxX + 4
            
            liveIndicator = LiveIndicator()
            liveIndicator.frame.origin = CGPoint(x: label.frame.maxX + 6, y: label.frame.origin.y)
            liveIndicator.center.y = base.center.y
            addSubview(liveIndicator)
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
