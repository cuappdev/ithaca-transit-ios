//
//  Place.swift
//  TCAT
//
//  Created by Monica Ong on 8/31/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class Place: NSObject, NSCoding {

    var name: String
    
    init(name: String){
        self.name = name
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Place else {
            return false
            
        }
        
        return object.name == name
    }
    
    // MARK: NSCoding
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        
        self.init(name: name)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
    }
}
