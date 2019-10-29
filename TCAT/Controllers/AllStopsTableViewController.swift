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

protocol UnwindAllStopsTVCDelegate: class {
    func dismissSearchResultsVC(place: Place)
}

class AllStopsTableViewController: UIViewController {

    private weak var unwindAllStopsTVCDelegate: UnwindAllStopsTVCDelegate?

    private var tableView = UITableView()
    
    private typealias Section = (title: String, places: [Place])
    private var sections: [Section] = []
    
//    private var allStops: [Place] = []
    private var isLoading: Bool { return loadingIndicator != nil }
    private var loadingIndicator: LoadingIndicator?
    private let networking: Networking = URLSession.shared.request
//    private var sectionIndexes: [String: [Place]] = [:]
//    private var sortedKeys: [String] = []

    init(delegate: UnwindAllStopsTVCDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.unwindAllStopsTVCDelegate = delegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Constants.Titles.allStops
        
        setupTableView()
        setupConstraints()

        refreshAllStops()
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
    }

    private func setupConstraints() {
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

    private func getStopsFromServer() -> Future<Response<[Place]>> {
        return networking(Endpoint.getAllStops()).decode()
    }

    /// Get all bus stops and store in UserDefaults
    private func refreshStops() {
        setUpLoadingIndicator()
        
        if let busStopsData = userDefaults.data(forKey: Constants.UserDefaults.allBusStops),
            let busStops = try? decoder.decode([Place].self, from: busStopsData) {
            loadingIndicator?.removeFromSuperview()
            loadingIndicator = nil
            
            guard !busStops.isEmpty else { return }
            setupTableSections(busStops: busStops)
            tableView.reloadData()
        } else {
            getStopsFromServer().observe { [weak self] result in
                
            }
        }
        
        if let allBusStops = userDefaults.value(forKey: Constants.UserDefaults.allBusStops) as? Data,
            let busStopArray = try? decoder.decode([Place].self, from: allBusStops) {
            allStops = busStopArray
            loadingIndicator?.removeFromSuperview()
            loadingIndicator = nil
            createSectionIndexesForBusStop()
            tableView.reloadData()
            return
        }
        getAllStops().observe { [weak self] result in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .value(let response):
                    if !response.data.isEmpty {
                        // Save bus stops in userDefaults
                        do {
                            let encodedObject = try JSONEncoder().encode(response.data)
                            userDefaults.set(encodedObject, forKey: Constants.UserDefaults.allBusStops)
                        } catch let error {
                            self.printClass(context: "\(#function) error", message: error.localizedDescription)
                            let payload = NetworkErrorPayload(
                                location: "\(self) Get All Stops",
                                type: "\((error as NSError).domain)",
                                description: error.localizedDescription)
                            Analytics.shared.log(payload)
                        }
                        self.allStops = response.data
                    }
                case .error(let error):
                    self.printClass(context: "\(#function) error", message: error.localizedDescription)
                    let payload = NetworkErrorPayload(
                        location: "\(self) Get All Stops",
                        type: "\((error as NSError).domain)",
                        description: error.localizedDescription)
                    Analytics.shared.log(payload)
                }
                self.loadingIndicator?.removeFromSuperview()
                self.loadingIndicator = nil
                self.createSectionIndexesForBusStop()
                self.tableView.reloadData()
            }
        }
    }
    
    private func setupTableSections(busStops: [Place]) {
        var sectionsDict: [String : [Place]] = [:]

        // Sort into dict by first letter
        for busStop in busStops {
            if let firstChar = busStop.name.capitalized.first {
                let section = firstChar.isNumber ? "#" : String(firstChar)
                sectionsDict[section, default: []].append(busStop)
            }
        }
        
        // Sort titles, putting # in the end
        let titles = sectionsDict.keys.sorted(by: { $0 == "#" ? false : $0 < $1 })
        // Sort places once at the end and update global sections
        sections = titles.map { title in
            let places = sectionsDict[title]?.sorted(by: { $0.name < $1.name }) ?? []
            return Section(title: title, places: places)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: DZNEmptyDataSetSource
extension AllStopsTableViewController: DZNEmptyDataSetSource {

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

// MARK: DZNEmptyDataSetDelegate
extension AllStopsTableViewController: DZNEmptyDataSetDelegate {
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap didTapButton: UIButton) {
        setUpLoadingIndicator()
        refreshAllStops()
    }
    
}

// MARK: TableViewDelegate
extension AllStopsTableViewController: UITableViewDelegate {

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
        let optionsVC = RouteOptionsViewController(searchTo: place)
        definesPresentationContext = false
        tableView.deselectRow(at: indexPath, animated: true)

        // TODO: CHECK THIS
        
        if let unwindDelegate = unwindAllStopsTVCDelegate {
            unwindDelegate.dismissSearchResultsVC(place: place)
            navigationController?.popViewController(animated: true)
        } else {
            navigationController?.pushViewController(optionsVC, animated: true)
        }
    }
    
}

// MARK: Table view data source
extension AllStopsTableViewController: UITableViewDataSource {

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
