//
//  PlaceResult2.swift
//  TCAT
//
//  Created by Austin Astorga on 3/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON
import CoreLocation

class PlaceResult: Place, JSONDecodable, CoordinateAcceptor {

    var detail: String
    var placeID: String

    private let detailKey = "detail"
    private let placeIDKey = "placeID"

    init(name: String, detail: String, placeID: String) {
        self.detail = detail
        self.placeID = placeID

        super.init(name: name)
        print(description)
    }

    required convenience init(json: JSON) throws {
        let name = json["structured_formatting"]["main_text"].stringValue
        let detail = json["structured_formatting"]["secondary_text"].stringValue
        let placeID = json["place_id"].stringValue
        
        self.init(name: name, detail: detail, placeID: placeID)
        print(description)
    }

    override func isEqual(_ object: Any?) -> Bool {
        if !super.isEqual(object) {
            return false
        }

        guard let object = object as? PlaceResult else {
            return false
        }

        return object.placeID == placeID
    }

    // MARK: Print

    override var description: String {
        return "PlaceResult(name: \(name), detail: \(detail), placeId: \(placeID))"
    }

    // MARK: NSCoding

    required init(coder aDecoder: NSCoder) {
        detail = (aDecoder.decodeObject(forKey: detailKey) as? String) ?? ""
        placeID = (aDecoder.decodeObject(forKey: placeIDKey) as? String) ?? ""
        super.init(coder: aDecoder)
    }

    public override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.detail, forKey: detailKey)
        aCoder.encode(self.placeID, forKey: placeIDKey)

        super.encode(with: aCoder)
    }

    // MARK: Visitor pattern

    func accept(visitor: CoordinateVisitor,
                callback: @escaping (_ coord: CLLocationCoordinate2D?, _ error: CoordinateVisitorError?) -> Void) {
        visitor.getCoordinate(from: self, callback: callback)
    }
}
