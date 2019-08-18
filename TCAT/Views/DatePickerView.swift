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

protocol DatePickerViewDelegate {
    func dismissDatePicker()
    func saveDatePickerDate(for date: Date, searchType: SearchType)
}

class DatePickerView: UIView {

    // MARK: Data vars

    var delegate: DatePickerViewDelegate?
    let leaveNowSegmentedControlOptions: [String]
    let typeToSegmentControlElements: [SearchType: SegmentControlElement] = [
        .leaveNow: SegmentControlElement(title: Constants.General.datepickerLeaveNow, index: 0),
        .leaveAt: SegmentControlElement(title: "Leave At", index: 0),
        .arriveBy: SegmentControlElement(title: "Arrive By", index: 1)]
    let timeTypeSegmentedControlOptions: [String]

    // MARK: View vars

    var cancelButton: UIButton = UIButton()
    var datepicker: UIDatePicker = UIDatePicker()
    var doneButton: UIButton = UIButton()
    var leaveNowSegmentedControl: UISegmentedControl = UISegmentedControl()
    var timeTypeSegmentedControl: UISegmentedControl = UISegmentedControl()

    // MARK: Spacing vars

    let buttonHeight: CGFloat = 20
    let datePickerHeight: CGFloat = 164.5
    let labelHeight: CGFloat = 28
    let segmentedControlHeight: CGFloat = 29

    let spaceBtButtonAndSegmentedControl: CGFloat = 16.0
    let spaceBtButtonAndSuperviewSide: CGFloat = 12.0
    let spaceBtButtonAndSuprviewTop: CGFloat = 16.0
    let spaceBtSegmentControlAndDatePicker: CGFloat = 8.0
    let spaceBtSegmentControls: CGFloat = 8.0

    // MARK: Init

