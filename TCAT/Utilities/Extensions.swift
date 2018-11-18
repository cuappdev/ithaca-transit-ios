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

let increaseTapTargetTag: Int = 1865

extension UIColor {

    @nonobjc static let tcatBlueColor = UIColor(red: 7 / 255, green: 157 / 255, blue: 220 / 255, alpha: 1)

    @nonobjc static let buttonColor = UIColor(red: 0 / 255, green: 118 / 255, blue: 255 / 255, alpha: 1)
    @nonobjc static let primaryTextColor = UIColor(white: 34 / 255, alpha: 1)
    @nonobjc static let secondaryTextColor = UIColor(white: 74 / 255, alpha: 1)
    @nonobjc static let tableHeaderColor = UIColor(white: 100 / 255, alpha: 1)

    @nonobjc static let lineDotColor = UIColor(white: 216 / 255, alpha: 1)
    @nonobjc static let mediumGrayColor = UIColor(white: 155 / 255, alpha: 1)

    @nonobjc static let tableViewHeaderTextColor = UIColor(white: 71 / 255, alpha: 1)
    @nonobjc static let tableBackgroundColor = UIColor(white: 242 / 255, alpha: 1)
    @nonobjc static let summaryBackgroundColor = UIColor(white: 248 / 255, alpha: 1)
    @nonobjc static let optionsTimeBackgroundColor = UIColor(white: 252 / 255, alpha: 1)
    @nonobjc static let searchBarCursorColor = UIColor.black
    @nonobjc static let searchBarPlaceholderTextColor = UIColor(red: 214 / 255, green: 216 / 255, blue: 220 / 255, alpha: 1)
    @nonobjc static let noInternetTextColor = UIColor(red: 0.0, green: 118 / 255, blue: 255 / 255, alpha: 1)

    @nonobjc static let liveGreenColor = UIColor(red: 39 / 255, green: 174 / 255, blue: 96 / 255, alpha: 1)
    @nonobjc static let liveRedColor = UIColor(red: 214 / 255, green: 48 / 255, blue: 79 / 255, alpha: 1)

    // Use six-character string of a hex color for initialization
    convenience init(hex: String) {
        let hex = Int(hex, radix: 16)!
        self.init(red: (hex >> 16) & 0xff, green: (hex >> 8) & 0xff, blue: hex & 0xff)
    }

    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
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

extension UIView {

    /** Round specific corners of UIView */
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    /// Get UIImage of passed in view
    func getImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, isOpaque, 0.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
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

    // Find the position of a string in a label
    func boundingRect(of string: String) -> CGRect? {

        guard let range = self.text?.range(of: string) else { return nil }
        let nsRange = string.nsRange(from: range)

        guard let attributedText = attributedText else { return nil }

        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()

        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0

        layoutManager.addTextContainer(textContainer)

        var glyphRange = NSRange()

        // Convert the range for glyphs.
        layoutManager.characterRange(forGlyphRange: nsRange, actualGlyphRange: &glyphRange)

        return layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    }

}

extension UIViewController {

    var isModal: Bool {
        if let index = navigationController?.viewControllers.index(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }

}

extension UIDevice {

    // Updated 3/16 - https://stackoverflow.com/questions/26028918/how-to-determine-the-current-iphone-device-model

    var modelName: String {

        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {

        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier

        }
    }

}

extension String {

    /// See function name
    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst()).lowercased()
        return first + other
    }

