//
//  UIColor+Shared.swift
//  TCAT
//
//  Created by Annie Cheng on 3/5/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import CoreLocation
import TRON

extension UIColor {
    
    @nonobjc static let tcatBlueColor = UIColor(red: 7 / 255, green: 157 / 255, blue: 220 / 255, alpha: 1.0)
    
    @nonobjc static let buttonColor = UIColor(red: 0 / 255, green: 118 / 255, blue: 255 / 255, alpha: 1)
    @nonobjc static let primaryTextColor = UIColor(white: 34 / 255, alpha: 1.0)
    @nonobjc static let secondaryTextColor = UIColor(white: 74 / 255, alpha: 1.0)
    @nonobjc static let tableHeaderColor = UIColor(white: 100 / 255, alpha: 1.0)
    @nonobjc static let mediumGrayColor = UIColor(white: 155 / 255, alpha: 1.0)
    @nonobjc static let tableViewHeaderTextColor = UIColor(white: 71 / 255, alpha: 1.0)
    @nonobjc static let lineColor = UIColor(white: 230 / 255, alpha: 1.0)
    @nonobjc static let lineDarkColor = UIColor(white: 216 / 255, alpha: 1)
    @nonobjc static let tableBackgroundColor = UIColor(white: 242 / 255, alpha: 1.0)
    @nonobjc static let summaryBackgroundColor = UIColor(white: 248 / 255, alpha: 1.0)
    @nonobjc static let optionsTimeBackgroundColor = UIColor(white: 252 / 255, alpha: 1.0)
    @nonobjc static let searchBarCursorColor = UIColor.black
    @nonobjc static let searchBarPlaceholderTextColor = UIColor(red: 214.0 / 255.0, green: 216.0 / 255.0, blue: 220.0 / 255.0, alpha: 1.0)
    @nonobjc static let noInternetTextColor = UIColor(red: 0.0, green: 118.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    @nonobjc static let placeColor = UIColor(white: 151.0 / 255.0, alpha: 1.0)
    
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

extension UILabel {
    /// Returns the number of lines the UILabel will take based on its width.
    func numberOfLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let labelText = (text ?? "") as NSString
        let textSize = labelText.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return Int(textSize.height/charSize)
    }
}

extension UIViewController {
    
    var isModal: Bool {
        if let index = navigationController?.viewControllers.index(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController  {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
    
}

extension JSON {
    
    /// Format date with pattern `"yyyy-MM-dd'T'HH:mm:ssZZZZ"`. Returns current date on error.
    func parseDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        let date = dateFormatter.date(from: self.stringValue) ?? Date.distantPast
        return date
    }
    
    /// Create coordinate object from JSON.
    func parseCoordinates() -> CLLocationCoordinate2D {
        let latitude = self["lat"].doubleValue
        let longitude = self["long"].doubleValue
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Create Bounds object
    func parseBounds() -> Bounds {
        return Bounds(
            minLat: self["minLat"].doubleValue,
            minLong: self["minLong"].doubleValue,
            maxLat: self["maxLat"].doubleValue,
            maxLong: self["maxLong"].doubleValue
        )
    }
    
    /** Return LocationObject.
     
        `id` is used when bus stops conform to this object.
        Would like a way to extend this class for instances when JSON
        strings are unique to the generic location (e.g. stopID)
    */
    func parseLocationObject() -> LocationObject {
        return LocationObject(
            name: self["name"].stringValue,
            id: self["stopID"].stringValue,
            latitude: self["lat"].doubleValue,
            longitude: self["long"].doubleValue
        )
    }
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst()).lowercased()
        return first + other
    }
}

extension CLLocationCoordinate2D {
    // MARK: CLLocationCoordinate2D+MidPoint
    func middleLocationWith(location:CLLocationCoordinate2D) -> CLLocationCoordinate2D {

        let lon1 = longitude * .pi / 180
        let lon2 = location.longitude * .pi / 180
        let lat1 = latitude * .pi / 180
        let lat2 = location.latitude * .pi / 180
        let dLon = lon2 - lon1
        let x = cos(lat2) * cos(dLon)
        let y = cos(lat2) * sin(dLon)

        let lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) )
        let lon3 = lon1 + atan2(y, cos(lat1) + x)

        let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat3 * 180 / .pi, lon3 * 180 / .pi)
        return center
    }
}

extension Double {
    /// Rounds the double to decimal places value
    mutating func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}

extension Array where Element: UIView {
    /// Remove each view from its superview.
    func removeViewsFromSuperview(){
        self.forEach { $0.removeFromSuperview() }
    }
}

extension Array : JSONDecodable {
    public init(json: JSON) {
        self.init(json.arrayValue.flatMap {
            if let type = Element.self as? JSONDecodable.Type {
                let element : Element?
                do {
                    element = try type.init(json: $0) as? Element
                } catch {
                    return nil
                }
                return element
            }
            return nil
        })
    }
}

/** Bold a phrase that appears in a string, and return the attributed string */
func bold(pattern: String, in string: String) -> NSMutableAttributedString {
    let fontSize = UIFont.systemFontSize
    let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: fontSize)])
    let boldFontAttribute = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: fontSize)]
    
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let ranges = regex.matches(in: string, options: [], range: NSMakeRange(0, string.count)).map {$0.range}
        for range in ranges { attributedString.addAttributes(boldFontAttribute, range: range) }
    } catch { }
    
    return attributedString
}

/** Convert distance from meters to proper unit (based on size)
 
 - Huge Distances: 16 mi
 - Medium Distances: 3.2 mi
 - Small Distances: 410 ft (412 ft -> 410 ft)
 
 */
func roundedString(_ value: Double) -> String {
    
    let numberOfMetersInMile = 1609.34
    var distanceInMiles = value / numberOfMetersInMile
    
    switch distanceInMiles {
        
    case let x where x >= 10:
        return "\(Int(distanceInMiles)) mi"
        
    case let x where x < 0.1:
        var distanceInFeet = distanceInMiles * 5280
        var temporaryValue = distanceInFeet.roundTo(places: 0) / 10.0
        distanceInFeet = temporaryValue.roundTo(places: 0) * 10.0
        return "\(Int(distanceInFeet)) ft"
        
    default:
        return "\(distanceInMiles.roundTo(places: 1)) mi"
        
    }
    
}

func areObjectsEqual<T: Equatable>(type: T.Type, a: Any, b: Any) -> Bool {
    guard let a = a as? T, let b = b as? T else { return false }
    return a == b
}

infix operator ???: NilCoalescingPrecedence

public func ???<T>(optional: T?, defaultValue: @autoclosure () -> String) -> String {
    switch optional {
    case let value?: return String(describing: value)
    case nil: return defaultValue()
    }
}

func sortFilteredBusStops(busStops: [BusStop], letter: Character) -> [BusStop]{
    var nonLetterArray = [BusStop]()
    var letterArray = [BusStop]()
    for stop in busStops {
        if stop.name.first! == letter {
            letterArray.append(stop)
        } else {
            nonLetterArray.append(stop)
        }
    }
    return letterArray + nonLetterArray
}
