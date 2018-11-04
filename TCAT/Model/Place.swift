//
//  Place.swift
//  TCAT
//
//  Created by Monica Ong on 8/31/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class Place: NSObject, NSCoding, Codable {

    var name: String
    
    private let nameKey = "name"
    
    init(name: String) {
        self.name = name
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Place else {
            return false
        }
        
        return object.name == name
    }
    
    // MARK: NSCoding
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: nameKey) as! String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: nameKey)
    }
    
}
