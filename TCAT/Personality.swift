//
//  Personality.swift
//  Brella, I mean, TCAT
//
//  Created by Matthew Barker on 04/15/18
//  Copyright © 2018 cuappdev. All rights reserved.
//

import Foundation

/// A custom location the a user searches for. Coordinates used for matching.
struct CustomLocation: Equatable {
    
    // MARK: Initializer
    
    var latitude: Double
    var longitude: Double
    
    /// The amount of acceptable difference between coordinate values
    var range: Double
    
    init(latitude: Double, longitude: Double, range: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.range = range
    }
    
    // MARK: Custom Locations
    
    static let rpcc = CustomLocation(latitude: 0, longitude: 0, range: 0)
    
    static let target = CustomLocation(latitude: 0, longitude: 0, range: 0)
    
    static let mall = CustomLocation(latitude: 0, longitude: 0, range: 0)
    
    // MARK: Variables
    
    /// Sorted in priority order; if locations overlap, the first location will be returned
    static let array: [CustomLocation] = [
    
        // Mall-related
        target,
        mall,
        
        // School-related
        rpcc,
        
    ]
    
}

/// The type of context with which to use Personality
enum PersonalityType {
    
    // MARK: Cases
    
    
    /// When route results show a walking only direction
    case walkingDirection
    
    /// When a user's destination matches a custom location
    case customLocation(_: CustomLocation)
    
    
    // MARK: Variables
    
    
    /// Custom phrases related to a specific context (PersonalityType)
    var array: [String] {
        
        switch self {
            
            
        case .walkingDirection:
            
            return [
                "There's nothing wrong with a little exercise!",
            ]
            
            
        case .customLocation(let location):
            
            switch location {
                
            case CustomLocation.rpcc:
                return [
                    "In the kitchen, wrist twistin' like it's Mongo 🎵",
                    "The best place for 1 AM calzones 😋",
                ]
                
            case CustomLocation.mall:
                return [
                    "Let's go to the mall... today! 🎵",
                    "You should play some lazer tag!",
                    "Catch a movie! 🎥"
                ]
                
            default:
                return []
                
            } // end customLocation switch statement
            
            
        } // end main switch statement
        
    } // end `array` variable declaration
    
}

/// An object that manages custom phrases to use in various app contexts
struct Personality {
    
    var type: PersonalityType!
    
    init(type: PersonalityType) {
        self.type = type
    }
    
    // Return the set customLocation PersonalityType if the coordinates match a customLocation
    static func customLocation(latitude: Double, longitude: Double) -> PersonalityType? {
        
        for location in CustomLocation.array {
            
            if location.range <= abs(location.latitude - latitude) &&
                location.range <= abs(location.longitude - longitude) {
                return .customLocation(location)
            }
            
        }
        
        return nil
        
    }
    
    /// Return a random value in the Personality object's initialized array
    func generateValue() -> String {
        let array = self.type.array
        let rand = Int(arc4random_uniform(UInt32(array.count)))
        return array[rand]
    }
    
}
