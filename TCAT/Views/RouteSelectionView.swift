//
//  RouteSelectionView.swift
//  TCAT
//
//  Created by Monica Ong on 3/5/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

protocol RouteSelectionViewDelegate: class {
    func swapFromAndTo()
    func showDatePicker()
    func searchingFrom()
    func searchingTo()
}

class RouteSelectionView: UIView {

    private weak var delegate: RouteSelectionViewDelegate?

    // MARK: View vars
    private var borderedCircle: Circle!
    private var bottomSeparator: UIView = UIView()
    private var datepickerButton: UIButton = UIButton()
    private var fromLabel: UILabel = UILabel()
    private var fromSearchbar: UIButton = UIButton()
    private var line: SolidLine!
    private var solidCircle: Circle!
    private var swapButton: UIButton = UIButton()
    private var toLabel: UILabel = UILabel()
    private var toSearchbar: UIButton = UIButton()
    private var topSeparator: UIView = UIView()

    private let searchbarHeight: CGFloat = 28

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = Colors.white

        setupLabel(label: fromLabel, text: "From")
        setupLabel(label: toLabel, text: "To")
        setupSearchbar(fromSearchbar)
        setupSearchbar(toSearchbar)
        setupRouteLine()
        setupSwapButton()
        setupSeparator(topSeparator)
        setupDatepickerButton()
        setupSeparator(bottomSeparator)

