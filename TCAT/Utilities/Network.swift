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
import GooglePlaces

class Error: JSONDecodable {
    required init(json: JSON) {
        //need to talk to shiv about what errors could be possibily returned
    }
}
class AllBusStops: JSONDecodable {
    var allStops : [BusStop] = [BusStop]()
    
    required init(json: JSON) throws {
        if json["success"].boolValue {
            let data = json["data"].arrayValue
            allStops = parseAllStops(json: data)
        }
    }
    
    func parseAllStops(json: [JSON]) -> [BusStop] {
        var allStopsArray = [BusStop]()
        for stop in json {
            let name = stop["name"].stringValue
            let location = stop["location"]
            let lat = location["latitude"].doubleValue
            let long = location["longitude"].doubleValue
            let busStop = BusStop(name: name, lat: lat, long: long)
            allStopsArray.append(busStop)
        }
        let sortedStops = allStopsArray.sorted(by: {$0.name!.uppercased() < $1.name!.uppercased()})
        return sortedStops
    }
}

class Network {

    /// Make sure you are running localhost:3000 on your computer!
    static let tron = TRON(baseURL: "http://localhost:3000/api/v1/")
    static let googleTron = TRON(baseURL: "https://maps.googleapis.com/maps/api/place/autocomplete/")
    static let placesClient = GMSPlacesClient.shared()
    
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
    
    class func getRoutes(start: BusStop, end: BusStop, time: Date, type: SearchType) -> APIRequest<Array<Route>, Error> {
        
        let request: APIRequest<Array<Route>, Error> = tron.request("routes")
        
        request.parameters = [
            
            "start_coords"  :   "\(start.lat ??? ""),\(start.long ??? "")",
            "end_coords"    :   "\(end.lat ??? ""),\(end.long ??? "")",
        
        ]

        if type == .arriveBy {
            request.parameters["depart_time"] = time.timeIntervalSince1970
        } else {
            request.parameters["leave_by"] = time.timeIntervalSince1970
        }
        
        print(request.parameters)
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

    class func getLocationFromPlaceId(placeId: String, callback:@escaping ((CLLocationCoordinate2D) -> Void)) {
        placesClient.lookUpPlaceID(placeId) { place, error in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            guard let place = place else {
                print("No place details for \(placeId)")
                return
            }
            callback(place.coordinate)
        }
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
