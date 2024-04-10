//
//  ApolloClientProtocol.swift
//  TCAT
//
//  Created by Vin Bui on 4/10/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Apollo
import Combine
import Foundation

extension ApolloClientProtocol {

    // MARK: - Queries

    /**
     Fetch a query from the server or local cache, depending on the cache contents and specified cache policy.

     - Parameters:
        - query: The query to fetch.
        - cachePolicy: A cache policy that specifies when results should be fetched from the server and when
            data should be loaded from the local cache. Defaults to `.default`.
        - contextIdentifier: [optional] A unique identifier for this request, to help with deduping cache hits
            for watchers. Defaults to `nil`.
        - context: [optional] A context that is being passed through the request chain. Defaults to `nil`.
        - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.

     - Returns: A publisher that delivers results from the fetch operation.
     */
    func queryPublisher<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .default,
        contextIdentifier: UUID? = nil,
        context: RequestContext? = nil,
        queue: DispatchQueue = .main
    ) -> Publishers.ApolloQueryPublisher<Query> {
        let config = Publishers.ApolloQueryConfiguration(
            cachePolicy: cachePolicy,
            client: self,
            context: context,
            contextIdentifier: contextIdentifier,
            query: query,
            queue: queue
        )
        return Publishers.ApolloQueryPublisher(with: config)
    }

    // MARK: - Mutations

    /**
     Perform a mutation by sending it to the server.

     - Parameters:
        - mutation: The mutation to perform.
        - publishResultToStore: If `true`, this will publish the result returned from the operation to the cache store.
            Defaults to `true`.
        - context: [optional] A context that is being passed through the request chain. Defaults to `nil`.
        - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.

     - Returns: A publisher that delivers results from the perform operation.
     */
    func mutationPublisher<Mutation: GraphQLMutation>(
        mutation: Mutation,
        publishResultToStore: Bool = true,
        context: RequestContext? = nil,
        queue: DispatchQueue = .main
    ) -> Publishers.ApolloMutationPublisher<Mutation> {
        let config = Publishers.ApolloMutationConfiguration(
            client: self,
            context: context,
            mutation: mutation,
            publishResultToStore: publishResultToStore,
            queue: queue
        )
        return Publishers.ApolloMutationPublisher(with: config)
    }

}
