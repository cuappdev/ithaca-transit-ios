//
//  Menu.swift
//  
//
//  Created by William Ma on 1/12/22.
//

import Foundation

public struct Menu: Codable, Hashable {

    public let categories: [MenuCategory]

    public init(categories: [MenuCategory]) {
        self.categories = categories
    }

}
