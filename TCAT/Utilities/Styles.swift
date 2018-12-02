//
//  Styles.swift
//  TCAT
//
//  Created by Matt Barker on 10/12/19.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit

// MARK: - Colors

// MARK: - Fonts

/// Font identifiers
struct Fonts {
    
    struct SanFrancisco {
        
        // Pro Display (New)
        static let regularPro = "SFProDisplay-Regular"
        static let mediumPro = "SFProDisplay-Medium"
        static let semiboldPro = "SFProDisplay-Semibold"
        static let boldPro = "SFProDisplay-Bold"
        
        // UI Text (Old)
        static let regular = "SFUIText-Regular"
        static let medium = "SFUIText-Medium"
        static let semibold = "SFUIText-Semibold"
        static let bold = "SFUIText-Bold"
        
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
        return UIFont(name: name, size: size)!
    }
    
}

// MARK: - Spacing

