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
        // need to talk to shiv about what errors could be possibily returned
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
        let sortedStops = allStopsArray.sorted(by: {$0.name.uppercased() < $1.name.uppercased()})
        return sortedStops
    }
}

class AllBusLocations: JSONDecodable {

    var allBusLocations : [BusLocation] = [BusLocation]()

    required init(json: JSON) throws {
        
        if json["success"].boolValue {
            let data = json["data"].arrayValue
            allBusLocations = parseAllLocations(json: data)
        }
    }

    func parseAllLocations(json: [JSON]) -> [BusLocation] {

        var allLocationsArray = [BusLocation]()

        for bus in json {

            let routeID = bus["routeID"].stringValue
            let busLocation = BusLocation(routeID: routeID)

            busLocation.destination = bus["destination"].stringValue
            busLocation.deviation = bus["deviation"].intValue
            busLocation.direction = bus["direction"].stringValue
            busLocation.displayStatus = bus["displayStatus"].stringValue
            busLocation.gpsStatus = bus["gpsStatus"].intValue
            busLocation.heading = bus["heading"].intValue
            busLocation.lastStop = bus["lastStop"].stringValue
            busLocation.lastUpdated = Date(timeIntervalSince1970: bus["lastUpdated"].doubleValue)
            busLocation.latitude = bus["latitude"].doubleValue
            busLocation.longitude = bus["longitude"].doubleValue
            busLocation.name = bus["name"].intValue
            busLocation.opStatus = bus["opStatus"].stringValue
            busLocation.runID = bus["runID"].intValue
            busLocation.speed = bus["speed"].intValue
            busLocation.tripID = bus["tripID"].intValue
            busLocation.vehicleID = bus["vehicleID"].intValue

            allLocationsArray.append(busLocation)

        }

        return allLocationsArray

    }

}

class Network {

    static let source = "34.235.128.17"
    static let tron = TRON(baseURL: "http://\(source)/api/v1/")
    static let googleTron = TRON(baseURL: "https://maps.googleapis.com/maps/api/place/autocomplete/")
    static let placesClient = GMSPlacesClient.shared()

    class func getAllStops() -> APIRequest<AllBusStops, Error> {
        let request: APIRequest<AllBusStops, Error> = tron.request("stops")
        request.method = .get
        return request
    }

    class func getStartEndCoords(start: CoordinateAcceptor, end: CoordinateAcceptor, callback:@escaping ((CLLocationCoordinate2D?, CLLocationCoordinate2D?) -> Void)) {
        let visitor = CoordinateVisitor()
        start.accept(visitor: visitor) { startCoord in
            end.accept(visitor: visitor) { endCoord in
        
                callback(startCoord, endCoord)
            }
        }
    }

    class func getRoutes(start: CoordinateAcceptor, end: CoordinateAcceptor, time: Date, type: SearchType, callback:@escaping ((APIRequest<JSON, Error>) -> Void)) {
        getStartEndCoords(start: start, end: end) { startCoords, endCoords in
            
            let request: APIRequest<JSON, Error> = tron.request("routes")
            
            request.parameters = [
                "start_coords"  :   "\(startCoords?.latitude ??? ""),\(startCoords?.longitude ??? "")",
                "end_coords"    :   "\(endCoords?.latitude ??? ""),\(endCoords?.longitude ??? "")",
            ]

            if type == .arriveBy {
                request.parameters["depart_time"] = time.timeIntervalSince1970
            } else {
                request.parameters["leave_by"] = time.timeIntervalSince1970
            }
            
            request.method = .get
            
            callback(request)
        }
    }


    class func getGooglePlaces(searchText: String) -> APIRequest<JSON, Error> {
        let googleJson = try! JSON(data: Data(contentsOf: Bundle.main.url(forResource: "config", withExtension: "json")!))
        let urlReadySearch = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let request: APIRequest<JSON, Error> = googleTron.request("json")
        request.parameters = ["strictbounds": "", "location": "42.4440,-76.5019", "radius": 24140, "input": urlReadySearch, "key": googleJson["google-places"].stringValue]
        request.method = .get
        return request
    }

    class func getBusLocations(routeID: String) -> APIRequest<AllBusLocations, Error> {
        let request: APIRequest<AllBusLocations, Error> = tron.request("tracking")
        request.parameters = ["routeID" : routeID]
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
