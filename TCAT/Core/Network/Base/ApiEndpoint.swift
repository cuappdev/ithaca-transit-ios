//
//  ApiEndpoint.swift
//  TCAT
//
//  Created by Jayson Hahn on 9/16/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation

/**
 An enumeration representing the HTTP methods that can be used in API requests.

 - GET: Represents the HTTP GET method.
 - POST: Represents the HTTP POST method.
 - PUT: Represents the HTTP PUT method.
 - DELETE: Represents the HTTP DELETE method.
 - PATCH: Represents the HTTP PATCH method.
 */
enum APIHTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}

/**
 A protocol defining the requirements for an API endpoint.

 Properties:
 - `baseURLString`: The base URL string for the API.
 - `apiPath`: The path for the API.
 - `apiVersion`: The version of the API.
 - `separatorPath`: An optional separator path for the API.
 - `path`: The specific path for the endpoint.
 - `headers`: An optional dictionary of headers to include in the request.
 - `queryParams`: An optional array of URL query items to include in the request.
 - `params`: An optional dictionary of parameters to include in the request body.
 - `method`: The HTTP method to use for the request.
 - `customDataBody`: An optional custom data body to include in the request.

 Methods:
 - `makeRequest`: A computed property that constructs and returns a `URLRequest` based on the endpoint's properties.
 */
protocol ApiEndpoint {
    var baseURLString: String { get }
    var apiPath: String { get }
    var apiVersion: String { get }
    var separatorPath: String? { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var queryParams: [URLQueryItem]? { get }
    var params: [String: Any]? { get }
    var method: APIHTTPMethod { get }
    var customDataBody: Data? { get }
}

/**
 An extension of the `ApiEndpoint` protocol that provides a default implementation for creating a `URLRequest`.

 The `makeRequest` computed property constructs a `URLRequest` using the endpoint's properties, including the base URL, path, query parameters, headers, and body parameters.
 */
extension ApiEndpoint {
    var makeRequest: URLRequest {
        var urlComponents = URLComponents(string: baseURLString)
        var longPath = "/"
        longPath.append(apiPath)
        longPath.append("/")
        longPath.append(apiVersion)
        if let separatorPath = separatorPath {
            longPath.append("/")
            longPath.append(separatorPath)
        }

        longPath.append(path)
        urlComponents?.path = longPath

        if let queryParams = queryParams {
            urlComponents?.queryItems = [URLQueryItem]()
            for queryParam in queryParams {
                urlComponents?.queryItems?.append(URLQueryItem(name: queryParam.name, value: queryParam.value))
            }
        }

        guard let url = urlComponents?.url else { return URLRequest(url: URL(string: baseURLString)!) }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let headers = headers {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        if let params = params {
            let jsonData = try? JSONSerialization.data(withJSONObject: params)
            request.httpBody = jsonData
        }

        if let customDataBody = customDataBody {
            request.httpBody = customDataBody
        }

        return request
    }
}
