//
//  MenuCategory.swift
//  
//
//  Created by William Ma on 1/12/22.
//

import Foundation

public struct MenuCategory: Codable, Hashable {

    public let category: String

    public let items: [MenuItem]

    public init(category: String, items: [MenuItem]) {
        self.category = category
        self.items = items
    }

}
