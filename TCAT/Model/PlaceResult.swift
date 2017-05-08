//
//  PlaceResult.swift
//  TCAT
//
//  Created by Austin Astorga on 3/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON

class PlaceResult: NSObject, NSCoding, JSONDecodable {
    var name: String? = ""
    var detail: String? = ""
    var placeID: String? = ""
    
    init(name: String, detail: String, placeID: String) {
        self.name = name
        self.detail = detail
        self.placeID = placeID
    }
    
    required init(json: JSON) throws {
        print("called JSON THING")
        self.name = json["structured_formatting"]["main_text"].stringValue
        self.detail = json["structured_formatting"]["secondary_text"].stringValue
        self.placeID = json["place_id"].stringValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? PlaceResult else {return false}
        return object.placeID == placeID
    }
    
    // MARK: NSCoding
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let detail = aDecoder.decodeObject(forKey: "detail") as! String
        let placeID = aDecoder.decodeObject(forKey: "placeID") as! String
        self.init(name: name, detail: detail, placeID: placeID)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.detail, forKey: "detail")
        aCoder.encode(self.placeID, forKey: "placeID")
    }
}
