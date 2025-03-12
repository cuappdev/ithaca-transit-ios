//
//  EateryAPI.swift
//  
//
//  Created by William Ma on 1/12/22.
//

import Foundation

public struct EateryAPI {

    private let decoder: JSONDecoder

    private let url: URL

    public init(url: URL) {
        self.url = url

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    public func eateries() async throws -> [Eatery] {
        let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
        var schemaApiResponse: [Schema.Eatery] = []

        do {
            schemaApiResponse = try decoder.decode([Schema.Eatery].self, from: data)
        }
        catch {
            throw EateryAPIError.apiResponseError(error.localizedDescription)
        }

        return schemaApiResponse.map(SchemaToModel.convert)
    }
    
    public func eatery() async throws -> Eatery {
        let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
        var schemaApiResponse: Schema.Eatery

        do {
            schemaApiResponse = try decoder.decode(Schema.Eatery.self, from: data)
        } catch {
            throw EateryAPIError.apiResponseError(error.localizedDescription)
        }
        
        return SchemaToModel.convert(schemaApiResponse)
    }

    public func reportError(eatery: Int64? = nil, content: String) async {
        struct ReportData: Codable {
            let eatery: Int64?
            let content: String
        }
        
        let reportData = ReportData(eatery: eatery, content: content)
        
        guard let jsonData = try? JSONEncoder().encode(reportData) else {
            logger.error("Unable to convert report data to JSON")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                logger.info("\(#function): Status Code \(response.statusCode)")
            }
            if let error = error {
                logger.error("Error submitting report: \(error.localizedDescription)")
            } else if let _ = data {
                logger.info("Successfully reported Eatery Blue issue")
            } else {
                logger.error("Unknown error submitting report")
            }
        }.resume()
    }

}

