//
//  UIColor+Shared.swift
//  TCAT
//
//  Created by Annie Cheng on 3/5/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    @nonobjc static let departTimeColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
    @nonobjc static let travelTimeColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
    @nonobjc static let stopLabelColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
    @nonobjc static let stopNumColor1 = UIColor(red: 243/255, green: 156/255, blue: 18/255, alpha: 1.0)
    @nonobjc static let stopNumColor2 = UIColor(red: 255/255, green: 97/255, blue: 116/255, alpha: 1.0)
    @nonobjc static let distanceLabelColor = UIColor(red: 187/255, green: 187/255, blue: 187/255, alpha: 1.0)
    @nonobjc static let pinColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
    @nonobjc static let tcatBlue = UIColor.colorFromCode(0x3A96FF, alpha: 1)
    
    // Get color from hex code
    public static func colorFromCode(_ code: Int, alpha: CGFloat) -> UIColor {
        let red = CGFloat(((code & 0xFF0000) >> 16)) / 255
        let green = CGFloat(((code & 0xFF00) >> 8)) / 255
        let blue = CGFloat((code & 0xFF)) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
