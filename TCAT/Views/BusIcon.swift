//
//  BusIcon.swift
//  TCAT
//
//  Created by Matthew Barker on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

enum BusIconSize: String {
    case small, large
}

class BusIcon: UIView {
    
    var color: UIColor = UIColor(red: 7 / 255, green: 157 / 255, blue: 220 / 255, alpha: 1)
    var number: Int = 99
    
    var label: UILabel!
    var image: UIImageView!
    
    init(size: BusIconSize, number: Int) {
        switch size {
        case .small : super.init(frame: CGRect(x: 0, y: 0, width: 48, height: 24))
        case .large : super.init(frame: CGRect(x: 0, y: 0, width: 72, height: 36))
        }
        
        self.number = number
        self.backgroundColor = color
        self.layer.cornerRadius = size == .large ? 8 : 4
        
        image = UIImageView(image: UIImage(named: "bus"))
        let constant: CGFloat = size == .large ? 0.9 : 0.6
        image.frame.size = CGSize(width: image.frame.width * constant, height: image.frame.height * constant)
        image.tintColor = .white
        image.center = center
        image.center.x -= size == .large ? image.frame.width / 2 - 2 : image.frame.width / 2
        addSubview(image)
        
        label = UILabel()
        label.text = "\(number)"
        label.font = (size == .large) ? UIFont(name: "SFUIText-Semibold", size: 21) : UIFont(name: "SFUIText-Semibold", size: 15)
        label.textColor = .white
        label.sizeToFit()
        label.center = center
        label.center.x += size == .large ? label.frame.width / 2 + 4 : label.frame.width / 2
        addSubview(label)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
