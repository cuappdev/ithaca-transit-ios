//
//  HomeOptionsCard.swift
//  TCAT
//
//  Created by Omar Rasheed on 3/23/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import Combine
import CoreLocation
import GoogleMaps
import SnapKit
import UIKit

// MARK: - HomeOptionsCardDelegate
protocol HomeOptionsCardDelegate: AnyObject {
    func updateSize()
    func getCurrentLocation() -> CLLocation?
}

// MARK: - HomeOptionsCard VC
class HomeOptionsCardViewController: UIViewController {

    weak var delegate: HomeOptionsCardDelegate?

    private let infoButton = UIButton(type: .infoLight)
    private var searchBarSeparator: UIView!
    var searchBar: UISearchBar!
    var tableView: UITableView!

    private var searchResultsSection: Section!
    var currentLocation: CLLocation? { return delegate?.getCurrentLocation() }
    var isNetworkDown = false

    private var currentSearchCancellable: AnyCancellable?
    private let infoButtonAnimationDuration = 0.1
    private var keyboardHeight: CGFloat = 0
    private let maxFavoritesCount = 2
    private let maxHeaderCount: CGFloat = 2
    private let maxRecentsCount = 2
    private let maxRowCount: CGFloat = 5
    private let maxScreenCoverage: CGFloat = 3/5
    private let maxSeparatorCount: CGFloat = 1
    private let searchBarHeight: CGFloat = 54
    private let searchBarSeparatorHeight: CGFloat = 1
    private let searchBarTopOffset: CGFloat = 3 // Add top offset to search bar so text is vertically centered
    private let tableViewRowHeight: CGFloat = 50
    let headerHeight: CGFloat = 42

    /// Height of the card when collapsed. This includes just searchBar height and any extra padding/spacing
    var collapsedHeight: CGFloat {
        return searchBarHeight + searchBarSeparatorHeight + searchBarTopOffset
    }

    /// Returns the height of a card that would contain two favorites and two recent searches.
    private var maxCardHeight: CGFloat {
        let totalRowHeight = tableViewRowHeight * maxRowCount
        let totalHeaderHeight = headerHeight * maxHeaderCount
        let totalSeparatorHeight = HeaderView.separatorViewHeight * maxSeparatorCount
        return totalRowHeight + totalHeaderHeight + totalSeparatorHeight + collapsedHeight
    }

    /// Returns the maximum height of the options card given the size of the phone. If the usual
    /// max height would make the card get covered by the keyboard, then we adjust it to be smaller.
    /// Otherwise, we keep it at the maximum height.
    private var adjustedMaxCardHeight: CGFloat {
        // swiftlint:disable:next line_length
        let openScreenSpace = UIScreen.main.bounds.height - HomeMapViewController.optionsCardInset.top - keyboardHeight - 20
        return min(maxCardHeight, openScreenSpace)
    }

    // MARK: - Table Content Variables

    /// Recent locations searched for. Up to `maxRecentsCount` are displayed in the table.
    /// Updating this variable reloads the table.
    var recentLocations: [Place] = [] {
        didSet {
            if recentLocations.count > maxRecentsCount {
                recentLocations = Array(recentLocations.prefix(maxRecentsCount))
            }
            if !isNetworkDown {
                updateSections()
            }
        }
    }

    /// The user's favorited places. Up to `maxFavoritesCount` are displayed in the table.
    /// Updating this variable reloads the table.
    var favorites: [Place] = [] {
        didSet {
            if favorites.count > maxFavoritesCount {
                favorites = Array(favorites.prefix(maxFavoritesCount))
            }
            if !isNetworkDown {
                updateSections()
            }
        }
    }

    /// The table sections. Updating this variable reloads the table.
    var sections: [Section] = [] {
        didSet {
            tableView.reloadData()
            DispatchQueue.main.async {
                self.delegate?.updateSize()
            }
        }
    }

    // MARK: - VC initializer and setup

    init(delegate: HomeOptionsCardDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(handleReachabilityChange), name: .reachabilityChanged, object: nil)

