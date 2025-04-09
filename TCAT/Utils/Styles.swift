//
//  Styles.swift
//  TCAT
//
//  Created by Matt Barker on 10/12/19.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit

/// App colors
struct Colors {

    // MARK: - Brand Color
    static let tcatBlue = UIColor(hex: "079DDC")
    static let notificationBlue = UIColor(hex: "08A0E0")

    // MARK: - Accent Colors
    static let lateRed = UIColor(hex: "D6304F")
    static let liveGreen = UIColor(hex: "27AE60")
    static let warningOrange = UIColor(hex: "E79C20")

    // MARK: - Grayscale Colors
    static let primaryText = UIColor(hex: "212121")
    static let secondaryText = UIColor(hex: "616161")
    static let metadataIcon = UIColor(hex: "9E9E9E")
    static let dividerTextField = UIColor(hex: "EEEEEE")
    static let backgroundWash = UIColor(hex: "F5F5F5")
    static let tableViewSeparator = UITableView().separatorColor!

    // MARK: - Constants
    static let black = UIColor.black
    static let white = UIColor.white
    static let carouselGray = UIColor(hex: "EFF1F4")

}

/// Font identifiers
enum Fonts {

    case regular, medium, semibold, bold

    enum SanFrancisco {

        struct ProDisplay {
            static let regular = "SFProDisplay-Regular"
            static let medium = "SFProDisplay-Medium"
            static let semibold = "SFProDisplay-Semibold"
            static let bold = "SFProDisplay-Bold"
        }

        struct ProText {
            static let regular = "SFUIText-Regular"
            static let medium = "SFUIText-Medium"
            static let semibold = "SFUIText-Semibold"
            static let bold = "SFUIText-Bold"
        }

    }

}

extension UIFont {

    /// Generate fonts for app usage
    static func getFont(_ name: Fonts, size: CGFloat) -> UIFont {
        var fontString: String
        if size >= 14 {
            switch name {
            case .regular:
                fontString = Fonts.SanFrancisco.ProDisplay.regular

            case .medium:
                fontString = Fonts.SanFrancisco.ProDisplay.medium

            case .semibold:
                fontString = Fonts.SanFrancisco.ProDisplay.semibold

            case .bold:
                fontString = Fonts.SanFrancisco.ProDisplay.bold
            }
        } else {
            switch name {
            case .regular:
                fontString = Fonts.SanFrancisco.ProText.regular

            case .medium:
                fontString = Fonts.SanFrancisco.ProText.medium

            case .semibold:
                fontString = Fonts.SanFrancisco.ProText.semibold

            case .bold:
                fontString = Fonts.SanFrancisco.ProText.bold
            }
        }
        return UIFont(name: fontString, size: size)!
    }

}

struct Spacing {

    static let eight: CGFloat = 8
    static let twelve: CGFloat = 12
    static let fourteen: CGFloat = 14
    static let twentyFour: CGFloat = 24

}
