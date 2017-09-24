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
}

class BusIcon: UIView {
    
    var number: Int = 99
    
    var label: UILabel!
    var image: UIImageView!
    
    init(type: BusIconType, number: Int) {
        
        switch type {
        case .directionSmall: super.init(frame: CGRect(x: 0, y: 0, width: 48, height: 24))
        case .directionLarge : super.init(frame: CGRect(x: 0, y: 0, width: 72, height: 36))
        }
        
        self.number = number
        self.backgroundColor = .clear
        
        let base = UIView(frame: self.frame)
        base.backgroundColor = .tcatBlueColor
        base.layer.cornerRadius = type == .directionLarge ? 8 : 4
        addSubview(base)
        
        image = UIImageView(image: UIImage(named: "bus"))
        let constant: CGFloat = type == .directionLarge ? 0.9 : 0.6
        image.frame.size = CGSize(width: image.frame.width * constant, height: image.frame.height * constant)
        image.tintColor = .white
        image.center = base.center
        image.center.x = frame.width / 3.5
        addSubview(image)
        
        label = UILabel(frame: CGRect(x: image.frame.maxX, y: 0, width: frame.width - image.frame.maxX, height: frame.height))
        label.text = "\(number)"
        label.font = UIFont.systemFont(ofSize: type == .directionLarge ? 20 : 14, weight: UIFontWeightSemibold)
        label.textColor = .white
        label.sizeToFit()
        label.textAlignment = .center
        label.center = base.center
        label.center.x = frame.width * 3 / 4.25
        addSubview(label)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
