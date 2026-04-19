//
//  Hotspot.swift
//  TCAT
//
//  Created by Gabriel Castillo on 4/19/26.
//  Copyright © 2026 cuappdev. All rights reserved.
//

import Foundation

// NOTE: This model is not finalized — field names and types need to be revised
// once the backend API is defined.
struct Hotspot: Codable, Equatable {

    let id: String
    let title: String
    let location: String
    let tags: String
    let startTime: Date
    let endTime: Date
    let isActive: Bool
    let organizerMessage: String
    let shortOrganizerMessage: String?
    let moreInfo: String

    private enum CodingKeys: String, CodingKey {
        case id, title, location, tags, isActive
        case startTime = "start_time"
        case endTime = "end_time"
        case organizerMessage = "organizer_message"
        case shortOrganizerMessage = "short_organizer_message"
        case moreInfo = "more_info"
    }

}
