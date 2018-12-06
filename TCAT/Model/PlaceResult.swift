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

class PlaceResult: Place, CoordinateAcceptor {
    
    var detail: String
    var placeID: String
    
    private let detailKey = "detail"
    private let placeIDKey = "placeID"
    
    private enum CodingKeys: CodingKey {
        case detail
        case placeID
    }
    
    init(name: String, detail: String, placeID: String) {
        self.detail = detail
        self.placeID = placeID
        
        super.init(name: name)
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.detail = try container.decode(String.self, forKey: .detail)
        self.placeID = try container.decode(String.self, forKey: .placeID)
        try super.init(from: decoder)
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
