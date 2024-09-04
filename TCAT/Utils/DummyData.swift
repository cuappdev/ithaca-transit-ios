//
//  DummyData.swift
//  TCAT
//
//  Created by Jayson Hahn on 5/1/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation

enum DummyData {

    static let Betha = Eatery(
        id: 18,
        name: "Jansen's Dining Room at Bethe House",
        menuSummary: "A west dining classic",
        imageUrl: "https://raw.githubusercontent.com/cuappdev/assets/master/eatery/eatery-images/Jansens-Dining.jpg",
        location: "Hans Bethe House",
        campusArea: "West",
        onlineOrderURL: nil,
        latitude: 42.447116,
        longitude: -76.48864,
        paymentAcceptsMealSwipes: true,
        paymentAcceptsBrbs: true,
        paymentAcceptsCash: true,
        events: [
            EateryEvent(id: 1103519, eventDescription: "Breakfast", start: 1714474800, end: 1714487400),
            EateryEvent(id: 1103520, eventDescription: "Lunch", start: 1714487400, end: 1714500000),
            EateryEvent(id: 1103521, eventDescription: "Dinner", start: 1714509000, end: 1714519800),
            EateryEvent(id: 1103522, eventDescription: "Breakfast", start: 1714561200, end: 1714573800),
            EateryEvent(id: 1103523, eventDescription: "Lunch", start: 1714573800, end: 1714586400),
            EateryEvent(id: 1103524, eventDescription: "Dinner", start: 1714600800, end: 1714606200),
            EateryEvent(id: 1103525, eventDescription: "Breakfast", start: 1714647600, end: 1714660200),
            EateryEvent(id: 1103526, eventDescription: "Lunch", start: 1714660200, end: 1714672800),
            EateryEvent(id: 1103527, eventDescription: "Dinner", start: 1714681800, end: 1714692600),
            EateryEvent(id: 1103528, eventDescription: "Breakfast", start: 1714734000, end: 1714746600),
            EateryEvent(id: 1103529, eventDescription: "Lunch", start: 1714746600, end: 1714759200),
            EateryEvent(id: 1103530, eventDescription: "Dinner", start: 1714768200, end: 1714779000),
            EateryEvent(id: 1103531, eventDescription: "Lunch", start: 1714833000, end: 1714845600),
            EateryEvent(id: 1103532, eventDescription: "Dinner", start: 1714854600, end: 1714865400),
            EateryEvent(id: 1103533, eventDescription: "Brunch", start: 1714917600, end: 1714932000),
            EateryEvent(id: 1103534, eventDescription: "Dinner", start: 1714941000, end: 1714951800),
            EateryEvent(id: 1103535, eventDescription: "Breakfast", start: 1714993200, end: 1715005800),
            EateryEvent(id: 1103536, eventDescription: "Lunch", start: 1715005800, end: 1715018400),
            EateryEvent(id: 1103537, eventDescription: "Dinner", start: 1715027400, end: 1715038200),
            EateryEvent(id: 1103538, eventDescription: "Breakfast", start: 1715079600, end: 1715092200),
            EateryEvent(id: 1103539, eventDescription: "Lunch", start: 1715092200, end: 1715104800),
            EateryEvent(id: 1103540, eventDescription: "Dinner", start: 1715113800, end: 1715124600)
        ]
    )

    static let Okenshields = Eatery(
        id: 26,
        name: "Okenshields",
        menuSummary: "The only central campus dining hall",
        imageUrl: "https://raw.githubusercontent.com/cuappdev/assets/master/eatery/eatery-images/Okenshields.jpg",
        location: "Willard Straight Hall",
        campusArea: "Central",
        onlineOrderURL: nil,
        latitude: 42.446491,
        longitude: -76.485678,
        paymentAcceptsMealSwipes: true,
        paymentAcceptsBrbs: true,
        paymentAcceptsCash: true,
        events: [
            EateryEvent(id: 1103650, eventDescription: "Lunch", start: 1714489200, end: 1714501800),
            EateryEvent(id: 1103651, eventDescription: "Dinner", start: 1714509000, end: 1714525200),
            EateryEvent(id: 1103652, eventDescription: "Lunch", start: 1714575600, end: 1714588200),
            EateryEvent(id: 1103653, eventDescription: "Dinner", start: 1714595400, end: 1714611600),
            EateryEvent(id: 1103654, eventDescription: "Lunch", start: 1714662000, end: 1714674600),
            EateryEvent(id: 1103655, eventDescription: "Dinner", start: 1714681800, end: 1714698000),
            EateryEvent(id: 1103656, eventDescription: "Lunch", start: 1714748400, end: 1714761000),
            EateryEvent(id: 1103657, eventDescription: "Dinner", start: 1714768200, end: 1714784400),
            EateryEvent(id: 1103658, eventDescription: "Lunch", start: 1715007600, end: 1715020200),
            EateryEvent(id: 1103659, eventDescription: "Dinner", start: 1715027400, end: 1715043600),
            EateryEvent(id: 1103660, eventDescription: "Lunch", start: 1715094000, end: 1715106600),
            EateryEvent(id: 1103661, eventDescription: "Dinner", start: 1715113800, end: 1715130000)
        ]
    )


}

extension Eatery {

    static func EcoOfEatery(eatery: Eatery) -> EcoLocation {
        return EcoLocation(facility: .eatery(eatery), status: getEateryStatus(eatery: eatery))
    }

    static func getEateryStatus(eatery: Eatery) -> EateryStatus{
        return EateryStatus(eatery.events)
    }
}
