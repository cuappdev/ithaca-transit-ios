//
//  UIColor+Shared.swift
//  TCAT
//
//  Created by Annie Cheng on 3/5/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import MapKit

extension UIColor {
    @nonobjc static let tcatBlueColor = UIColor(red: 7 / 255, green: 157 / 255, blue: 220 / 255, alpha: 1.0)
    @nonobjc static let primaryTextColor = UIColor(white: 34 / 255, alpha: 1.0)
    @nonobjc static let secondaryTextColor = UIColor(white: 74 / 255, alpha: 1.0)
    @nonobjc static let tableHeaderColor = UIColor(white: 100 / 255, alpha: 1.0)
    @nonobjc static let mediumGrayColor = UIColor(white: 155 / 255, alpha: 1.0)
    @nonobjc static let lineColor = UIColor(white: 230 / 255, alpha: 1.0)
    @nonobjc static let lineDarkColor = UIColor(white: 216 / 255, alpha: 1)
    @nonobjc static let tableBackgroundColor = UIColor(white: 242 / 255, alpha: 1.0)
    @nonobjc static let summaryBackgroundColor = UIColor(white: 248 / 255, alpha: 1.0)
    @nonobjc static let optionsTimeBackgroundColor = UIColor(white: 252 / 255, alpha: 1.0)
    @nonobjc static let searchBarPlaceholderTextColor = UIColor(red: 214.0 / 255.0, green: 216.0 / 255.0, blue: 220.0 / 255.0, alpha: 1.0)
    
    // Get color from hex code
    public static func colorFromCode(_ code: Int, alpha: CGFloat) -> UIColor {
        let red = CGFloat(((code & 0xFF0000) >> 16)) / 255
        let green = CGFloat(((code & 0xFF00) >> 8)) / 255
        let blue = CGFloat((code & 0xFF)) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension MKPolyline {
    public var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                              count: self.pointCount)
        
        self.getCoordinates(&coords, range: NSRange(location: 0, length: self.pointCount))
        
        return coords
    }
}

/** Round specific corners of UIView */
extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

/** Bold a phrase that appears in a string, and return the attributed string */
func bold(pattern: String, in string: String) -> NSMutableAttributedString {
    let fontSize = UIFont.systemFontSize
    let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: fontSize)])
    let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize)]
    
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let ranges = regex.matches(in: string, options: [], range: NSMakeRange(0, string.characters.count)).map {$0.range}
        for range in ranges { attributedString.addAttributes(boldFontAttribute, range: range) }
    } catch { }
    
    return attributedString
}

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst()).lowercased()
        return first + other
    }
}

extension Double {
    /// Rounds the double to decimal places value
    mutating func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}

func areObjectsEqual<T: Equatable>(type: T.Type, a: Any, b: Any) -> Bool {
    guard let a = a as? T, let b = b as? T else { return false }
    return a == b
}
