//
//  ApiErrorHandler.swift
//  TCAT
//
//  Created by Jayson Hahn on 9/16/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation

struct ApiError: Codable {
    let code: String?
    let message: String?
}

enum ApiErrorHandler: Error {
    case customApiError(ApiError)
    case requestFailed
    case normalError(Error)
    case emptyErrorWithStatusCode(String)
    case noSearchResultsFound

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
            return error.localizedDescription

        case .emptyErrorWithStatusCode(let status):
            return "Empty response with status code: \(status)"

        case .noSearchResultsFound:
            return "No search results found"
        }
    }
}
