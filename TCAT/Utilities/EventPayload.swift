//
//  EventPayload.swift
//  TCAT
//
//  Created by Austin Astorga on 9/24/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import Foundation

public protocol Payload: Codable {
    static var eventName: String {get}
}

public extension Payload {
    func toEvent() -> Event<Self> {
        return Event(payload: self)
    }
}

/// Use JSONData for serialized JSON
public typealias JSONData = Data

public class Event<TPayload: Payload>: Codable {

    public let payload: TPayload
    public var eventName: String {return TPayload.eventName}

    init(payload: TPayload) {
        self.payload = payload
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.payload = try values.decode(TPayload.self, forKey: .payload)
        let decodedEventName = try values.decode(String.self, forKey: .eventName)
        if decodedEventName != eventName {
            throw NSError.init(domain: "bar", code: 0)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.payload, forKey: .payload)
        try values.encode(self.eventName, forKey: .eventName)
    }

    enum CodingKeys: String, CodingKey {
        case timestamp, payload, eventName = "event_type"
    }

    public func serializeJson() throws -> JSONData {
        return try JSONEncoder().encode(self)
    }

}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()

public class TimestampedEvent<TPayload: Payload>: Event<TPayload> {

    public let timestamp: Date

    init(event: Event<TPayload>) {
        self.timestamp = Date()
        super.init(payload: event.payload)
    }

    init(event: Event<TPayload>, timestamp: Date) {
        self.timestamp = timestamp
        super.init(payload: event.payload)
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let timestampString = try values.decode(String.self, forKey: .timestamp)
        guard let decodedTimestamp = dateFormatter.date(from: timestampString) else {
            throw NSError.init(domain: "bar", code: 0)
        }
        timestamp = decodedTimestamp
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(dateFormatter.string(from: timestamp), forKey: .timestamp)
    }

}
