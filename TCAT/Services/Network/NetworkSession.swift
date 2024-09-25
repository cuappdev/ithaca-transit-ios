//
//  NetworkSession.swift
//  TCAT
//
//  Created by Jayson Hahn on 9/16/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation
import Combine

protocol NetworkSession: AnyObject {
    func publisher<T>(_ request: URLRequest, decodingType: T.Type) -> AnyPublisher<T, APIErrorHandler> where T: Decodable
}

extension URLSession: NetworkSession {
    func publisher<T>(_ request: URLRequest, decodingType: T.Type) -> AnyPublisher<T, APIErrorHandler> where T: Decodable {

        return dataTaskPublisher(for: request)
            .tryMap({ result in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw APIErrorHandler.requestFailed
                }

                if (200..<300) ~= httpResponse.statusCode {
                    return result.data
                } else {
                    if let error = try? JSONDecoder().decode(ApiError.self, from: result.data) {
                        throw APIErrorHandler.customApiError(error)
                    } else {
                        throw APIErrorHandler.emptyErrorWithStatusCode(httpResponse.statusCode.description)
                    }
                }
            })
            .decode(type: APIResponse<T>.self, decoder: JSONDecoder())
            .tryMap { response in
                // FIXME: Fix backend error handler
                if !response.success {
                    throw APIErrorHandler.customApiError(ApiError(code: "500", message: "Internal server error", errorItems: nil))
                }
                return response.data
            }
            .mapError({ error -> APIErrorHandler in
                if let error = error as? APIErrorHandler {
                    return error
                }
                return APIErrorHandler.normalError(error)
            })
            .eraseToAnyPublisher()
    }
}


