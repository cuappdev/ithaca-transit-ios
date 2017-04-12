//
//  Network.swift
//  TCAT
//
//  Created by Austin Astorga on 4/6/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import Foundation
import SwiftyJSON
import TRON
import CoreLocation

class Error: JSONDecodable {
    required init(json: JSON) {
        //need to talk to shiv about what errors could be possibily returned
    }
}

class AllBusStops: JSONDecodable {
    var allStops : [BusStop] = [BusStop]()
    
    required init(json: JSON) throws {
        allStops = parseAllStops(json: json.array!)
    }
    
    func parseAllStops(json: [JSON]) -> [BusStop] {
        var allStopsArray = [BusStop]()
        for stop in json {
            let name = stop["name"].stringValue
            let lat = stop["latitude"].doubleValue
            let long = stop["longitude"].doubleValue
            let busStop = BusStop(name: name, lat: lat, long: long)
            allStopsArray.append(busStop)
        }
        return allStopsArray
    }
}


    /* Example Usage */

  /*let x = Network.getRoutes()
    x.perform(withSuccess: { route in
    print(route.mainStops)
    print(route.mainStopsNums)
    })
 
    Network.getAllStops().perform(withSuccess: { stops in
    print(stops.allStops.map({print($0.name!)}))
    })
    */

class Network {
    static let tron = TRON(baseURL: "http://rawgit.com/cuappdev/tcat-backend/7b76081/")
    
    class func getRoutes() -> APIRequest<Route, Error> {
        let request: APIRequest<Route, Error> = tron.request("navigate.json")
        request.method = .get
        print(request.errorParser)
        return request
    }
    
    class func getAllStops() -> APIRequest<AllBusStops, Error> {
        let request: APIRequest<AllBusStops, Error> = tron.request("stops.json")
        request.method = .get
        return request
    }
}
