//
//  Eatery.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import CoreLocation
import Foundation

public struct Eatery: Codable, Hashable {

    public let alerts: [EateryAlert]

    public let campusArea: String?

    public let events: [Event]

    public let id: Int64

    public let imageUrl: URL?

    public let latitude: Double?

    public let locationDescription: String?

    public let longitude: Double?

    public let menuSummary: String?

    public let name: String

    public let onlineOrderUrl: URL?

    public let paymentMethods: Set<PaymentMethod>

    public let waitTimesByDay: [Day: WaitTimes]

    public init(
        alerts: [EateryAlert] = [],
        campusArea: String? = nil,
        events: [Event] = [],
        id: Int64,
        imageUrl: URL? = nil,
        latitude: Double? = nil,
        locationDescription: String? = nil,
        longitude: Double? = nil,
        menuSummary: String? = nil,
        name: String,
        onlineOrderUrl: URL? = nil,
        paymentMethods: Set<PaymentMethod> = [],
        waitTimesByDay: [Day: WaitTimes] = [:]
    ) {
        self.alerts = alerts
        self.campusArea = campusArea
        self.events = events
        self.id = id
        self.imageUrl = imageUrl
        self.latitude = latitude
        self.locationDescription = locationDescription
        self.longitude = longitude
        self.menuSummary = menuSummary
        self.name = name
        self.onlineOrderUrl = onlineOrderUrl
        self.paymentMethods = paymentMethods
        self.waitTimesByDay = waitTimesByDay
    }

}

public extension Eatery {

    func walkTime(userLocation: CLLocation?) -> TimeInterval? {
        guard let latitude = latitude, let longitude = longitude, let userLocation = userLocation else {
            return nil
        }

        let distance = userLocation.distance(from: CLLocation(latitude: latitude, longitude: longitude))

        // https://en.wikipedia.org/wiki/Preferred_walking_speed
        let walkingSpeed = 1.42
        return distance / walkingSpeed
    }

    func waitTime(date: Date) -> WaitTimeSample? {
        guard let waitTimes = waitTimesByDay[Day(date: date)] else {
            return nil
        }

        return waitTimes.sample(at: date)
    }

    /// Estimate the time to get food at an eatery, taking into the account the walk time when calculating the wait
    /// time.
    ///
    /// If the walk time cannot be estimated, this function returns the wait time at the departure date.
    func timingInfo(userLocation: CLLocation?, departureDate: Date) -> (walkTime: TimeInterval?, waitTime: WaitTimeSample?) {
        if let walkTime = walkTime(userLocation: userLocation) {
            return (walkTime: walkTime, waitTime: waitTime(date: departureDate + walkTime))
        } else {
            return (walkTime: nil, waitTime: waitTime(date: departureDate))
        }
    }

    /// Expected time to get food at an eatery, taking into the account the walk time when calculating the wait time.
    func expectedTotalTime(userLocation: CLLocation?, departureDate: Date) -> TimeInterval? {
        let timingInfo = timingInfo(userLocation: userLocation, departureDate: departureDate)
        if timingInfo.walkTime == nil, timingInfo.waitTime == nil {
            return nil
        }

        let walkTime = timingInfo.walkTime ?? 0
        let waitTime = timingInfo.waitTime?.expected ?? 0
        return walkTime + waitTime
    }

}

public extension Eatery {

    var status: EateryStatus {
        EateryStatus(events)
    }

    var isOpen: Bool {
        status.isOpen
    }

}
