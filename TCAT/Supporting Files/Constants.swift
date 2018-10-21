//
//  Constants.swift
//  TCAT
//
//  Created by Monica Ong on 9/16/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

/// App-wide constants
struct Constants {

    /// The actions used for alerts
    struct Actions {
        // Alert actions
        static let settings = "Settings"
        static let cancel = "Cancel"
        static let dontRemind = "Don't Remind Me Again"
        static let gotIt = "Got It!"
        static let emailSettings = "Email Settings"
        static let copyEmail = "Copy Address to Clipboard"
        static let teleportation = "😐😒🙄"
        static let OK = "OK"

        // Other button actions
        static let retry = "Retry"
        static let done = "Done"
        static let magicSchoolBus = "✨📚🚌"
        static let dismiss = "Dismiss"
        static let begin = "BEGIN"
        static let share = "Share"
        static let back = "  Back"
    }

    /// The messages used for alerts
    struct AlertMessages {
        static let locationDisabled = "The app won't be able to use your current location without permission. Tap Settings to turn on Location Services."
        static let limitedLocation = "Tap Settings to change your location permissions, or continue using a limited version of the app."
        static let enableLocation = "You need to enable Location Services in Settings"
        static let maxFavorites = "To add more favorites, please swipe left and delete one first."
        static let couldntSendEmail = "To send your message with device logs, please add an email account in Settings > Accounts & Passwords > Add Account. You can also contact us at " + Constants.App.contactEmailAddress + " to send feedback."
        static let saysTheBus = "says the TCAT bus."
        static let teleportation = "You have arrived at your destination. Thank you for using our TCAT Teleporation™ feature (beta)."
        static let outOfRange = "Try looking for another route with start and end locations closer to Tompkins County."
    }

    /// The titles used for alerts
    struct AlertTitles {
        static let locationDisabled = "Location Services Disabled"
        static let maxFavorites = "Maximum Number of Favorites"
        static let couldntSendEmail = "Couldn't Send Email"
        static let beep = "Be-beep be-beep!"
        static let teleportation = "You're here!"
        static let outOfRange = "Location Out Of Range"
    }

    struct App {
        /// The App Store Identifier used in App Store links
        static let storeIdentifier: String = "\(1290883721)"

        /// The link of the application in the App Store
        static let appStoreLink: String = "https://itunes.apple.com/app/id\(storeIdentifier)"

        /// The app version within the App Store (e.g. "1.4.2") [String value of `CFBundleShortVersionString`]
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"

        /// Developer email address to direct contact inquiries and emails toward
        static let contactEmailAddress = "ithacatransit@cornellappdev.com"

        /// Link to Google Forms for Feedback
        // static let feedbackLink = "https://goo.gl/forms/jYejUtVccVQ3UHH12"
    }

    /// Banner titles
    struct Banner {
        static let noInternetConnection = "No internet connection"
        static let trackingLater = "Tracking available near departure time"
        static let cannotConnectLive = "Cannot connect to live tracking"
        static let noLiveTrackingForRoutes = "No live tracking available for routes"
        static let noLiveTrackingForRoute = "No live tracking available for Route "
        static let cantConnectServer = "Could not connect to server"
        static let calculationError = "Route calculation error. Please retry."
    }

    struct BusUserData {
        static let actualCoordinates = "actualCoords"
        static let indicatorCoordinates = "indicatorCoords"
        static let vehicleID = "vehicleID"
    }

    /// Cell identifiers
    struct Cells {
        static let busIdentifier = "BusStop"
        static let searchResultsIdentifier = "SearchResults"
        static let cornellDestinationsIdentifier = "CornellDestinations"
        static let seeAllStopsIdentifier = "SeeAllStops"
        static let currentLocationIdentifier = "CurrentLocation"
        static let smallDetailCellIdentifier = "SmallCell"
        static let largeDetailCellIdentifier = "LargeCell"
        static let busStopCellIdentifier = "BusStopCell"
        static let informationCellIdentifier = "InformationCell"
    }

    /// The empty state messages
    struct EmptyStateMessages {
        // Error messages
        static let couldntGetStops = "Couldn't Get Stops"
        static let locationNotFound = "Location Not Found"
        static let noNetworkConnection = "No Network Connection"
        static let noRoutesFound = "No Routes Found"

        // Other empty state messages
        static let lookingForRoutes = "Looking For Routes..."
    }

