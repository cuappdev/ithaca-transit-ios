//
//  Personality.swift
//
//  Created by Matthew Barker on 04/15/18
//  Copyright © 2018 cuappdev. All rights reserved.
//

import Foundation

struct Messages {

    static let walkingPhrases: [String] = [
        "A little exercise never hurt anyone!",
        "I hope it's a nice day!",
        "Get yourself some Itha-calves"
    ]

    static let shoppingPhrases: [String] = [
        "Stock up on some Ramen noodles!",
        "Paper or plastic?",
        "Pro Tip: Never grocery shop on an empty stomach"
    ]

    // MARK: - Cornell

    static let rpcc: [String] = [
        "In the kitchen, wrist twistin' like it's Mongo 🎵",
        "The best place for 1 AM calzones 😋",
        "Hear someone passionately scream out your name 😉"
    ]

    static let bakerFlagpole: [String] = [
        "You should try the food on East Campus some time!",
        "Grab a snack at Jansen's 🍪",
        "Admire how slope-y the slope is."
    ]

    static let statler: [String] = [
        "You can check out any time you like, but you can never leave 🎵",
        "The Terrace has the best burritos on campus 🌯",
        "You think dorms are expensive, try staying a night here!"
    ]

    static let rockefeller: [String] = [
        "Voted #3 Best Bus Stop Shelter in Tompkins County",
        "Why is it called East Ave.? It doesn't even go east!",
        "I bet there's a Rockefeller building on every old campus"
    ]

    static let balch: [String] = [
        "Home of the Balch Arch, aka the Barch!",
        "Treat yourself with a Louie's milkshake 😋",
        "Dorm sweet dorm!"
    ]

    static let schwartz: [String] = [
        "Try something new at CTB!",
        "I wonder if eHub is crowded... probably",
        "Welcome to the hustle and bustle of Collegetown"
    ]

    // MARK: - Ithaca

    static let regalCinema: [String] = [
        "The trailers always take a half hour anyway...",
        "Grab some popcorn! 🍿",
        "Don't track your bus while the movie is playing 🙂"
    ]

    static let target: [String] =  [
        "Do they even sell targets?",
        "Can you get tar at target?"
    ] + Messages.shoppingPhrases

    static let mall: [String] = [
        "Let's go to the mall... today! 🎵",
        "You should play some lazer tag!"
    ]

    static let wegmans: [String] = [
        "Make sure you grab a liter of Dr. W!",
        "Weg it up."
    ] + Messages.shoppingPhrases

    static let walmart: [String] = [
        "But they don't sell any walls...",
        "A small mom & pop shop owned by Wally and Marty"
    ] + Messages.shoppingPhrases

    static let chipotle: [String] = [
        "Honestly, the new queso is a bit underwhelming...",
        "Get there early before they run out of guac!",
        "Try getting a quesarito, a secret menu item!"
    ]

}

class Phrases {

    /// Select random string from array
    static func selectMessage(from messages: [String]) -> String {
        return messages.randomElement() ?? ""
    }

}

class LocationPhrases: Phrases {

    /// For new places, use: https://boundingbox.klokantech.com set to CSV.

