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
    //    TRON(baseURL: "http://rawgit.com/cuappdev/tcat-ios/1194a64/")
    static let tron = TRON(baseURL: "http://tcat-dev-env-1.bsjzqmpigt.us-west-2.elasticbeanstalk.com/")
    static let googleTron = TRON(baseURL: "https://maps.googleapis.com/maps/api/place/autocomplete/")
    
    class func getRoutes() -> APIRequest<Route, Error> {
        let request: APIRequest<Route, Error> = tron.request("navigate.json")
        request.method = .get
        print(request.errorParser)
        return request
    }
    
    class func getAllStops() -> APIRequest<AllBusStops, Error> {
        let request: APIRequest<AllBusStops, Error> = tron.request("stops")
        request.method = .get
        return request
    }
    
    class func getRoutes(start: BusStop, end: PlaceResult, time: Date, type: SearchType) -> APIRequest<Array<Route>, Error> {
        let request: APIRequest<Array<Route>, Error> = tron.request("navigate")
        request.parameters = ["source": "\(start.lat ??? ""),\(start.long ??? "")",
            "sink": "\(end.placeID ??? "")"]
        if type == .arriveby {
            request.parameters["depart_time"] = Time.string(from: time)
        }else{
            request.parameters["arrive_time"] = Time.string(from: time)
        }
        request.method = .get
        return request
    }
    
    class func getRoutes(start: BusStop, end: BusStop, time: Date, type: SearchType) -> APIRequest<Array<Route>, Error>{
        let request: APIRequest<Array<Route>, Error> = tron.request("navigate")
        request.parameters = ["source": "\(start.lat ??? ""),\(start.long ??? "")",
            "sink": "\(end.lat ??? ""),\(end.long ??? "")" ]
        if type == .arriveby {
            request.parameters["depart_time"] = Time.string(from: time)
        }else{
            request.parameters["arrive_time"] = Time.string(from: time)
        }
        request.method = .get
        return request
    }
    
    class func getRoutes(start: PlaceResult, end: PlaceResult, time: Date, type: SearchType) -> APIRequest<Array<Route>, Error>{
        let request: APIRequest<Array<Route>, Error> = tron.request("navigate")
        request.parameters = ["source": "\(start.placeID ??? "")", "sink": "\(end.placeID ??? "")"]
        if type == .arriveby {
            request.parameters["depart_time"] = Time.string(from: time)
        }else{
            request.parameters["arrive_time"] = Time.string(from: time)
        }
        request.method = .get
        return request
    }
    
    class func getRoutes(start: PlaceResult, end: BusStop, time: Date, type: SearchType) -> APIRequest<Array<Route>, Error>{
        let request: APIRequest<Array<Route>, Error> = tron.request("navigate")
        request.parameters = ["source": "\(start.placeID ??? "")",
            "sink": "\(end.lat ??? ""),\(end.long ??? "")"]
        if type == .arriveby {
            request.parameters["depart_time"] = Time.string(from: time)
        }else{
            request.parameters["arrive_time"] = Time.string(from: time)
        }
        request.method = .get
        return request
    }
    
    class func getGooglePlaces(searchText: String) -> APIRequest<JSON, Error> {
        let googleJson = try! JSON(data: Data(contentsOf: Bundle.main.url(forResource: "config", withExtension: "json")!))
        let urlReadySearch = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let request: APIRequest<JSON, Error> = googleTron.request("json")
        request.parameters = ["strictbounds": "", "location": "42.4440,-76.5019", "radius": 24140, "input": urlReadySearch, "key": googleJson["google-places"].stringValue]
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
