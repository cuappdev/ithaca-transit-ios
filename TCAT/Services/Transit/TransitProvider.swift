//
//  Providers.swift
//  TCAT
//
//  Created by Jayson Hahn on 9/16/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation

/// Enum representing various transit providers and their associated API endpoints.
enum TransitProvider {
    case alerts
    case allDelays(TripBody)
    case allStops
    case applePlaces(ApplePlacesBody)
    case appleSearch(SearchResultsBody)
    case busLocations(GetBusLocationsBody)
    case cancelDelayNotification(DelayNotificationBody)
    case cancelDepartureNotification(DepartureNotificationBody)
    case delay(GetDelayBody)
    case delayNotification(DelayNotificationBody)
    case departueNotification(DepartureNotificationBody)
    case routes(GetRoutesBody)
}

/// Extension to conform `TransitProvider` to `ApiEndpoint` protocol.
extension TransitProvider: ApiEndpoint {

    /// Base URL string for the transit API.
    var baseURLString: String {
//        return TransitEnvironment.transitURL
        // TODO: Remove once the Notifications moves to prod
        switch self {
        case .delayNotification, .departueNotification, .cancelDelayNotification, .cancelDepartureNotification:
            return TransitEnvironment.devTransitURL

        default:
            return TransitEnvironment.transitURL
        }
    }

    /// API path for the transit endpoints.
    var apiPath: String {
        return "api"
    }

    /// API version for the transit endpoints.
    var apiVersion: String {
        switch self {
        case .delayNotification, .departueNotification, .cancelDelayNotification, .cancelDepartureNotification, .allStops:
            return "v1"

        default:
            return "v3"
        }
    }

    /// Separator path for the transit endpoints.
    var separatorPath: String? {
        switch self {
        default:
            return nil
        }
    }

    /// Specific path for each transit endpoint.
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

        case .cancelDelayNotification:
            return Constants.Endpoints.cancelDelayNotification
            
        case .cancelDepartureNotification:
            return Constants.Endpoints.cancelDepartureNotification

        case .delay:
            return Constants.Endpoints.delay

        case .departueNotification:
            return Constants.Endpoints.departureNotification

        case .delayNotification:
            return Constants.Endpoints.delayNotification

        case .routes:
            return Constants.Endpoints.getRoutes
        }
    }

    /// Headers for the transit API requests.
    var headers: [String: String]? {
        switch self {
        default:
            return ["Content-Type": "application/json"]
        }
    }

    /// Query parameters for the transit API requests.
    var queryParams: [URLQueryItem]? {
        switch self {
        case .delay(let getDelayBody):
            return getDelayBody.toQueryItems()

        default:
            return nil
        }
    }

    /// Parameters for the transit API requests.
    var params: [String: Any]? {
        switch self {
        default:
            return nil
        }
    }

    /// HTTP method for the transit API requests.
    var method: APIHTTPMethod {
        switch self {
        case .alerts, .allStops:
            return .GET

        default:
            return .POST
        }
    }

    /// Custom data body for the transit API requests.
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

        case .delayNotification(let delayNotificationBody), .cancelDelayNotification(let delayNotificationBody):
            return try? JSONEncoder().encode(delayNotificationBody)

        case .departueNotification(
            let departureNotificationBody
        ), .cancelDepartureNotification(
            let departureNotificationBody
        ):
            return try? JSONEncoder().encode(departureNotificationBody)

        case .routes(let getRoutesBody):
            return try? JSONEncoder().encode(getRoutesBody)

        default:
            return nil
        }
    }

}
