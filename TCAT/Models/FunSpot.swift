//
//  FunSpot.swift
//  TCAT
//
//  Created by Gabriel Castillo on 4/19/26.
//  Copyright © 2026 cuappdev. All rights reserved.
//

import Foundation

// NOTE: This model is not finalized — field names and types need to be revised
// once the backend API is defined.
enum FunSpotCategory: String, Codable {
    case hotel, restaurant, cafe, attraction
}

// NOTE: This model is not finalized — field names and types need to be revised
// once the backend API is defined.
struct FunSpot: Codable, Equatable {

    let id: String
    let name: String
    let address: String
    let distanceMiles: Double
    let category: FunSpotCategory
    let about: String
    let quote: String?
    let imageURL: String?
    var isFavorite: Bool

    private enum CodingKeys: String, CodingKey {
        case id, name, address, category, about, quote
        case distanceMiles = "distance_miles"
        case imageURL = "image_url"
        case isFavorite = "is_favorite"
    }

}
