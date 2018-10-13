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
        static let regular = "SFUIText-Regular"
        static let medium = "SFUIText-Medium"
        static let semibold = "SFUIText-Semibold"
        static let bold = "SFUIText-Bold"
    }
    
    struct System {
        private static let regularFont = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: UIFont.Weight.regular)
        static let regular = regularFont.fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.name] as! String
        
        private static let semiboldFont = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: UIFont.Weight.semibold)
        static let semibold = semiboldFont.fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.name] as! String
        
        private static let boldFont = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: UIFont.Weight.bold)
        static let bold = boldFont.fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.name] as! String
        
        // Make sure NSString as! String works
        // Was previously UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
    }
    
}

extension UIFont {
    
    /// Generate fonts for app usage
    static func style(_ name: String, size: CGFloat) -> UIFont {
        
        print("name:", name)
        return UIFont(name: name, size: size)!
        
        let sanFrancisco: [String] = [
            Fonts.SanFrancisco.regular,
            Fonts.SanFrancisco.medium,
            Fonts.SanFrancisco.semibold,
            Fonts.SanFrancisco.bold
        ]
        
        let system: [String] = [
            Fonts.System.regular,
            Fonts.System.semibold,
            Fonts.System.bold
        ]
        
        if sanFrancisco.contains(name) {
            
        }
        
        if system.contains(name) {

        }
        
    }
    
}

// MARK: - Spacing

