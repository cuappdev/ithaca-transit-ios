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
    case mapStandard
}

class BusIcon: UIView {
    
    var number: Int = 99
    
    var label: UILabel!
    var image: UIImageView!
    
    init(type: BusIconType, number: Int) {
        
        switch type {
        case .directionSmall: super.init(frame: CGRect(x: 0, y: 0, width: 48, height: 24))
        case .directionLarge : super.init(frame: CGRect(x: 0, y: 0, width: 72, height: 36))
        case .mapStandard : super.init(frame: CGRect(x: 0, y: 0, width: 48, height: 32))
        }
        
        self.number = number
        self.backgroundColor = .clear
        
        let frame = type == .mapStandard ? CGRect(x: 0, y: 0, width: 48, height: 24) : self.frame
        let base = UIView(frame: frame)
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
        
        if type == .mapStandard {
            
            let size = min(base.frame.width, base.frame.height / 3)
            let frame = CGRect(x: base.frame.width / 2 - (size / 2), y: base.frame.maxY, width: size, height: size)
            let tail = TriangleView(frame: frame)
            addSubview(tail)
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class TriangleView : UIView {
    
    var color: UIColor!
    
    init(frame: CGRect, color: UIColor = .tcatBlueColor) {
        self.color = color
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext()
            else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.maxY))
        context.closePath()
        
        context.setFillColor(color.cgColor)
        context.fillPath()
        
    }
    
}
