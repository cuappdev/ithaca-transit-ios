//
//  ApolloNetwork.swift
//  TCAT
//
//  Created by Vin Bui on 4/10/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Apollo
import Foundation

/// An API that used Combine Publishers to execute GraphQL requests and return responses via ApolloClient.
final class ApolloNetwork {

    /// The Apollo client for Uplift.
    static let upliftClient = ApolloClient(url: URL(string: TransitEnvironment.upliftURL)!)

}