    /// For overlapping places, put the smaller one first
    static let places: [CustomLocation] = [
        CustomLocation(
            messages: Messages.rpcc,
            minimumLongitude: -76.4780073578,
            minimumLatitude: 42.4555571687,
            maximumLongitude: -76.4770239162,
            maximumLatitude: 42.4562933289
        ),
        CustomLocation(
            messages: Messages.bakerFlagpole,
            minimumLongitude: -76.4882680195,
            minimumLatitude: 42.447154511,
            maximumLongitude: -76.4869808879,
            maximumLatitude: 42.4482142506
        ),
        CustomLocation(
            messages: Messages.statler,
            minimumLongitude: -76.4826804461,
            minimumLatitude: 42.445607399,
            maximumLongitude: -76.4816523295,
            maximumLatitude: 42.4467569576
        ),
        CustomLocation(
            messages: Messages.rockefeller,
            minimumLongitude: -76.4828309704,
            minimumLatitude: 42.4493108267,
            maximumLongitude: -76.4824479047,
            maximumLatitude: 42.44969019
        ),
        CustomLocation(
            messages: Messages.balch,
            minimumLongitude: -76.4811291114,
            minimumLatitude: 42.4526837484,
            maximumLongitude: -76.4789034578,
            maximumLatitude: 42.4536103104
        ),
        CustomLocation(
            messages: Messages.schwartz,
            minimumLongitude: -76.4855623082,
            minimumLatitude: 42.4424106249,
            maximumLongitude: -76.4849883155,
            maximumLatitude: 42.4428654009
        ),
        CustomLocation(
            messages: Messages.target,
            minimumLongitude: -76.4927489222,
            minimumLatitude: 42.4847167857,
            maximumLongitude: -76.4889960764,
            maximumLatitude: 42.4858172457
        ),
        CustomLocation(
            messages: Messages.regalCinema,
            minimumLongitude: -76.493338437,
            minimumLatitude: 42.4838963076,
            maximumLongitude: -76.4914179754,
            maximumLatitude: 42.4846716949
        ),
        CustomLocation(
            messages: Messages.mall,
            minimumLongitude: -76.493291,
            minimumLatitude: 42.480977,
            maximumLongitude: -76.488651,
            maximumLatitude: 42.48597
        ),
        CustomLocation(
            messages: Messages.wegmans,
            minimumLongitude: -76.5114533069,
            minimumLatitude: 42.4336357432,
            maximumLongitude: -76.5093075397,
            maximumLatitude: 42.4362012905
        ),
        CustomLocation(
            messages: Messages.walmart,
            minimumLongitude: -76.5148997155,
            minimumLatitude: 42.4265752766,
            maximumLongitude: -76.511709343,
            maximumLatitude: 42.4284506244
        ),
        CustomLocation(
            messages: Messages.chipotle,
            minimumLongitude: -76.5082565033,
            minimumLatitude: 42.4297004932,
            maximumLongitude: -76.5080904931,
            maximumLatitude: 42.4302749214
        )
    ]

    /// Return a string from the first location within the range of coordinates. Otherwise, return nil.
    static func generateMessage(latitude: Double, longitude: Double) -> String? {
        for place in places where place.isWithinRange(latitude: latitude, longitude: longitude) {
            return selectMessage(from: place.messages)
        }
        return nil
    }

}

class WalkingPhrases: Phrases {

    /// If route is solely a walking direction, return message. Otherwise, return nil.
    static func generateMessage(route: Route) -> String? {
        let messages = Messages.walkingPhrases
        return route.isRawWalkingRoute() ? selectMessage(from: messages) : nil
    }

}

// MARK: - Utility Classes & Functions

/// A custom location the a user searches for. Coordinates used for matching.
struct CustomLocation: Equatable {

    /// Messages related to location
    var messages: [String]

    // MARK: - Bounding Box Variables

    /// The bottom left corner longitude value for the location's bounding box
    var maximumLongitude: Double

    /// The bottom right corner latitude value for the location's bounding box
    var minimumLatitude: Double

    /// The top right corner longitude value for the location's bounding box
    var minimumLongitude: Double

    /// The top left corner latitude value for the location's bounding box
    var maximumLatitude: Double

    init(
        messages: [String],
        minimumLongitude: Double,
        minimumLatitude: Double,
        maximumLongitude: Double,
        maximumLatitude: Double
    ) {
        self.messages = messages
        self.minimumLongitude = minimumLongitude
        self.minimumLatitude = minimumLatitude
        self.maximumLongitude = maximumLongitude
        self.maximumLatitude = maximumLatitude
    }

    /// Returns true is passed in coordinates are within the range of the location
    func isWithinRange(latitude: Double, longitude: Double) -> Bool {
        let isLatInRange = minimumLatitude <= latitude && latitude <= maximumLatitude
        let isLongInRange = minimumLongitude <= longitude && longitude <= maximumLongitude
        return isLatInRange && isLongInRange
    }

}
