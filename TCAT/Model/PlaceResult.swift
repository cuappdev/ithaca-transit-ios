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

class PlaceResult: Place, JSONDecodable {
    var detail: String
    var placeID: String
    
    init(name: String, detail: String, placeID: String) {
        self.detail = detail
        self.placeID = placeID
        
        super.init(name: name)
    }
    
    required convenience init(json: JSON) throws {
        let name = json["structured_formatting"]["main_text"].stringValue
        let detail = json["structured_formatting"]["secondary_text"].stringValue
        let placeID = json["place_id"].stringValue
        
        self.init(name: name, detail: detail, placeID: placeID)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if (!super.isEqual(object)){
            return false
        }
        
        guard let object = object as? PlaceResult else {
            return false
        }
        
        return object.placeID == placeID
    }
    
    // MARK: NSCoding
    
    required init(coder aDecoder: NSCoder) {
        detail = aDecoder.decodeObject(forKey: "detail") as! String
        placeID = aDecoder.decodeObject(forKey: "placeID") as! String
        
        super.init(coder: aDecoder)
    }
    
    public override func encode(with aCoder: NSCoder) {        
        aCoder.encode(self.detail, forKey: "detail")
        aCoder.encode(self.placeID, forKey: "placeID")
        
        super.encode(with: aCoder)
    }
}
