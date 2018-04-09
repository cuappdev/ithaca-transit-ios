//
//  BusIcon.swift
//  TCAT
//
//  Created by Matthew Barker on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//
import UIKit

enum BusIconType: String {
    case directionSmall, directionLarge, liveTracking
    
    var width: CGFloat {
        switch self {
        case .directionSmall:
            return 48
        case .liveTracking:
            return 72
        case .directionLarge:
            return 72
        }
    }
    
    var height: CGFloat {
        switch self {
        case .directionSmall:
            return 24
        case .liveTracking:
            return 30
        case .directionLarge:
            return 36
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .directionLarge:
            return 8
        default:
            return 4
        }
    }
}

class BusIcon: UIView {
    
    // MARK: Data vars
    
    let type: BusIconType
    let number: Int
    
    // MARK: View vars
    
    var baseView: UIView!
    var label: UILabel!
    var image: UIImageView!
    var liveIndicator: LiveIndicator?
    
    // MARK: Constraint vars
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: type.width, height: type.height)
    }
    
    // MARK: Init
    
    init(type: BusIconType, number: Int) {
        self.type = type
        self.number = number

        super.init(frame: CGRect(x: 0, y: 0, width: type.width, height: type.height))
        
        self.backgroundColor = .clear
        
        baseView = UIView(frame: self.frame)
        baseView.backgroundColor = .tcatBlueColor
        baseView.layer.cornerRadius = type.cornerRadius
        addSubview(baseView)
        
        image = UIImageView(image: UIImage(named: "bus"))
        let constant: CGFloat = type == .directionSmall ? 0.75 : 1.0
        image.frame.size = CGSize(width: image.frame.width * constant, height: image.frame.height * constant)
        image.tintColor = .white
        image.center.y = baseView.center.y
        image.frame.origin.x = type == .directionSmall ? 8 : 12
        addSubview(image)
        
        label = UILabel(frame: CGRect(x: image.frame.maxX, y: 0, width: frame.width - image.frame.maxX, height: frame.height))
        label.text = "\(number)"
        label.font = UIFont.systemFont(ofSize: type == .directionLarge ? 20 : 14, weight: UIFont.Weight.semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.center.y = baseView.center.y
        label.frame.size.width = frame.maxX - image.frame.maxX
        label.frame.origin.x = image.frame.maxX
        addSubview(label)
        
        if type == .liveTracking {
            
            label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
            label.sizeToFit()
            image.frame.origin.x = 8
            let sizeConstant: CGFloat = 0.87
            image.frame.size = CGSize(width: image.frame.width * sizeConstant, height: image.frame.height * sizeConstant)
            label.center.y = baseView.center.y
            label.frame.origin.x = image.frame.maxX + 4
            
            liveIndicator = LiveIndicator(size: .large, color: .white)
            liveIndicator!.frame.origin = CGPoint(x: label.frame.maxX + 4, y: label.frame.origin.y)
            liveIndicator!.center.y = baseView.center.y
            addSubview(liveIndicator!)
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        type = .directionSmall
        number = 99
        super.init(coder: aDecoder)
    }
    
    // MARK: Reuse
    
    func prepareForReuse() {
        baseView.removeFromSuperview()
        label.removeFromSuperview()
        image.removeFromSuperview()
        liveIndicator?.removeFromSuperview()
    }
    
}
