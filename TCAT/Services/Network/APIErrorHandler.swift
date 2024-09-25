//
//  APIErrorHandler.swift
//  TCAT
//
//  Created by Jayson Hahn on 9/16/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation

struct ApiError: Codable {
    let code: String?
    let message: String?
    let errorItems: [String: String]?
}

enum APIErrorHandler: Error {
    case customApiError(ApiError)
    case requestFailed
    case normalError(Error)
    case emptyErrorWithStatusCode(String)

    var errorDescription: String? {
        switch self {
        case .customApiError(let apiError):
            var errorItems: String?
            if let errorItemsDict = apiError.errorItems {
                errorItems = ""
                errorItemsDict.forEach { key, value in
                    errorItems?.append(key)
                    errorItems?.append(" ")
                    errorItems?.append(value)
                    errorItems?.append("\n")
                }
            }
            if errorItems == nil && apiError.code == nil && apiError.message == nil {
                errorItems = "Internal error!"
            }
            return String(format: "%@ %@ \n %@", apiError.code ?? "", apiError.message ?? "", errorItems ?? "")
        case .requestFailed:
            return "request failed"
        case .normalError(let error):
            return error.localizedDescription
        case .emptyErrorWithStatusCode(let status):
            return status
        }
    }
}
