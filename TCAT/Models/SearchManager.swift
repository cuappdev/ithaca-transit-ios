//
//  SearchManager.swift
//  TCAT
//
//  Created by Kevin Chan on 9/23/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import Combine
import Foundation
import MapKit

class SearchManager: NSObject {

    // MARK: - Public Properties
    static let shared = SearchManager()

    // MARK: - Private Properties
    private var busStops = [Place]()
    private var cancellables = Set<AnyCancellable>()
    private var searchQuerySubject = PassthroughSubject<String, Never>()
    private var lastSearchQuery: String?
    private var searchPublisher = PassthroughSubject<Result<[Place], ApiErrorHandler>, Never>()

    // MARK: - Initializer
    override private init() {
        super.init()
        setUpSearchSubscription()
    }

    // MARK: - Public Search Method
    func search(for query: String) -> AnyPublisher<Result<[Place], ApiErrorHandler>, Never> {
        searchQuerySubject.send(query)
        return searchPublisher.eraseToAnyPublisher()
    }

    // MARK: - Private Methods
    private func setUpSearchSubscription() {
        searchQuerySubject
            .removeDuplicates()
            .debounce(for: .milliseconds(750), scheduler: DispatchQueue.main)
            .flatMap { [weak self] searchText -> AnyPublisher<AppleSearchResponse, ApiErrorHandler> in
                guard let self = self, !searchText.isEmpty else {
                    return Fail(error: ApiErrorHandler.noSearchResultsFound).eraseToAnyPublisher()
                }
                self.lastSearchQuery = searchText
                return TransitService.shared.getAppleSearchResults(searchText: searchText)
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.searchPublisher.send(.failure(error))
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                self?.processSearchResults(response: response)
            })
            .store(in: &cancellables)
    }

    private func processSearchResults(response: AppleSearchResponse) {
        busStops = response.busStops

        if let applePlaces = response.applePlaces, !applePlaces.isEmpty {
            let combinedResults = applePlaces + busStops
            self.searchPublisher.send(.success(combinedResults))
        } else {
            if let lastQuery = lastSearchQuery {
                performLocalSearch(with: lastQuery)
            } else {
                self.searchPublisher.send(.failure(.noSearchResultsFound))
            }
        }
    }

    private func performLocalSearch(with query: String) {
        guard !query.isEmpty else {
            self.searchPublisher.send(.failure(.noSearchResultsFound))
            return
        }

        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        let localSearch = MKLocalSearch(request: searchRequest)

        localSearch.start { [weak self] response, error in
            guard let self = self else { return }

            if let error = error {
                self.searchPublisher.send(.failure(.normalError(error)))
                return
            }

            let places = self.extractPlaces(from: response)

            if places.isEmpty {
                self.searchPublisher.send(.failure(.noSearchResultsFound))
            } else {
                let combinedResults = places + self.busStops
                self.searchPublisher.send(.success(combinedResults))
            }
        }
    }

    private func extractPlaces(from response: MKLocalSearch.Response?) -> [Place] {
        return response?.mapItems.compactMap { mapItem -> Place? in
            guard let name = mapItem.name,
                  let address = mapItem.placemark.thoroughfare,
                  let city = mapItem.placemark.locality,
                  let state = mapItem.placemark.administrativeArea,
                  let country = mapItem.placemark.country else { return nil }

            let description = [address, city, state, country].joined(separator: ", ")
            return Place(
                name: name,
                type: .applePlace,
                latitude: mapItem.placemark.coordinate.latitude,
                longitude: mapItem.placemark.coordinate.longitude,
                placeDescription: description
            )
        } ?? []
    }
}
