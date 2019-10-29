//
//  AllStopsTableViewController.swift
//  TCAT
//
//  Created by Austin Astorga on 11/11/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import DZNEmptyDataSet
import FutureNova
import UIKit

class StopPickerViewController: UIViewController {
    private var tableView = UITableView()
    private typealias Section = (title: String, places: [Place])
    private var sections: [Section] = []
    
    private var isLoading: Bool { return loadingIndicator != nil }
    private var loadingIndicator: LoadingIndicator?

    /// Handles a `Place` selection.
    var onSelection: ((Place) -> ())?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: -View setup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Constants.Titles.allStops
        setupTableView()
        refreshStops()
    }

    private func setupTableView() {
        tableView.sectionIndexColor = Colors.primaryText
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: Constants.Cells.placeIdentifier)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setUpLoadingIndicator() {
        loadingIndicator = LoadingIndicator()
        guard let loadingIndicator = loadingIndicator else { return }
        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
    
    // MARK: -Refresh stops

    private func getStopsFromServer() -> Future<Response<[Place]>> {
        return URLSession.shared.request(endpoint: Endpoint.getAllStops()).decode()
    }

    /// Get all bus stops from the server, update UserDefaults, and refresh the table
    private func refreshStops() {
        setUpLoadingIndicator()
        
        if let busStopsData = userDefaults.data(forKey: Constants.UserDefaults.allBusStops),
            let busStops = try? decoder.decode([Place].self, from: busStopsData) {
            loadingIndicator?.removeFromSuperview()
            loadingIndicator = nil
            sections = tableSections(for: busStops)
            tableView.reloadData()
        } else {
            getStopsFromServer().observe { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .value(let response):
                    guard !response.data.isEmpty else { return } // ensure the response has stops
                    
                    do {
                        let stopsData = try JSONEncoder().encode(response.data) // note: response.data is [Place], not Data
                        userDefaults.set(stopsData, forKey: Constants.UserDefaults.allBusStops)
                        self.sections = self.tableSections(for: response.data)
                    } catch {
                        self.logRefreshError(error)
                    }
                case .error(let error):
                    self.logRefreshError(error)
                }
                
                DispatchQueue.main.async {
                    self.loadingIndicator?.removeFromSuperview()
                    self.loadingIndicator = nil
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    /// Sorts `busStops` into table `Section`s in alphabetical order.
    private func tableSections(for busStops: [Place]) -> [Section] {
        var sectionsDict: [String : [Place]] = [:]

        // Sort into dict by first letter
        for busStop in busStops {
            if let firstChar = busStop.name.capitalized.first {
                let section = firstChar.isNumber ? "#" : String(firstChar)
                sectionsDict[section, default: []].append(busStop)
            }
        }
        
        // Sort titles, putting # at the end
        let titles = sectionsDict.keys.sorted(by: { $0 == "#" ? false : $0 < $1 })
        // Sort places once at the end and return
        return titles.map { title in
            let places = sectionsDict[title]?.sorted(by: { $0.name < $1.name }) ?? []
            return Section(title: title, places: places)
        }
    }
    
    /// Logs an error that was thrown while attempting to refresh the bus stops.
    private func logRefreshError(_ error: Error) {
        self.printClass(context: "AllStopsTableViewController.refreshStops error", message: error.localizedDescription)
        let payload = NetworkErrorPayload(
            location: "\(self) Get All Stops",
            type: "\((error as NSError).domain)",
            description: error.localizedDescription)
        Analytics.shared.log(payload)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: -DZNEmptyDataSetSource
extension StopPickerViewController: DZNEmptyDataSetSource {

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        // If loading indicator is being shown, don't display image
        return isLoading ? nil : #imageLiteral(resourceName: "serverDown")
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        // If loading indicator is being shown, don't display description
        if isLoading {
            return nil
        }
        let title = Constants.EmptyStateMessages.couldntGetStops
        return NSAttributedString(string: title, attributes: [.foregroundColor: Colors.metadataIcon])
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        // If loading indicator is being shown, don't display button
        if isLoading {
            return nil
        }
        let title = Constants.Buttons.retry
        return NSAttributedString(string: title, attributes: [.foregroundColor: Colors.tcatBlue])
    }
}

// MARK: -DZNEmptyDataSetDelegate
extension StopPickerViewController: DZNEmptyDataSetDelegate {
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap didTapButton: UIButton) {
        setUpLoadingIndicator()
        refreshStops()
    }
    
}

// MARK: -TableViewDelegate
extension StopPickerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let inset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        cell.separatorInset = inset
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = inset
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.placeIdentifier, for: indexPath) as? PlaceTableViewCell else { return UITableViewCell() }
        cell.configure(for: sections[indexPath.section].places[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = sections[indexPath.section].places[indexPath.row]
        definesPresentationContext = false
        tableView.deselectRow(at: indexPath, animated: true)
        onSelection?(place)
    }
    
}

// MARK: -Table view data source
extension StopPickerViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].places.count
    }

}