    override init(frame: CGRect) {
        leaveNowSegmentedControlOptions = [typeToSegmentControlElements[.leaveNow]!.title]
        timeTypeSegmentedControlOptions = [typeToSegmentControlElements[.leaveAt]!.title, typeToSegmentControlElements[.arriveBy]!.title]

        super.init(frame: frame)

        backgroundColor = Colors.white

        styleDatepicker()
        styleSegmentedControl(timeTypeSegmentedControl)
        styleSegmentedControl(leaveNowSegmentedControl)
        styleCancelButton()
        styleDoneButton()

        setDatepickerSettings()

        setSegmentedControl(timeTypeSegmentedControl, withItems: timeTypeSegmentedControlOptions)
        timeTypeSegmentedControl.selectedSegmentIndex = typeToSegmentControlElements[.leaveAt]!.index
        timeTypeSegmentedControl.addTarget(self, action: #selector(timeTypeSegmentedControlValueChanged(segmentControl:)), for: .valueChanged)

        setSegmentedControl(leaveNowSegmentedControl, withItems: leaveNowSegmentedControlOptions)
        leaveNowSegmentedControl.addTarget(self, action: #selector(leaveNowSegmentedControlValueChanged(segmentControl:)), for: .valueChanged)

        setCancelButton(withTitle: Constants.Buttons.cancel)
        setDoneButton(withTitle: Constants.Buttons.done)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Segement Control

    @objc private func timeTypeSegmentedControlValueChanged(segmentControl: UISegmentedControl) {
        if timeTypeSegmentedControl.selectedSegmentIndex == typeToSegmentControlElements[.arriveBy]!.index {
            leaveNowSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        }
    }

    @objc private func leaveNowSegmentedControlValueChanged(segmentControl: UISegmentedControl) {
        datepicker.date = Date()
    }

    // MARK: Datepicker

    @objc private func datepickerValueChanged(datepicker: UIDatePicker) {
        if Time.compare(date1: datepicker.date, date2: Date()) == ComparisonResult.orderedSame {
            leaveNowSegmentedControl.selectedSegmentIndex = typeToSegmentControlElements[.leaveNow]!.index
        } else {
            leaveNowSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        }
    }

    // MARK: Setters

    func setDatepickerDate(date: Date) {
        datepicker.date = date
        datepickerValueChanged(datepicker: datepicker)
    }

    func setDatepickerTimeType(searchTimeType: SearchType) {
        switch searchTimeType {
        case .leaveAt, .leaveNow:
            timeTypeSegmentedControl.selectedSegmentIndex = typeToSegmentControlElements[.leaveAt]!.index
        case .arriveBy:
            timeTypeSegmentedControl.selectedSegmentIndex = typeToSegmentControlElements[.arriveBy]!.index
        }
    }

    // MARK: Getters
    func getDate() -> Date {
        return datepicker.date
    }

    // MARK: Style

    private func styleDatepicker() {
        datepicker.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: datePickerHeight)
    }

    private func styleSegmentedControl(_ segmentedControl: UISegmentedControl) {
        segmentedControl.tintColor = Colors.tcatBlue
        segmentedControl.setTitleTextAttributes(
            [.font: UIFont.getFont(.regular, size: 13.0)],
            for: .normal)
    }

    private func styleCancelButton() {
        cancelButton.frame = CGRect(x: 0, y: 0, width: 60, height: buttonHeight)
        cancelButton.titleLabel?.font = .getFont(.regular, size: 17.0)
        cancelButton.setTitleColor(Colors.metadataIcon, for: .normal)
    }

    private func styleDoneButton() {
        doneButton.frame = CGRect(x: 0, y: 0, width: 55, height: buttonHeight)
        doneButton.titleLabel?.font = .getFont(.regular, size: 17.0)
        doneButton.setTitleColor(Colors.tcatBlue, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
    }

    // MARK: Set data

    private func setDatepickerSettings() {
        let now = Date()
        datepicker.minimumDate = now

        let next7Days = now.addingTimeInterval(7*24*60*60)
        datepicker.maximumDate = next7Days //set maximum date to 7 days from now

        datepicker.addTarget(self, action: #selector(datepickerValueChanged(datepicker:)), for: .valueChanged)
    }

    private func setSegmentedControl(_ segmentedContol: UISegmentedControl, withItems titles: [String]) {
        for i in titles.indices {
            segmentedContol.insertSegment(withTitle: titles[i], at: i, animated: false)
        }
    }

    private func setCancelButton(withTitle title: String) {
        cancelButton.setTitle(title, for: .normal)
    }

    private func setDoneButton(withTitle title: String) {
        doneButton.setTitle(title, for: .normal)
    }

    // MARK: Position

    func positionSubviews() {
        positionCancelButton()
        positionDoneButton()
        positionTimeTypeSegmentedControl(usingCancelButton: cancelButton)
        positionLeaveNowSegmentedControl(usingTimeTypeSegmentedControl: timeTypeSegmentedControl)
        positionDatepicker(usingSegmentedControl: timeTypeSegmentedControl)
     }

    private func positionCancelButton() {
        let oldFrame = cancelButton.frame
        let newFrame = CGRect(x: spaceBtButtonAndSuperviewSide, y: spaceBtButtonAndSuprviewTop, width: oldFrame.width, height: oldFrame.height)

        cancelButton.frame = newFrame
    }

    private func positionDoneButton() {
        let oldFrame = doneButton.frame
        let newFrame = CGRect(x: self.frame.width - spaceBtButtonAndSuperviewSide - oldFrame.width, y: spaceBtButtonAndSuprviewTop, width: oldFrame.width, height: oldFrame.height)

        doneButton.frame = newFrame
    }

    private func positionTimeTypeSegmentedControl(usingCancelButton cancelButton: UIButton) {
        timeTypeSegmentedControl.frame = CGRect(x: 0, y: cancelButton.frame.maxY + spaceBtButtonAndSegmentedControl, width: (self.frame.width*(343/375) - spaceBtSegmentControls)*(2/3), height: segmentedControlHeight)

        timeTypeSegmentedControl.center.x = self.frame.width/2 + timeTypeSegmentedControl.frame.width/4 + spaceBtSegmentControls/2
    }

    private func positionLeaveNowSegmentedControl(usingTimeTypeSegmentedControl timeTypeSegmentedControl: UISegmentedControl) {
        let width = (self.frame.width*(343/375) - spaceBtSegmentControls)*(1/3)
        leaveNowSegmentedControl.frame = CGRect(x: timeTypeSegmentedControl.frame.minX - spaceBtSegmentControls - width, y: timeTypeSegmentedControl.frame.minY, width: width, height: segmentedControlHeight)
    }

    private func positionDatepicker(usingSegmentedControl segmentedControl: UISegmentedControl) {
        let oldFrame = datepicker.frame
        let newFrame = CGRect(x: 0, y: segmentedControl.frame.maxY + spaceBtSegmentControlAndDatePicker, width: oldFrame.width, height: oldFrame.height)

        datepicker.frame = newFrame

        datepicker.center.x = self.frame.width/2
    }

    // MARK: Add subviews

    func addSubviews() {
        addSubview(cancelButton)
        addSubview(doneButton)
        addSubview(timeTypeSegmentedControl)
        addSubview(leaveNowSegmentedControl)
        addSubview(datepicker)
    }

    @objc private func doneButtonPressed() {
        var searchTimeType: SearchType = .leaveNow
        switch leaveNowSegmentedControl.selectedSegmentIndex {
        case typeToSegmentControlElements[.leaveNow]!.index:
            searchTimeType = .leaveNow
        case typeToSegmentControlElements[.arriveBy]!.index:
            searchTimeType = .arriveBy
        default:
            searchTimeType = .leaveAt
        }

        delegate?.saveDatePickerDate(for: getDate(), searchType: searchTimeType)
    }

    @objc private func cancelButtonPressed() {
        delegate?.dismissDatePicker()
    }

}