        setupConstraints()
    }

    private func setupLabel(label: UILabel, text: String) {
        label.text = text
        label.font = .getFont(.regular, size: 14.0)
        label.textColor = Colors.primaryText

        addSubview(label)
    }

    private func setupSearchbar(_ searchbar: UIButton) {
        searchbar.backgroundColor = Colors.backgroundWash
        searchbar.setTitleColor(Colors.primaryText, for: .normal)
        searchbar.titleLabel?.font = .getFont(.regular, size: 14.0)
        searchbar.contentHorizontalAlignment = .left
        searchbar.contentEdgeInsets.left = 12
        searchbar.layer.cornerRadius = searchbarHeight/4
        searchbar.layer.masksToBounds = true

        addSubview(searchbar)
    }

    private func setupRouteLine() {
        solidCircle = Circle(size: .small, style: .solid, color: Colors.metadataIcon)
        line = SolidLine(color: Colors.metadataIcon)
        borderedCircle = Circle(size: .medium, style: .bordered, color: Colors.metadataIcon)

        addSubview(solidCircle)
        addSubview(line)
        addSubview(borderedCircle)
    }

    private func setupSwapButton() {
        swapButton.setImage(#imageLiteral(resourceName: "swap"), for: .normal)
        swapButton.tintColor = Colors.metadataIcon
        swapButton.imageView?.contentMode = .scaleAspectFit

        addSubview(swapButton)
    }

    private func setupDatepickerButton() {
        let datepickerImageWidth: CGFloat = 1.5
        let datepickerTitleLeadingSpace: CGFloat = 12

        datepickerButton.setImage(#imageLiteral(resourceName: "clock"), for: .normal)
        datepickerButton.contentMode = .scaleAspectFit
        datepickerButton.tintColor = Colors.metadataIcon
        datepickerButton.setTitleColor(Colors.metadataIcon, for: .normal)
        datepickerButton.titleLabel?.font = .getFont(.regular, size: 14.0)
        datepickerButton.backgroundColor = Colors.white
        datepickerButton.contentHorizontalAlignment = .left
        datepickerButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        datepickerButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: datepickerButton.imageEdgeInsets.left + datepickerImageWidth + datepickerTitleLeadingSpace, bottom: 0, right: 0)

        addSubview(datepickerButton)
    }

    private func setupSeparator(_ separator: UIView) {
        separator.backgroundColor = Colors.dividerTextField

        addSubview(separator)
    }

    func setDatepickerTitle(withDate date: Date, withSearchTimeType searchTimeType: SearchType) {
        let dateString = Time.dateString(from: date)
        var title = ""

        if Calendar.current.isDateInToday(date) || Calendar.current.isDateInTomorrow(date) {
            let verb = (searchTimeType == .arriveBy) ? "Arrive" : (searchTimeType == .leaveNow) ? "Leave now" : "Leave" //Use simply,"arrive" or "leave"
            let day = Calendar.current.isDateInToday(date) ? "" : "tomorrow " //if today don't put day
            title = (searchTimeType == .leaveNow) ? "\(verb) (\(day.capitalizingFirstLetter())\(Time.timeString(from: date)))" : "\(verb) \(day)at \(Time.timeString(from: date))"
        } else {
            let verb = (searchTimeType == .arriveBy) ? "Arrive by" : "Leave on" //Use "arrive by" or "leave on"
            title = "\(verb) \(dateString)"
        }

        datepickerButton.setTitle(title, for: .normal)
    }

    private func setupConstraints() {
        let datePickerButtonHeight = 40
        let fromSearchbarToSolidCircleSpacing = 20
        let fromSearchbarToSwapButtonSpacing = 16
        let routeLineToCircleInsets = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0) // To remove empty space from curve of circle
        let searchbarSpacing = 12
        let separatorHeight = 1
        let solidCircleToFromLabelSpacing = 17
        let superviewInsets = UIEdgeInsets(top: 10, left: 24, bottom: 0, right: 16)
        let swapButtonSize = CGSize(width: 20, height: 25)
        let topSeparatorToToSearchbarSpacing = 10

        swapButton.snp.makeConstraints { make in
            make.size.equalTo(swapButtonSize)
            make.centerY.equalTo(line)
            make.trailing.equalToSuperview().inset(superviewInsets.right)
        }

        fromSearchbar.snp.makeConstraints { make in
            make.trailing.equalTo(swapButton.snp.leading).offset(-fromSearchbarToSwapButtonSpacing)
            make.top.equalToSuperview().inset(superviewInsets.top)
            make.leading.equalTo(solidCircle.snp.trailing).offset(fromSearchbarToSolidCircleSpacing)
            make.height.equalTo(searchbarHeight)
        }

        toSearchbar.snp.makeConstraints { make in
            make.height.leading.trailing.equalTo(fromSearchbar)
            make.top.equalTo(fromSearchbar.snp.bottom).offset(searchbarSpacing)
            make.height.equalTo(searchbarHeight)
        }

        fromLabel.snp.makeConstraints { make in
            make.size.equalTo(fromLabel.intrinsicContentSize)
            make.leading.equalToSuperview().inset(superviewInsets.left)
            make.centerY.equalTo(fromSearchbar)
        }

        toLabel.snp.makeConstraints { make in
            make.size.equalTo(toLabel.intrinsicContentSize)
            make.leading.equalTo(fromLabel)
            make.centerY.equalTo(borderedCircle)
        }

        solidCircle.snp.makeConstraints { make in
            make.leading.equalTo(fromLabel.snp.trailing).offset(solidCircleToFromLabelSpacing)
            make.centerY.equalTo(fromLabel)
            make.size.equalTo(solidCircle.intrinsicContentSize)
        }

        line.snp.makeConstraints { make in
            make.centerX.equalTo(solidCircle)
            make.top.equalTo(solidCircle.snp.bottom).inset(routeLineToCircleInsets.top)
            make.bottom.equalTo(borderedCircle.snp.top).inset(routeLineToCircleInsets.bottom)
            make.width.equalTo(line.intrinsicContentSize.width)
        }

        borderedCircle.snp.makeConstraints { make in
            make.centerX.equalTo(solidCircle)
            make.centerY.equalTo(toSearchbar)
            make.size.equalTo(borderedCircle.intrinsicContentSize)
        }

        topSeparator.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(toSearchbar.snp.bottom).offset(topSeparatorToToSearchbarSpacing)
            make.height.equalTo(separatorHeight)
        }

        datepickerButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(topSeparator.snp.bottom)
            make.height.equalTo(datePickerButtonHeight)
        }

        bottomSeparator.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(datepickerButton.snp.bottom)
            make.height.equalTo(separatorHeight)
            make.bottom.equalToSuperview().inset(superviewInsets.bottom)
        }
    }

    func configure(delegate: RouteSelectionViewDelegate?, from: String, to: String) {
        self.delegate = delegate

        toSearchbar.addTarget(self, action: #selector(forwardSearchingTo), for: .touchUpInside)
        fromSearchbar.addTarget(self, action: #selector(forwardSearchingFrom), for: .touchUpInside)
        datepickerButton.addTarget(self, action: #selector(forwardShowDatePicker), for: .touchUpInside)
        swapButton.addTarget(self, action: #selector(forwardSwapFromAndTo), for: .touchUpInside)

        updateSearchBarTitles(from: from, to: to)
    }

    func updateSearchBarTitles(from: String? = nil, to: String? = nil) {
        if let from = from {
            fromSearchbar.setTitle(from, for: .normal)
        }

        if let to = to {
            toSearchbar.setTitle(to, for: .normal)
        }
    }

    @objc private func forwardSearchingTo() {
        delegate?.searchingTo()
    }

    @objc private func forwardSearchingFrom() {
        delegate?.searchingFrom()
    }

    @objc private func forwardShowDatePicker() {
        delegate?.showDatePicker()
    }

    @objc private func forwardSwapFromAndTo() {
        delegate?.swapFromAndTo()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
