//
//  NetworkManager.swift
//  TCAT
//
//  Created by Jayson Hahn on 9/15/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation
import Combine

protocol NetworkService {
    /// Sends a network request and decodes the response into the specified type.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` to be sent.
    ///   - decodingType: The type to decode the response into. Must conform to `Decodable`.
    ///   - responseType: The type of response format expected (.standard or .simple)
    /// - Returns: A publisher that emits the decoded object of type `T` or an `ApiErrorHandler` on failure.
    func request<T: Decodable>(
        _ request: URLRequest,
        decodingType: T.Type,
        responseType: ResponseFormat
    ) -> AnyPublisher<
        T,
        ApiErrorHandler
    >
}

enum ResponseFormat {
    case standard    // Format with success and data
    case simple      // Format with only success
}

class NetworkManager: NetworkService {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(
        _ request: URLRequest,
        decodingType: T.Type,
        responseType: ResponseFormat = .standard
    ) -> AnyPublisher<
        T,
        ApiErrorHandler
    > {
        print(request.url?.absoluteString ?? "No URL")
        return session.dataTaskPublisher(for: request)
            .tryMap { result in
                try self.handleResponse(result)
            }
            .flatMap { data in
                self.decodeResponse(data: data, decodingType: decodingType, responseType: responseType)
            }
            .mapError { error in
                self.mapToAPIError(error)
            }
            .eraseToAnyPublisher()
    }

    // Handles HTTP response and decodes or throws an appropriate error
    private func handleResponse(_ result: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard let httpResponse = result.response as? HTTPURLResponse else {
            throw ApiErrorHandler.requestFailed
        }

        if (200..<300).contains(httpResponse.statusCode) {
            return result.data
        } else {
            // Attempt to decode error message from server
            if let apiError = try? JSONDecoder().decode(ApiError.self, from: result.data) {
                throw ApiErrorHandler.customApiError(apiError)
            } else {
                throw ApiErrorHandler.emptyErrorWithStatusCode(httpResponse.statusCode.description)
            }
        }
    }

    // Decodes the response based on response format
    private func decodeResponse<T: Decodable>(
        data: Data,
        decodingType: T.Type,
        responseType: ResponseFormat
    ) -> AnyPublisher<
        T,
        Error
    > {
        let decoder = JSONDecoder()
        switch responseType {
        case .standard:
            return Just(data)
                .decode(type: APIResponse<T>.self, decoder: decoder)
                .tryMap { response in
                    try self.validateAPIResponse(response)
                }
                .eraseToAnyPublisher()
        case .simple:
            return Just(data)
                .decode(type: SimpleAPIResponse.self, decoder: decoder)
                .tryMap { response in
                    let success = try self.validateSimpleResponse(response)
                    guard let result = success as? T else {
                        throw ApiErrorHandler.requestFailed
                    }
                    return result
                }
                .eraseToAnyPublisher()
        }
    }

    // Validate standard API response
    private func validateAPIResponse<T>(_ response: APIResponse<T>) throws -> T {
        guard response.success else {
            // TODO: Update when backend sends more error codes
            throw ApiErrorHandler.customApiError(ApiError(code: "500", message: "Internal server error"))
        }

        return response.data
    }

    // Validate simple API response
    private func validateSimpleResponse(_ response: SimpleAPIResponse) throws -> Bool {
        guard response.success else {
            // TODO: Update when backend sends more error codes
            throw ApiErrorHandler.customApiError(ApiError(code: "500", message: "Internal server error"))
        }

        return response.success
    }

    // Map Combine errors to custom APIErrorHandler types
    private func mapToAPIError(_ error: Error) -> ApiErrorHandler {
        if let apiError = error as? ApiErrorHandler {
            return apiError
        }

        return ApiErrorHandler.normalError(error)
    }
    
    // Returns raw response reqdata from backend requests (made for live tracking debugging)
    func requestResponse(_ request: URLRequest) -> AnyPublisher<Data, ApiErrorHandler> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .mapError { error -> ApiErrorHandler in
                return ApiErrorHandler(error: error)
            }
            .eraseToAnyPublisher()
    }

}
