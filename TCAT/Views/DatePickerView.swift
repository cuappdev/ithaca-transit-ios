//
//  DatepickerView.swift
//  TCAT
//
//  Created by Monica Ong on 3/14/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

struct SegmentControlElement {
    var title: String
    var index: Int
}

protocol DatePickerViewDelegate: AnyObject {
    func dismissDatePicker()
    func saveDatePickerDate(for date: Date, searchType: SearchType)
}

class DatePickerView: UIView {

    // MARK: - Data vars

    private weak var delegate: DatePickerViewDelegate?
    private let leaveNowElement = SegmentControlElement(title: Constants.General.datepickerLeaveNow, index: 0)
    private let leaveAtElement = SegmentControlElement(title: Constants.General.datepickerLeaveAt, index: 1)
    private let arriveByElement = SegmentControlElement(title: Constants.General.datepickerArriveBy, index: 2)

    // MARK: - View vars

    private var cancelButton: UIButton = UIButton()
    private var datepicker: UIDatePicker = UIDatePicker()
    private var doneButton: UIButton = UIButton()
    private var timeTypeSegmentedControl: UISegmentedControl = UISegmentedControl()

    // MARK: - Init

    init(delegate: DatePickerViewDelegate? = nil) {
        super.init(frame: .zero)

        self.delegate = delegate
        backgroundColor = Colors.white
        layer.cornerRadius = 8
        clipsToBounds = true

        setupDatePicker()
        setupTimeTypeSegmentedControl()
        setupCancelButton()
        setupDoneButton()

        setupConstraints()
    }

    // MARK: - View setup

    private func setupDatePicker() {
        let now = Date()
        datepicker.minimumDate = now

        let next7Days = now.addingTimeInterval(7*24*60*60)
        datepicker.maximumDate = next7Days //set maximum date to 7 days from now

        datepicker.addTarget(self, action: #selector(datepickerValueChanged(datepicker:)), for: .valueChanged)

        addSubview(datepicker)
    }

    private func styleSegmentedControl(_ segmentedControl: UISegmentedControl) {
        segmentedControl.tintColor = Colors.tcatBlue
        segmentedControl.setTitleTextAttributes(
            [.font: UIFont.getFont(.regular, size: 13.0)],
            for: .normal
        )
    }

    private func setSegmentedControlOptions(_ segmentedContol: UISegmentedControl, options: [String]) {
        options.indices.forEach { i in
            segmentedContol.insertSegment(withTitle: options[i], at: i, animated: false)
        }
    }

    private func setupTimeTypeSegmentedControl() {
        styleSegmentedControl(timeTypeSegmentedControl)
        setSegmentedControlOptions(timeTypeSegmentedControl, options: [leaveNowElement.title,leaveAtElement.title, arriveByElement.title])
        timeTypeSegmentedControl.selectedSegmentIndex = leaveNowElement.index

        addSubview(timeTypeSegmentedControl)
    }

    private func setupCancelButton() {
        cancelButton.titleLabel?.font = .getFont(.regular, size: 17.0)
        cancelButton.setTitleColor(Colors.metadataIcon, for: .normal)
        cancelButton.setTitle(Constants.Buttons.cancel, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)

        addSubview(cancelButton)
    }

    private func setupDoneButton() {
        doneButton.titleLabel?.font = .getFont(.regular, size: 17.0)
        doneButton.setTitleColor(Colors.tcatBlue, for: .normal)
        doneButton.setTitle(Constants.Buttons.done, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)

        addSubview(doneButton)
    }

    private func setupConstraints() {
        let buttonHeight = 20
        let datePickerHeight = 164.5
        let segmentedControlHeight = 29
        let segmentedControlSizeRatio = 0.5
        let spaceBtButtonAndSegmentedControl = 16
        let spaceBtButtonAndSuperviewSide = 12
        let spaceBtButtonAndSuprviewTop = 16
        let spaceBtSegmentControlAndDatePicker = 8
        let spaceBtSegmentControls = 8

        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(spaceBtButtonAndSuperviewSide)
            make.top.equalToSuperview().inset(spaceBtButtonAndSuprviewTop)
            make.width.equalTo(cancelButton.intrinsicContentSize.width)
            make.height.equalTo(buttonHeight)
        }

        doneButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(spaceBtButtonAndSuperviewSide)
            make.top.equalToSuperview().inset(spaceBtButtonAndSuprviewTop)
            make.width.equalTo(doneButton.intrinsicContentSize.width)
            make.height.equalTo(buttonHeight)
        }

        timeTypeSegmentedControl.snp.makeConstraints { make in
            make.trailing.equalTo(doneButton)
            make.top.equalTo(doneButton.snp.bottom).offset(spaceBtButtonAndSegmentedControl)
            make.height.equalTo(segmentedControlHeight)
            make.leading.equalTo(cancelButton)
        }

        datepicker.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(90)
            make.top.equalTo(timeTypeSegmentedControl.snp.bottom).offset(spaceBtSegmentControlAndDatePicker)
            make.height.equalTo(datePickerHeight)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }

    // MARK: - Setters

    func setDatepickerDate(date: Date) {
        datepicker.date = date
        datepickerValueChanged(datepicker: datepicker)
    }

    func setDatepickerTimeType(searchTimeType: SearchType) {
        switch searchTimeType {
        case .leaveAt, .leaveNow:
            timeTypeSegmentedControl.selectedSegmentIndex = leaveAtElement.index
        case .arriveBy:
            timeTypeSegmentedControl.selectedSegmentIndex = arriveByElement.index
        }
    }

    // MARK: - Buttons

    @objc private func doneButtonPressed() {
        var searchTimeType: SearchType = .leaveNow
        if timeTypeSegmentedControl.selectedSegmentIndex != leaveNowElement.index {
            switch timeTypeSegmentedControl.selectedSegmentIndex {
            case arriveByElement.index:
                searchTimeType = .arriveBy
            case leaveAtElement.index:
                searchTimeType = .leaveAt
            default:
                break
            }
        } else {
            //If the user for some reason changes the date/time on datepicker, but selects leaveNow
            //we change the date/time on datepicker to be the current date/time
            datepicker.date = Date()
        }

        delegate?.saveDatePickerDate(for: datepicker.date, searchType: searchTimeType)
    }

    @objc private func cancelButtonPressed() {
        delegate?.dismissDatePicker()
    }

    // MARK: - Segment Controls

    @objc private func leaveNowSegmentedControlValueChanged(segmentControl: UISegmentedControl) {
        datepicker.date = Date()
    }

    // MARK: - Datepicker

    @objc private func datepickerValueChanged(datepicker: UIDatePicker) {
        if Time.compare(date1: datepicker.date, date2: Date()) == ComparisonResult.orderedSame {
            timeTypeSegmentedControl.selectedSegmentIndex = leaveNowElement.index
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
