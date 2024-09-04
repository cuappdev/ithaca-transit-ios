//
//  Eatery.swift
//  TCAT
//
//  Created by Jayson Hahn on 4/24/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation

struct Eatery: Codable {
    let id: Int
    let name, menuSummary: String
    let imageUrl: String
    let location, campusArea: String
    let onlineOrderURL: String?
    let latitude, longitude: Double
    let paymentAcceptsMealSwipes, paymentAcceptsBrbs, paymentAcceptsCash: Bool
    let events: [EateryEvent]

    enum CodingKeys: String, CodingKey {
        case id, name
        case menuSummary = "menu_summary"
        case imageUrl = "image_url"
        case location
        case campusArea = "campus_area"
        case onlineOrderURL = "online_order_url"
        case latitude, longitude
        case paymentAcceptsMealSwipes = "payment_accepts_meal_swipes"
        case paymentAcceptsBrbs = "payment_accepts_brbs"
        case paymentAcceptsCash = "payment_accepts_cash"
        case events
    }
}

public struct EateryEvent: Codable {
    let id: Int
    let eventDescription: String
    let start, end: Int

    enum CodingKeys: String, CodingKey {
        case id
        case eventDescription = "event_description"
        case start, end
    }
}

extension EateryEvent {

    var startDate: Date {
        Date(timeIntervalSince1970: TimeInterval(start))
    }

    var endDate: Date {
        Date(timeIntervalSince1970: TimeInterval(end))
    }

}
