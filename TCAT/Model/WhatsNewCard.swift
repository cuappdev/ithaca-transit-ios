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
        title: "Integrated Service Alerts",
        description: "View all active service alerts provided by TCAT. All route calculations incorporate this data.",
        primaryActionTitle: "View",
        primaryActionHandler: { (homeViewController) in
            let informationViewController = InformationViewController()
            let navigationVC = CustomNavigationController(rootViewController: informationViewController)
            homeViewController.present(navigationVC, animated: true, completion: {
                let payload = ServiceAlertsPayload(didTapWhatsNew: true)
                Analytics.shared.log(payload)
                informationViewController.showServiceAlerts()
            })
        },
        secondaryActionTitle: nil,
        secondaryActionHandler: nil
    )
    
    // MARK: Upcoming Updates
    
    // Twitter Update
    
    // var title = "@IthacaTransit on Twitter"
    // var description = "Follow our new Twitter account for schedule changes, app statuses, and promotions!",
    
    // var appLink = "twitter://user?screen_name=IthacaTransit"
    // var webLink = "https://twitter.com/IthacaTransit"
    
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
    
    /// The function to perform in the app when an action is selected.
    var primaryActionHandler: ((_: HomeViewController) -> ())?
    
    
    // MARK: Secondary Button - Gray, Regular
    
    /// The title of the secondary button. If doesn't exist, make nil to hide button.
    var secondaryActionTitle: String?
    
    /// The function to perform in the app when an action is selected.
    var secondaryActionHandler: ((_: HomeViewController) -> ())?
    
    
    // MARK: Functions
    
    /// Open a website or app link if an action is selected.
    func actionLinkHandler(webLink: String?, appLink: String?, completion: @escaping () -> Void) {
        if let link = webLink {
            open(link, optionalAppLink: appLink) {
                completion()
            }
        } else {
            completion()
        }
    }
    
    /// Helpfer function to open web or app links.
    private func open(_ link: String, optionalAppLink: String?, linkOpened: @escaping () -> Void) {
        if
            let appLink = optionalAppLink,
            let appURL = URL(string: appLink),
            UIApplication.shared.canOpenURL(appURL)
        {
            // Open link in an installed app.
            UIApplication.shared.open(appURL, options: [:]) { _ in
                linkOpened()
            }
        }
            
        else if let webURL = URL(string: link) {
            // Open link in Safari.
            UIApplication.shared.open(webURL, options: [:]) { _ in
                linkOpened()
            }
        }
    }
    
}
