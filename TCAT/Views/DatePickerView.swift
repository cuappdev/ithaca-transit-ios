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

protocol DatePickerViewDelegate: class {
    func dismissDatePicker()
    func saveDatePickerDate(for date: Date, searchType: SearchType)
}

class DatePickerView: UIView {

    // MARK: Data vars

    weak var delegate: DatePickerViewDelegate?
    let leaveNowElement = SegmentControlElement(title: Constants.General.datepickerLeaveNow, index: 0)
    let leaveAtElement = SegmentControlElement(title: Constants.General.datepickerLeaveAt, index: 0)
    let arriveByElement = SegmentControlElement(title: Constants.General.datepickerArriveBy, index: 1)

    // MARK: View vars

    var cancelButton: UIButton = UIButton()
    var datepicker: UIDatePicker = UIDatePicker()
    var doneButton: UIButton = UIButton()
    var leaveNowSegmentedControl: UISegmentedControl = UISegmentedControl()
    var timeTypeSegmentedControl: UISegmentedControl = UISegmentedControl()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = Colors.white

        setupDatePicker()
        setupTimeTypeSegmentedControl()
        setupLeaveNowSegmentedControl()
        setupCancelButton()
        setupDoneButton()

        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Style

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
            for: .normal)
    }

    private func setSegmentedControlOptions(_ segmentedContol: UISegmentedControl, options: [String]) {
        options.indices.forEach { i in
            segmentedContol.insertSegment(withTitle: options[i], at: i, animated: false)
        }
    }

    private func setupTimeTypeSegmentedControl() {
        styleSegmentedControl(timeTypeSegmentedControl)
        setSegmentedControlOptions(timeTypeSegmentedControl, options: [leaveAtElement.title, arriveByElement.title])
        timeTypeSegmentedControl.selectedSegmentIndex = leaveAtElement.index
        timeTypeSegmentedControl.addTarget(self, action: #selector(timeTypeSegmentedControlValueChanged(segmentControl:)), for: .valueChanged)

        addSubview(timeTypeSegmentedControl)
    }

    private func setupLeaveNowSegmentedControl() {
        styleSegmentedControl(leaveNowSegmentedControl)
        setSegmentedControlOptions(leaveNowSegmentedControl, options: [leaveNowElement.title])
        leaveNowSegmentedControl.addTarget(self, action: #selector(leaveNowSegmentedControlValueChanged(segmentControl:)), for: .valueChanged)

        addSubview(leaveNowSegmentedControl)
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

    // MARK: Setters

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

    // MARK: Getters

    func getDate() -> Date {
        return datepicker.date
    }

    private func setupConstraints() {
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
            make.size.equalTo(cancelButton.intrinsicContentSize)
        }

        doneButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(spaceBtButtonAndSuperviewSide)
            make.top.equalToSuperview().inset(spaceBtButtonAndSuprviewTop)
            make.size.equalTo(doneButton.intrinsicContentSize)
        }

        timeTypeSegmentedControl.snp.makeConstraints { make in
            make.trailing.equalTo(doneButton)
            make.top.equalTo(doneButton.snp.bottom).offset(spaceBtButtonAndSegmentedControl)
            make.height.equalTo(segmentedControlHeight)
            make.leading.equalTo(leaveNowSegmentedControl.snp.trailing).offset(spaceBtSegmentControls)
        }

        leaveNowSegmentedControl.snp.makeConstraints { make in
            make.leading.equalTo(cancelButton)
            make.top.equalTo(timeTypeSegmentedControl)
            make.height.equalTo(segmentedControlHeight)
            make.width.equalTo(timeTypeSegmentedControl.snp.width).multipliedBy(segmentedControlSizeRatio)
        }

        datepicker.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(leaveNowSegmentedControl.snp.bottom).offset(spaceBtSegmentControlAndDatePicker)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }

    // MARK: Buttons

    @objc private func doneButtonPressed() {
        var searchTimeType: SearchType = .leaveNow
        switch leaveNowSegmentedControl.selectedSegmentIndex {
        case leaveNowElement.index:
            searchTimeType = .leaveNow
        case arriveByElement.index:
            searchTimeType = .arriveBy
        default:
            searchTimeType = .leaveAt
        }

        delegate?.saveDatePickerDate(for: getDate(), searchType: searchTimeType)
    }

    @objc private func cancelButtonPressed() {
        delegate?.dismissDatePicker()
    }

    // MARK: Segment Controls

    @objc private func timeTypeSegmentedControlValueChanged(segmentControl: UISegmentedControl) {
        if timeTypeSegmentedControl.selectedSegmentIndex == arriveByElement.index {
            leaveNowSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        }
    }

    @objc private func leaveNowSegmentedControlValueChanged(segmentControl: UISegmentedControl) {
        datepicker.date = Date()
    }

    // MARK: Datepicker

    @objc private func datepickerValueChanged(datepicker: UIDatePicker) {
        if Time.compare(date1: datepicker.date, date2: Date()) == ComparisonResult.orderedSame {
            leaveNowSegmentedControl.selectedSegmentIndex = leaveNowElement.index
            timeTypeSegmentedControl.selectedSegmentIndex = leaveAtElement.index
        } else {
            leaveNowSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        }
    }
}
