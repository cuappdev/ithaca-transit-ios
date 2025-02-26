//
//  ApiErrorHandler.swift
//  TCAT
//
//  Created by Jayson Hahn on 9/16/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation

/// Represents an API error with optional code and message.
struct ApiError: Codable {
    let code: String?
    let message: String?
}

/// Enum to handle various API errors and provide localized error descriptions.
enum ApiErrorHandler: LocalizedError {
    /// Custom API error with associated `ApiError` object.
    case customApiError(ApiError)

    /// Error indicating that the request failed.
    case requestFailed

    /// Normal error with associated `Error` object.
    case normalError(Error)

    /// Error indicating an empty response with a specific status code.
    case emptyErrorWithStatusCode(String)

    /// Error indicating that no search results were found.
    case noSearchResultsFound

    /// Provides a localized description for each error case.
    var errorDescription: String {
        switch self {
        case .customApiError(let apiError):
            var errorComponents = [String]()

            if let code = apiError.code, !code.isEmpty {
                errorComponents.append("Code: \(code)")
            }

            if let message = apiError.message, !message.isEmpty {
                errorComponents.append("Message: \(message)")
            }

            if errorComponents.isEmpty {
                return "Internal error!"
            }

            return errorComponents.joined(separator: "\n")

        case .requestFailed:
            return "Request failed"

        case .normalError(let error):
            return "Normal error: \(error.localizedDescription)"
        
        case .emptyErrorWithStatusCode(let status):
            return "Empty response with status code: \(status)"

        case .noSearchResultsFound:
            return "No search results found"
        }
    }
}
