//
//  EateryAlert.swift
//  
//
//  Created by William Ma on 1/28/22.
//

import Foundation

public struct EateryAlert: Codable, Hashable {

    public let description: String?

    public let endTimestamp: Int

    public let id: Int64

    public let startTimestamp: Int

    public init(
        description: String? = nil,
        endTimestamp: Int,
        id: Int64,
        startTimestamp: Int
    ) {
        self.description = description
        self.endTimestamp = endTimestamp
        self.id = id
        self.startTimestamp = startTimestamp
    }

}

public extension EateryAlert {

    var startDate: Date {
        Date(timeIntervalSince1970: TimeInterval(startTimestamp))
    }

    var endDate: Date {
        Date(timeIntervalSince1970: TimeInterval(endTimestamp))
    }

}
