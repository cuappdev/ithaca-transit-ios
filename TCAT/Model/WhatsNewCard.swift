//
//  WhatsNewCard.swift
//  TCAT
//
//  Created by Matt Barker on 3/6/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

struct WhatsNewCard {
    
    // MARK: Current What's New Card Data
    
    static let current = WhatsNewCard(
        label: "New in Ithaca Transit",
        title: "@IthacaTransit on Twitter",
        description: "Follow our new Twitter account for schedule changes, app statuses, and promotions!",
        primaryActionTitle: "View",
        primaryActionAppLink: "twitter://user?screen_name=IthacaTransit",
        primaryActionWebLink: "https://twitter.com/IthacaTransit",
        secondaryActionTitle: "Dismiss",
        secondaryActionAppLink: nil,
        secondaryActionWebLink: nil
    )
    
    // MARK: Main Descriptions
    
    /// This is the small blue label above the main title. Will be entirely uppercased in UI.
    var label: String
    
    /// The bolded main title of the card describing the update feature.
    var title: String
    
    /// A succinct description of the update feature.
    var description: String
    
    
    // MARK: Primary Button - Blue, Bolded
    
    // IMPORTANT: At least ONE action title *must* be set to create a button. It can be either for primary or secondary.
    
    /// The title of the primary button. If doesn't exist, make nil to hide button.
    var primaryActionTitle: String?
    
    /// If a button uses a web link, enter the app-specific URL. Otherwise, nil.
    var primaryActionAppLink: String?
    
    /// If a button uses a web link, enter the HTTPS URL. Otherwise, nil.
    var primaryActionWebLink: String?
    
    
    // MARK: Secondary Button - Gray, Regular
    
    /// The title of the secondary button. If doesn't exist, make nil to hide button.
    var secondaryActionTitle: String?
    
    /// If a button uses a web link, enter the app-specific URL. Otherwise, nil.
    var secondaryActionAppLink: String?
    
    /// If a button uses a web link, enter the app-specific URL. Otherwise, nil.
    var secondaryActionWebLink: String?
    
}