    /// Convert Range to NSRange
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.encodedOffset
        let to = range.upperBound.encodedOffset
        return NSRange(location: from - startIndex.encodedOffset, length: to - from)
    }

    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin],
                                            attributes: [.font: font], context: nil)
        return boundingBox.height
    }
    /** Bold a phrase that appears in a string, and return the attributed string. Only shows the last bolded phrase.

        - Parameter containerText: The string to scan through and make `self` bold inside.
        - Parameter originalFont: The initial font of the containerText.
        - Parameter boldFont: The font to make the bold string.
     */
    func bold(in containerText: String, from originalFont: UIFont, to boldFont: UIFont) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: containerText, attributes: [.font: originalFont])
        return self.bold(in: attributedString, to: boldFont)
    }

    /** Bold a phrase that appears in an attributed string, and return the attributed string */
    func bold(in containerText: NSMutableAttributedString, to boldFont: UIFont) -> NSMutableAttributedString {

        let pattern = self
        let attributedString: NSMutableAttributedString = containerText
        let newAttributedString = attributedString
        let plain_string: String = attributedString.string

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let ranges = regex.matches(in: plain_string, options: [], range: NSRange(location: 0, length: plain_string.count)).map { $0.range }
            for range in ranges { newAttributedString.addAttributes([.font: boldFont], range: range) }
        } catch {
            print("bold NSRegularExpression failed")
        }

        return newAttributedString

    }
}

extension CLLocationCoordinate2D: Codable {
    // MARK: CLLocationCoordinate2D+MidPoint
    func middleLocationWith(location: CLLocationCoordinate2D) -> CLLocationCoordinate2D {

        let lon1 = longitude * .pi / 180
        let lon2 = location.longitude * .pi / 180
        let lat1 = latitude * .pi / 180
        let lat2 = location.latitude * .pi / 180
        let dLon = lon2 - lon1
        let x = cos(lat2) * cos(dLon)
        let y = cos(lat2) * sin(dLon)

        let lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) )
        let lon3 = lon1 + atan2(y, cos(lat1) + x)

        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat3 * 180 / .pi, lon3 * 180 / .pi)
        return center
    }

    private enum CodingKeys: String, CodingKey {
        case lat
        case long
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }

    public init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        longitude = try container.decode(Double.self, forKey: .long)
        latitude = try container.decode(Double.self, forKey: .lat)

    }
}

extension DateFormatter {
    static let defaultParser: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        return dateFormatter
    }()
}

extension Double {

    /** Convert distance from meters to proper unit (based on size)

     - Huge Distances: 16 mi
     - Medium Distances: 3.2 mi
     - Small Distances: 410 ft (412 ft -> 410 ft)

     */
    var roundedString: String {

        let numberOfMetersInMile = 1609.34
        var distanceInMiles = self / numberOfMetersInMile

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

    /// Rounds the double to decimal places value
    mutating func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }

}

extension Array where Element: UIView {
    /// Remove each view from its superview.
    func removeViewsFromSuperview() {
        self.forEach { $0.removeFromSuperview() }
    }
}

extension Array: JSONDecodable {
    public init(json: JSON) {
        self.init(json.arrayValue.compactMap {
            if let type = Element.self as? JSONDecodable.Type {
                let element: Element?
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

/// Present a share sheet for a route in any context.
func presentShareSheet(from view: UIView, for route: Route, with image: UIImage? = nil) {

    let shareText = route.summaryDescription
    let promotionalText = "Download Ithaca Transit on the App Store! \(Constants.App.appStoreLink)"

    var activityItems: [Any] = [promotionalText]
    if let shareImage = image {
        activityItems.insert(shareImage, at: 0)
    } else {
        activityItems.insert(shareText, at: 0)
    }

    let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    activityVC.excludedActivityTypes = [.print, .assignToContact, .openInIBooks, .addToReadingList]
    activityVC.popoverPresentationController?.sourceView = view
    activityVC.completionWithItemsHandler = { (activity, completed, items, error) in
        let sharingMethod = activity?.rawValue.replacingOccurrences(of: "com.apple.UIKit.activity.", with: "") ?? "None"
        let payload = RouteSharedEventPayload(activityType: sharingMethod, didSelectAndCompleteShare: completed, error: error?.localizedDescription)
        Analytics.shared.log(payload)
    }

    UIApplication.shared.delegate?.window??.presentInApp(activityVC)

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

func sortFilteredBusStops(busStops: [BusStop], letter: Character) -> [BusStop] {
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

extension Collection {

    subscript(optional i: Index) -> Iterator.Element? {
        return self.indices.contains(i) ? self[i] : nil
    }

}

class JsonDecoderWithCustomDate: JSONDecoder {
    override init() {
        super.init()

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"

        self.dateDecodingStrategy = .formatted(dateFormatter)
    }
}
