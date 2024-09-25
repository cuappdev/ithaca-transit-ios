//
//  NetworkManager.swift
//  TCAT
//
//  Created by Jayson Hahn on 9/15/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation
import Combine

class NetworkManager {

    let session: NetworkSession

    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }

    func performRequest<T>(
        _ request: URLRequest,
        decodingType: T.Type
    ) -> AnyPublisher<
        T,
        APIErrorHandler
    > where T: Decodable {
        return session.publisher(request, decodingType: decodingType)
            .mapError { error -> APIErrorHandler in
                return error
            }
            .eraseToAnyPublisher()
    }

}
