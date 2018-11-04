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
    
    // MARK: - Accent Colors
    static let lateRed = UIColor(hex: "D6304F")
    static let liveGreen = UIColor(hex: "27AE60")
    static let warningOrange = UIColor(hex: "E79C20")
    
    // MARK: - Grayscale Colors
    static let primaryText = UIColor(hex: "212121")
    static let secondaryText = UIColor(hex: "616161")
    static let metadataIcon = UIColor(hex: "BDBDBD")
    static let dividerTextField = UIColor(hex: "EEEEEE")
    static let backgroundWash = UIColor(hex: "F5F5F5")
    
}

/// Font identifiers
struct Fonts {
    
    struct SanFrancisco {
        
        // General Sizes
        static let regular = "regular"
        static let medium = "medium"
        static let semibold = "semibold"
        static let bold = "bold"
        
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
    
    struct System {
        // Placeholder for init function below, not actually used.
        static let systemFontSize: CGFloat = 14 // Same as UIFont.systemFontSize
        
        static let regular = UIFont.systemFont(ofSize: systemFontSize, weight: .regular).fontName
        static let semibold = UIFont.systemFont(ofSize: systemFontSize, weight: .semibold).fontName
        static let bold = UIFont.systemFont(ofSize: systemFontSize, weight: .bold).fontName
    }
    
}

extension UIFont {
    
    /// Generate fonts for app usage
    static func style(_ name: String, size: CGFloat) -> UIFont {
        var name = name
        if size >= 14 {
            switch name {
            case Fonts.SanFrancisco.regular: name = Fonts.SanFrancisco.ProDisplay.regular
            case Fonts.SanFrancisco.medium: name = Fonts.SanFrancisco.ProDisplay.medium
            case Fonts.SanFrancisco.semibold: name = Fonts.SanFrancisco.ProDisplay.semibold
            case Fonts.SanFrancisco.bold: name = Fonts.SanFrancisco.ProDisplay.bold
            default: break
            }
        } else {
            switch name {
            case Fonts.SanFrancisco.regular: name = Fonts.SanFrancisco.ProText.regular
            case Fonts.SanFrancisco.medium: name = Fonts.SanFrancisco.ProText.medium
            case Fonts.SanFrancisco.semibold: name = Fonts.SanFrancisco.ProText.semibold
            case Fonts.SanFrancisco.bold: name = Fonts.SanFrancisco.ProText.bold
            default: break
            }
        }
        return UIFont(name: name, size: size)!
    }
    
}

struct Spacing {
    
    static let eight: CGFloat = 8
    static let twelve: CGFloat = 12
    static let fourteen: CGFloat = 14
    static let twentyFour: CGFloat = 24
    
}

