//
//  SearchManager.swift
//  TCAT
//
//  Created by Kevin Chan on 9/23/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import FutureNova
import MapKit

struct SearchManagerError: Swift.Error {
    let description: String
}

class SearchManager: NSObject {

    typealias SearchManagerCallback = (_ searchResults: [Place], _ error: Error?) -> Void

    static let shared = SearchManager()

    // MARK: - Private vars
    private var callback: SearchManagerCallback?
    private var busStops = [Place]()
    private let networking: Networking = URLSession.shared.request
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()

    private override init() {
        super.init()
        searchCompleter.delegate = self
        if let searchRadius = CLLocationDistance(exactly: Constants.Map.searchRadius) {
            let center = CLLocationCoordinate2D(latitude: Constants.Map.startingLat, longitude: Constants.Map.startingLong)
            searchCompleter.region = MKCoordinateRegion(
                center: center,
                latitudinalMeters: searchRadius,
                longitudinalMeters: searchRadius
            )
        }
    }

    func performLookup(for query: String, completionHandler: @escaping SearchManagerCallback) {
        getAppleSearchResults(searchText: query).observe { [weak self] result in
            guard let `self` = self else {
                completionHandler([], SearchManagerError(description: "[SearchManager] self is nil"))
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .value(let response):
                    let busStops = response.data.busStops
                    // If the list of Apple Places for this query already exists in
                    // server cache, no further work is needed
                    if let applePlaces = response.data.applePlaces {
                        let searchResults = applePlaces + busStops
                        completionHandler(searchResults, nil)
                    } else {
                        // Otherwise, we need to perform the Apple Places lookup locally
                        // and only display results after this lookup is done
                        self.busStops = busStops
                        self.callback = completionHandler
                        self.searchCompleter.queryFragment = query
                    }
                case .error(let error):
                    completionHandler([], error)
                }
            }
        }
    }

    private func getAppleSearchResults(searchText: String) -> Future<Response<AppleSearchResponse>> {
        return networking(Endpoint.getAppleSearchResults(searchText: searchText)).decode()
    }

}

extension SearchManager: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Get list of ApplePlaces for this search query, i.e. completer.queryFragment
        let query = completer.queryFragment
        var places = [Place]()
        let dispatchGroup = DispatchGroup()
        searchResults = completer.results
        searchResults.forEach { (completion) -> Void in
            let searchRequest = MKLocalSearch.Request(completion: completion)
            let search = MKLocalSearch(request: searchRequest)
            dispatchGroup.enter()
            search.start(completionHandler: { (response, error) in
                if let error = error {
                    print("[SearchManager] Apple Places search result error: \(error)")
                    dispatchGroup.leave()
                    return
                }
                if let mapItem = response?.mapItems.first,
                    let name = mapItem.name,
                    let address = mapItem.placemark.thoroughfare,
                    let city = mapItem.placemark.locality,
                    let state = mapItem.placemark.administrativeArea,
                    let country = mapItem.placemark.country {
                    let lat = mapItem.placemark.coordinate.latitude
                    let long = mapItem.placemark.coordinate.longitude
                    let description = [address, city, state, country].joined(separator: ", ")
                    let place = Place(name: name, latitude: lat, longitude: long, placeDescription: description)
                    places.append(place)
                }
                dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: .main) {
            let searchResults = places + self.busStops
            self.callback?(searchResults, nil)

            self.busStops = []
            self.callback = nil

            // Update server cache of Apple Places for this search query
            self.updateApplePlacesCache(searchText: query, places: places).observe { [weak self] result in
                guard self != nil else { return }
                switch result {
                case .value(let response):
                    print("[SearchManager] Succeeded in updating apple places cache: \(response.data)")
                default: break
                }
            }
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("[SearchManager] MKLocalSearch failed for error: \(error)")
    }

    private func updateApplePlacesCache(searchText: String, places: [Place]) -> Future<Response<Bool>> {
        return networking(Endpoint.updateApplePlacesCache(searchText: searchText, places: places)).decode()
    }

}
