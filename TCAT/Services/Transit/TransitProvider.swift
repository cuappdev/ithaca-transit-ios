//
//  Providers.swift
//  TCAT
//
//  Created by Jayson Hahn on 9/16/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation

enum TransitProvider {
    case alerts
    case allDelays(TripBody)
    case allStops
    case applePlaces(ApplePlacesBody)
    case appleSearch(SearchResultsBody)
    case busLocations(GetBusLocationsBody)
    case delay(GetDelayBody)
    case routes(GetRoutesBody)
}

extension TransitProvider: ApiEndpoint {

    var baseURLString: String {
        return TransitEnvironment.transitURL
    }

    var apiPath: String {
        return "api"
    }

    var apiVersion: String {
        switch self {
        case .routes:
            return "v2"
        default:
            return "v3"
        }
    }

    var separatorPath: String? {
        switch self {
        default:
            return ""
        }
    }

    var path: String {
        switch self {
        case .alerts:
            return Constants.Endpoints.alerts
        case .allDelays:
            return Constants.Endpoints.delays
        case .allStops:
            return Constants.Endpoints.allStops
        case .applePlaces:
            return Constants.Endpoints.applePlaces
        case .appleSearch:
            return Constants.Endpoints.appleSearch
        case .busLocations:
            return Constants.Endpoints.busLocations
        case .delay:
            return Constants.Endpoints.delay
        case .routes:
            return Constants.Endpoints.getRoutes
        }
    }

    var headers: [String: String]? {
        switch self {
        default:
            return ["Content-Type": "application/json"]
        }
    }

    var queryParams: [URLQueryItem]? {
        switch self {
        case .delay(let getDelayBody):
            return getDelayBody.toQueryItems()
        default:
            return nil
        }
    }

    var params: [String: Any]? {
        switch self {
        default:
            return nil
        }
    }

    var method: APIHTTPMethod {
        switch self {
        case .alerts, .allStops:
            return .GET
        default:
            return .POST
        }
    }

    var customDataBody: Data? {
        switch self {
        case .allDelays(let tripBody):
            return try? JSONEncoder().encode(tripBody)
        case .applePlaces(let applePlacesBody):
            return try? JSONEncoder().encode(applePlacesBody)
        case .appleSearch(let searchResultsBody):
            return try? JSONEncoder().encode(searchResultsBody)
        case .busLocations(let getBusLocationsBody):
            return try? JSONEncoder().encode(getBusLocationsBody)
        case .delay(let getDelayBody):
            return try? JSONEncoder().encode(getDelayBody)
        case .routes(let getRoutesBody):
            return try? JSONEncoder().encode(getRoutesBody)
        default:
            return nil
        }
    }

}
