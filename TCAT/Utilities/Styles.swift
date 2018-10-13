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
        static let regular = "SFProDisplay-Regular"
        static let medium = "SFProDisplay-Medium"
        static let semibold = "SFProDisplay-Semibold"
        static let bold = "SFProDisplay-Bold"
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
        
        let sanFrancisco: [String] = [
            Fonts.SanFrancisco.regular,
            Fonts.SanFrancisco.medium,
            Fonts.SanFrancisco.semibold,
            Fonts.SanFrancisco.bold
        ]
        
        // Installed San Francisco Font
        if sanFrancisco.contains(name) {
            print(UIFont.fontNames(forFamilyName: "SF Pro Display"))
            let fontStringArray = name.split(separator: "-")
            let textStyle = fontStringArray.last ?? ""
            let descriptor = UIFontDescriptor(fontAttributes: [
                UIFontDescriptor.AttributeName.name : name,
                /*UIFontDescriptor.AttributeName.family : "SF Pro Display",*/
                /*UIFontDescriptor.AttributeName.textStyle : textStyle*/
            ])
            return UIFont(descriptor: descriptor, size: size)
        }
        
        // System Font
        else {
            
        }
        
    }
    
}

// MARK: - Spacing

