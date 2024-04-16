//
//  Publishers.swift
//  TCAT
//
//  Created by Vin Bui on 4/10/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Apollo
import Combine
import Foundation

/// A structure that represents a custom error from GraphQL.
struct GraphQLErrorWrapper: Error {
    let msg: String
}

extension Publishers {

    // MARK: - Queries

    /// A configuration for an a GraphQL Query used by Apollo.
    struct ApolloQueryConfiguration<Query: GraphQLQuery> {
        let cachePolicy: CachePolicy
        let client: ApolloClientProtocol
        let context: RequestContext?
        let contextIdentifier: UUID?
        let query: Query
        let queue: DispatchQueue
    }

    /// A Combine Publisher for a GraphQL Query used by Apollo.
    struct ApolloQueryPublisher<Query: GraphQLQuery>: Publisher {
        typealias Output = GraphQLResult<Query.Data>
        typealias Failure = Error

        private let configuration: ApolloQueryConfiguration<Query>

        init(with configuration: ApolloQueryConfiguration<Query>) {
            self.configuration = configuration
        }

        func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            let subscription = ApolloQuerySubscription(subscriber: subscriber, configuration: configuration)
            subscriber.receive(subscription: subscription)
        }
    }

    /// A Combine Subscription for a GraphQL Query used by Apollo.
    private final class ApolloQuerySubscription<S: Subscriber, Query: GraphQLQuery>: Subscription
    where S.Failure == Error, S.Input == GraphQLResult<Query.Data> {
        private let configuration: ApolloQueryConfiguration<Query>
        var subscriber: S?
        private var task: Apollo.Cancellable?

        init(subscriber: S?, configuration: ApolloQueryConfiguration<Query>) {
            self.subscriber = subscriber
            self.configuration = configuration
        }

        func request(_ demand: Subscribers.Demand) {
            task = configuration.client.fetch(
                query: configuration.query,
                cachePolicy: configuration.cachePolicy,
                contextIdentifier: configuration.contextIdentifier,
                context: configuration.context,
                queue: configuration.queue
            ) { [weak self] result in
                switch result {
                case .success(let data):
                    if let graphQLError = data.errors?.first {
                        let error = GraphQLErrorWrapper(msg: graphQLError.description)
                        self?.subscriber?.receive(completion: .failure(error))
                    } else {
                        _ = self?.subscriber?.receive(data)

                        if self?.configuration.cachePolicy == .returnCacheDataAndFetch && data.source == .cache {
                            return
                        }
                        self?.subscriber?.receive(completion: .finished)
                    }

                case .failure(let error):
                    self?.subscriber?.receive(completion: .failure(error))
                }
            }
        }

        func cancel() {
            task?.cancel()
            task = nil
            subscriber = nil
        }
    }

    // MARK: - Mutations

    /// A configuration for an a GraphQL Mutation used by Apollo.
    struct ApolloMutationConfiguration<Mutation: GraphQLMutation> {
        let client: ApolloClientProtocol
        let context: RequestContext?
        let mutation: Mutation
        let publishResultToStore: Bool
        let queue: DispatchQueue
    }

    /// A Combine Publisher for a GraphQL Mutation used by Apollo.
    struct ApolloMutationPublisher<Mutation: GraphQLMutation>: Publisher {
        typealias Output = GraphQLResult<Mutation.Data>
        typealias Failure = Error

        private let configuration: ApolloMutationConfiguration<Mutation>

        init(with configuration: ApolloMutationConfiguration<Mutation>) {
            self.configuration = configuration
        }

        func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            let subscription = ApolloMutationSubscription(subscriber: subscriber, configuration: configuration)
            subscriber.receive(subscription: subscription)
        }
    }

    /// A Combine Subscription for a GraphQL Mutation used by Apollo.
    private final class ApolloMutationSubscription<S: Subscriber, Mutation: GraphQLMutation>: Subscription
    where S.Failure == Error, S.Input == GraphQLResult<Mutation.Data> {
        private let configuration: ApolloMutationConfiguration<Mutation>
        private var subscriber: S?
        private var task: Apollo.Cancellable?

        init(subscriber: S, configuration: ApolloMutationConfiguration<Mutation>) {
            self.subscriber = subscriber
            self.configuration = configuration
        }

        func request(_ demand: Subscribers.Demand) {
            task = configuration.client.perform(
                mutation: configuration.mutation,
                publishResultToStore: configuration.publishResultToStore,
                context: configuration.context,
                queue: configuration.queue
            ) { [weak self] result in
                switch result {
                case .success(let data):
                    if let graphQLError = data.errors?.first {
                        let error = GraphQLErrorWrapper(msg: graphQLError.description)
                        self?.subscriber?.receive(completion: .failure(error))
                    } else {
                        _ = self?.subscriber?.receive(data)
                        self?.subscriber?.receive(completion: .finished)
                    }

                case .failure(let error):
                    self?.subscriber?.receive(completion: .failure(error))
                }
            }
        }

        func cancel() {
            task?.cancel()
            task = nil
            subscriber = nil
        }
    }

}
