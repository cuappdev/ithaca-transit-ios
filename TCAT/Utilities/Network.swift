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
            let location = stop["location"].arrayObject as! [Double]
            let lat = location[0]
            let long = location[1]
            let busStop = BusStop(name: name, lat: lat, long: long)
            allStopsArray.append(busStop)
        }
        let sortedStops = allStopsArray.sorted(by: {$0.name!.uppercased() < $1.name!.uppercased()})
        return sortedStops
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
    static let tron = TRON(baseURL: "http://rawgit.com/cuappdev/tcat-ios/4e095ce/")
//    static let tron = TRON(baseURL: "http://10.132.8.213:5000/")
    
    class func getRoutes() -> APIRequest<Route, Error> {
        let request: APIRequest<Route, Error> = tron.request("navigate.json")
        request.method = .get
        print(request.errorParser)
        return request
    }
    
    class func getAllStops() -> APIRequest<AllBusStops, Error> {
        let request: APIRequest<AllBusStops, Error> = tron.request("stops2.json")
        request.method = .get
        return request
    }
    
    
    class func getPlaceRoute(startLat: Double, startLng: Double, destPlaceID: String) -> APIRequest<Array<Route>, Error> {
        let request: APIRequest<Array<Route>, Error> = tron.request("routeTestingJSON.json")
        request.method = .get
        return request
    }
    
    class func getBusRoute(startLat: Double, startLng: Double, destLat: Double, destLng: Double) -> APIRequest<Array<Route>, Error> {
        let request: APIRequest<Array<Route>, Error> = tron.request("routeTestingJSON.json")
        //request.parameters = ["source": "\(startLat),\(startLng)", "sink": "\(destLat),\(destLng)" ]
        request.method = .get
        return request
    }    
}

extension Array : JSONDecodable {
    public init(json: JSON) {
        self.init(json.arrayValue.flatMap {
            if let type = Element.self as? JSONDecodable.Type {
                let element : Element?
                do {
                    element = try type.init(json: $0) as? Element
                } catch {
                    return nil
                }
                return element
            }
            return nil
        })
    }
}