    struct Footers {
        static let emptyFooterView = "RouteDetailEmptyFooterView"
        static let phraseLabelFooterView = "RouteDetailPhraseLabelFooterView"
    }

    /// The phrases used in InformationViewController
    struct InformationView {
        static let onboarding = "Show Onboarding"
        static let sendFeedback = "Send Feedback"
        static let moreApps = "More Apps"
        static let website = "Visit Our Website"
        static let madeBy = "Made by Cornell App Development"
        static let appDevDescription = "An Engineering Project Team\nat Cornell University"
        static let magicSchoolBus = "Ride on the Magic School Bus"
    }

    /// The phrases used in onboarding
    struct Onboarding {
        // Title label phrases
        static let welcome = "Welcome to Ithaca Transit."
        static let liveTracking = "Live Tracking."
        static let searchAnywhere = "Search Anywhere."
        static let favorites = "Your Favorites."
        static let bestFeatures = "All the best features. All in one app."

        // Detail label messages
        static let welcomeMessage = "A beautiful and simple end-to-end navigation app for TCAT. Made by AppDev."
        static let liveTrackingMessage = "Know exactly where your bus is and when it will be there."
        static let searchAnywhereMessage = "From Ithaca Mall to Taughannock Falls, search any location and get there fast."
        static let favoritesMessage = "All of your favorite destinations are just one tap away."
        static let empty = ""
    }

    struct Phrases {
        static let firstFavorite = "Add Your First Favorite!"
        static let searchPlaceholder = "Where to?"
        static let favoritesPlaceholder = "Search any destination"
        static let fromSearchBarPlaceholder = "Choose starting point..."
        static let toSearchBarPlaceholder = "Choose destination..."
        static let datepickerLeaveNow = "Leave Now"
        static let searchForDestination = "Search for a destination"

        static let seeAllStops = "See All Stops"

        // What's New phrases
        static let whatsNewUpdateName = "App Shortcuts for Favorites"
        static let whatsNewDescription = "Force Touch the app icon to search your favorites even faster."
    }

    struct Stops {
        static let currentLocation = "Current Location"
        static let destination = "your destination"
    }

    struct TableHeaders {
        static let getThereNow = "Get There Now"
        static let recentSearches = "Recent Searchers"
        static let favoriteDestinations = "Favorite Destinations"
    }

    /// The titles of controllers
    struct Titles {
        static let allStops = "All Stops"
        static let favorite = "Add Favorite"
        static let favorites = "Add Favorites"
        static let aboutUs = "About Us"
        static let routeDetails = "Route Details"
        static let routeOptions = "Route Options"
        static let routeResults = "Route Results"
    }

    struct UserDefaults {
        static let version = "version"
        static let appLaunchCount = "appLaunchCount"
        static let onboardingShown = "onboardingShown"
        static let showLocationAuthReminder = "locationAuthReminder"
        static let whatsNewDismissed = "whatsNewDismissed"

        static let recentSearch = "recentSearch"
        static let allBusStops = "allBusStops"
        static let favorites = "favorites"
    }

    struct Values {
        static let maxDistanceBetweenStops = 160.0
        static let fuzzySearchMinimumValue = 75

        /// The most extreme points of TCAT Routes
        struct RouteMaxima {

            /// Max Latitude Value
            static let north: Double = 42.61321283145329
            /// Max Longitude Value
            static let east: Double = -76.28125469914926
            /// Min Latitude Value
            static let south: Double = 42.32796328578829
            /// Min Longitude Value
            static let west: Double = -76.67690943302259
        }

        /// The borders to use for valid TCAT bus service area
        struct RouteBorders {
            // Calculated by converting latitudeMidpoint to radians and multuplying by oneLatDegree
            // https://gis.stackexchange.com/questions/142326/calculating-longitude-length-in-miles
            // let oneLatDegree = 69.172
            // let latitudeMidpoint = 42.470588059
            // let oneMileInLatitude = 1 / 69.172
            // let oneMileInLongitude = 1 / 51.2738554594
            // Conversion: 1º / x mi

            /// Max Latitude Value
            static let northBorder: Double = 42.61321283145329 + (1 / 69.172)
            /// Max Longitude Value
            static let eastBorder: Double = -76.28125469914926 + (1 / 51.2738554594)
            /// Min Latitude Value
            static let southBorder: Double = 42.32796328578829 - (1 / 69.172)
            /// Min Longitude Value
            static let westBorder: Double = -76.67690943302259 - (1 / 51.2738554594)
        }
    }
}
