//
//  Personality.swift
//  Brella, I mean, TCAT
//
//  Created by Matthew Barker on 04/15/18
//  Copyright © 2018 cuappdev. All rights reserved.
//

import Foundation

struct Messages {
    
    struct Walking {
        
        static let phrases = [
            "There's nothing wrong with a little exercise!",
        ]
        
    }
    
    /// Phrases relating to a specific location
    struct Locations {
        
        static let rpcc: [String] = [
            "In the kitchen, wrist twistin' like it's Mongo 🎵",
            "The best place for 1 AM calzones 😋",
        ]
        
        static let mall: [String] = [
            "Let's go to the mall... today! 🎵",
            "You should play some lazer tag!",
            "Catch a movie! 🎥"
        ]
        
        static let target: [String] = [
            "Do they even sell targets?",
            "Can you get tar at target?",
        ]
        
        static let wegmans: [String] = [
            "Make sure you grab a liter of Dr. W!",
            "Weg it up."
        ]
        
        static let walmart: [String] = [
            "But they don't sell any walls...",
            "A small mom & pop shop owned by Wally and Marty",
            "The only store big enough to have its own weather system"
        ]
        
        static let chipotle: [String] = [
            "Honestly, the new queso is a bit underwhelming...",
            "Get there early before they run out of guac!",
            "Try getting a quesarito, a secret menu item!"
        ]
        
    }
    
}


class LocationPhrases {
    
    static let places: [CustomLocation] = [
        
        CustomLocation(messages: Messages.Locations.rpcc, latitude: 0, longitude: 0, range: 0),
        CustomLocation(messages: Messages.Locations.mall, latitude: 0, longitude: 0, range: 0),
        CustomLocation(messages: Messages.Locations.target, latitude: 0, longitude: 0, range: 0),
        CustomLocation(messages: Messages.Locations.wegmans, latitude: 0, longitude: 0, range: 0),
        CustomLocation(messages: Messages.Locations.chipotle, latitude: 0, longitude: 0, range: 0),
        
    ]
    
    /// Return a string from the first location within the range of coordinates. Otherwise, return nil.
    static func generateMessage(latitude: Double, longitude: Double) -> String? {
        for place in places {
            if place.isWithinRange(latitude: latitude, longitude: longitude) {
                return selectMessage(from: place.messages)
            }
        }
        return nil
    }

}


class WalkingPhrases {
    
    static let messages: [String] = [
        
        "A little exercise never hurt anyone!",
        "I hope it's a nice day!",
        "Get yourself some Itha-calves",
        
    ]
    
    /// If route is solely a walking direction, return message. Otherwise, return nil.
    static func generateMessage(route: Route) -> String? {
        return route.isRawWalkingRoute() ? selectMessage(from: messages) : nil
    }

}

// MARK: Utility Classes & Functions

/// A custom location the a user searches for. Coordinates used for matching.
struct CustomLocation: Equatable {
    
    /// Messages related to location
    var messages: [String]
    /// Latitude of location
    var latitude: Double
    /// Longitude of location
    var longitude: Double
    /// The amount of acceptable difference between coordinate values
    var range: Double
    
    init(messages: [String], latitude: Double, longitude: Double, range: Double) {
        self.messages = messages
        self.latitude = latitude
        self.longitude = longitude
        self.range = range
    }
    
    /// Returns true is passed in coordinates are within the range of the location
    func isWithinRange(latitude: Double, longitude: Double) -> Bool {
        return range <= abs(self.latitude - latitude) && range <= abs(self.longitude - longitude)
    }
    
}

/// Select random string from array
func selectMessage(from messages: [String]) -> String {
    let rand = Int(arc4random_uniform(UInt32(messages.count)))
    return messages[rand]
}

