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
    /// - Returns: A publisher that emits the decoded object of type `T` or an `ApiErrorHandler` on failure.
    func request<T: Decodable>(_ request: URLRequest, decodingType: T.Type) -> AnyPublisher<T, ApiErrorHandler>
}

class NetworkManager: NetworkService {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ request: URLRequest, decodingType: T.Type) -> AnyPublisher<T, ApiErrorHandler> {
        return session.dataTaskPublisher(for: request)
            .tryMap { result in
                try self.handleResponse(result)
            }
            .decode(type: APIResponse<T>.self, decoder: JSONDecoder())
            .tryMap { response in
                try self.validateAPIResponse(response)
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

    // Validate API response and handle future error cases
    private func validateAPIResponse<T>(_ response: APIResponse<T>) throws -> T {
        guard response.success else {
            // TODO: Update when backend sends more error codes
            throw ApiErrorHandler.customApiError(ApiError(code: "500", message: "Internal server error"))
        }

        return response.data
    }

    // Map Combine errors to custom APIErrorHandler types
    private func mapToAPIError(_ error: Error) -> ApiErrorHandler {
        if let apiError = error as? ApiErrorHandler {
            return apiError
        }

        return ApiErrorHandler.normalError(error)
    }
}