        setupTableView()
        setupInfoButton()
        setupSearchBarSeparator()
        setupSearchBar()
        setupConstraints()
        updatePlaces()
    }

    @objc func handleReachabilityChange() {
        if NetworkMonitor.shared.isReachable {
            self.updateSections()
        } else {
            self.sections = []
        }

        self.isNetworkDown = !NetworkMonitor.shared.isReachable
        self.searchBar.isUserInteractionEnabled = NetworkMonitor.shared.isReachable
        self.setNeedsStatusBarAppearanceUpdate()
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = tableViewRowHeight
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: Constants.Cells.placeIdentifier)
        tableView.register(GeneralTableViewCell.self, forCellReuseIdentifier: Constants.Cells.generalCellIdentifier)
        view.addSubview(tableView)
    }

    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = Constants.General.searchPlaceholder
        searchBar.delegate = self
        searchBar.searchBarStyle = .default
        searchBar.returnKeyType = .search
        searchBar.barTintColor = .white
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBar.layer.borderWidth = 1

        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField,
            let searchView = textFieldInsideSearchBar.leftView as? UIImageView {
            textFieldInsideSearchBar.backgroundColor = Colors.white
            searchView.image = #imageLiteral(resourceName: "search-large")
        }

        // Add horizontal offset so that placeholder text is aligned with bus stop names and all stops
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 8, vertical: 0)
        view.addSubview(searchBar)
    }

    private func setupInfoButton() {
        infoButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 0)
        infoButton.contentVerticalAlignment = .center
        infoButton.tintColor = .black
        infoButton.addTarget(self, action: #selector(openInformationScreen), for: .touchUpInside)
        view.addSubview(infoButton)
    }

    private func setupSearchBarSeparator() {
        searchBarSeparator = UIView()
        searchBarSeparator.backgroundColor = Colors.backgroundWash
        view.addSubview(searchBarSeparator)
    }

    private func setupConstraints() {
        let infoButtonSize = CGSize.init(width: 30, height: 38)
        let infoButtonTrailingInset = 16

        infoButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(searchBar).offset(-searchBarTopOffset / 2)
            make.trailing.equalToSuperview().inset(infoButtonTrailingInset)
            make.size.equalTo(infoButtonSize)
        }

        searchBar.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().inset(searchBarTopOffset)
            make.trailing.equalTo(infoButton.snp.leading)
            make.height.equalTo(searchBarHeight)
        }

        searchBarSeparator.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom)
            make.height.equalTo(searchBarSeparatorHeight)
        }

        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(searchBarSeparator.snp.bottom)
        }
    }

    /// Updates the table sections to show favorites, recent searches, and all stops. Ultimately reloads the table.
    func updateSections() {
        sections.removeAll()
        if !recentLocations.isEmpty {
            sections.append(Section.recentSearches(items: recentLocations))
        }
        sections.append(Section.seeAllStops)
    }

    /// Updates recent searches and favorites. Ultimately reloads the table.
    func updatePlaces() {
        recentLocations = Global.shared.retrievePlaces(for: Constants.UserDefaults.recentSearch)
    }

    // MARK: - Table Calculations

    private func tableViewContentHeight() -> CGFloat {
        return sections.reduce(0) { (result, section) -> CGFloat in
            switch section {
            case .recentSearches:
                return headerHeight + tableViewRowHeight * CGFloat(section.getItems().count) + result

            case .seeAllStops:
                return HeaderView.separatorViewHeight + tableViewRowHeight + result

            default:
                return tableViewRowHeight * CGFloat(section.getItems().count) + result
            }
        }
    }

    /// Decide whether to show full card or just searchBar
    func calculateCardHeight() -> CGFloat {
        if searchBar.isFirstResponder {
            let contentHeight = tableViewContentHeight() + collapsedHeight
            return min(contentHeight, adjustedMaxCardHeight)
        } else {
            return collapsedHeight
        }
    }

    // MARK: - infoButton Interactivity

    func animateInInfoButton() {
        UIView.animate(withDuration: infoButtonAnimationDuration) {
            self.infoButton.alpha = 1

            self.searchBar.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview()
                make.top.equalToSuperview().inset(self.searchBarTopOffset)
                make.trailing.equalTo(self.infoButton.snp.leading)
                make.height.equalTo(self.searchBarHeight)
            }
            self.view.layoutIfNeeded()
        }
    }

    func animateOutInfoButton() {
        UIView.animate(withDuration: infoButtonAnimationDuration) {
            self.infoButton.alpha = 0
            self.searchBar.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.top.equalToSuperview().inset(self.searchBarTopOffset)
                make.trailing.equalTo(self.infoButton.snp.trailing)
                make.height.equalTo(self.searchBarHeight)
            }
            self.view.layoutIfNeeded()
        }
    }

    /// Open information screen
    @objc private func openInformationScreen() {
        let informationViewController = InformationViewController()
        let navigationVC = CustomNavigationController(rootViewController: informationViewController)
        present(navigationVC, animated: true)
    }

    // MARK: - Get Search Results
    /// Get Search Results
    internal func startSearch(for searchText: String) {
        currentSearchCancellable?.cancel()

        currentSearchCancellable = SearchManager.shared.search(for: searchText)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let searchResults):
                    self.searchResultsSection = Section.searchResults(items: searchResults)
                    self.tableView.contentOffset = .zero
                    self.sections = [self.searchResultsSection]

                case .failure(let error):
                    print("Search error: \(error.errorDescription)")
                }
            }
    }

    // MARK: - Keyboard

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (
            notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
        )?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
