//
//  DatepickerView.swift
//  TCAT
//
//  Created by Monica Ong on 3/14/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class DatepickerView: UIView {

    // MARK:  View vars
    
    var datepicker: UIDatePicker = UIDatePicker()
    var leaveNowSegmentedControl: UISegmentedControl = UISegmentedControl()
    let leaveNowSegmentedControlOptions: [String] = ["Leave Now"]
    var timeTypeSegmentedControl: UISegmentedControl = UISegmentedControl()
    let timeTypeSegmentedControlOptions: [String] = ["Leave At", "Arrive By"]
    var cancelButton: UIButton = UIButton()
    var doneButton: UIButton = UIButton()
    var disclaimerLabel: UILabel = UILabel()
    
    // MARK: Spacing vars
    
    let buttonHeight: CGFloat = 20
    let segmentedControlHeight: CGFloat = 29
    let datePickerHeight: CGFloat = 164.5
    let labelHeight: CGFloat = 28
    
    let spaceBtButtonAndSuprviewTop: CGFloat = 16.0
    let spaceBtButtonAndSuperviewSide: CGFloat = 12.0
    let spaceBtButtonAndSegmentedControl: CGFloat = 16.0
    let spaceBtSegmentControlAndDatePicker: CGFloat = 8.0
    let spaceBtSegmentControls: CGFloat = 8.0
    
    // MARK: Init
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        styleDatepicker()
        styleSegmentedControl(timeTypeSegmentedControl)
        styleSegmentedControl(leaveNowSegmentedControl)
        styleCancelButton()
        styleDoneButton()
//        styleDisclaimerLabel()

        setDatepickerSettings()
        
        setSegmentedControl(timeTypeSegmentedControl, withItems: timeTypeSegmentedControlOptions)
        let leaveAt = 0
        timeTypeSegmentedControl.selectedSegmentIndex = leaveAt
        
        setSegmentedControl(leaveNowSegmentedControl, withItems: leaveNowSegmentedControlOptions)
        leaveNowSegmentedControl.addTarget(self, action: #selector(leaveNowSegmentedControlValueChanged(segmentControl:)), for: .valueChanged)

        setCancelButton(withTitle: "Cancel")
        setDoneButton(withTitle: "Done")
//        setDisclaimerLabel(withText: "Results are shown for buses departing up to 30 minutes after the selected time")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Segement Control
    
    @objc func leaveNowSegmentedControlValueChanged(segmentControl: UISegmentedControl) {
        datepicker.date = Date()
    }
    
    // MARK: Datepicker
    
    @objc func datepickerValueChanged(datepicker: UIDatePicker) {
        let now = Date()
        if Time.compare(date1: datepicker.date, date2: now) == ComparisonResult.orderedSame {
            let leaveNow = 0
            leaveNowSegmentedControl.selectedSegmentIndex = leaveNow
        } else {
            leaveNowSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
        }
    }
    
    // MARK: Setters
    
    func setDatepickerDate(date: Date) {
        datepicker.date = date
        datepickerValueChanged(datepicker: datepicker)
    }
    
    func setDatepickerTimeType(searchTimeType: SearchType) {
        switch searchTimeType {
        case .leaveAt:
            timeTypeSegmentedControl.selectedSegmentIndex = 0
        case .arriveBy:
            timeTypeSegmentedControl.selectedSegmentIndex = 1
        }
    }
    
    // MARK: Style
    
    private func styleDatepicker(){
        datepicker.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: datePickerHeight)
    }
    
    private func styleSegmentedControl(_ segmentedControl: UISegmentedControl){
        segmentedControl.tintColor = .tcatBlueColor
        let segmentControlFont = UIFont(name: FontNames.SanFrancisco.Regular, size: 13.0)
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: segmentControlFont!], for: .normal)
    }
    
    private func styleCancelButton(){
        cancelButton.frame = CGRect(x: 0, y: 0, width: 60, height: buttonHeight)
        cancelButton.titleLabel?.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 17.0)
        cancelButton.setTitleColor(.mediumGrayColor, for: .normal)
    }
    
    private func styleDoneButton(){
        doneButton.frame = CGRect(x: 0, y: 0, width: 55, height: buttonHeight)
        doneButton.titleLabel?.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 17.0)
        doneButton.setTitleColor(.tcatBlueColor, for: .normal)
    }
    
    private func styleDisclaimerLabel(){
        disclaimerLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width*(343/375), height: labelHeight)
        disclaimerLabel.textColor = .mediumGrayColor
        disclaimerLabel.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 12.0)
        disclaimerLabel.numberOfLines = 0
        disclaimerLabel.lineBreakMode = .byWordWrapping
        disclaimerLabel.textAlignment = .center
    }
    
    // MARK: Set data
    
    private func setDatepickerSettings(){
        let now = Date()
        datepicker.minimumDate = now
        
        let next7Days = now.addingTimeInterval(7*24*60*60)
        datepicker.maximumDate = next7Days //set maximum date to 7 days from now
        
        datepicker.addTarget(self, action: #selector(datepickerValueChanged(datepicker:)), for: .valueChanged)
    }
    
    private func setSegmentedControl(_ segmentedContol: UISegmentedControl, withItems titles: [String]){
        for i in titles.indices {
            segmentedContol.insertSegment(withTitle: titles[i], at: i, animated: false)
        }
    }
    
    private func setCancelButton(withTitle title: String){
        cancelButton.setTitle(title, for: .normal)
    }
    
    private func setDoneButton(withTitle title: String){
        doneButton.setTitle(title, for: .normal)
    }
    
    private func setDisclaimerLabel(withText text: String){
        disclaimerLabel.text = text
        disclaimerLabel.sizeToFit()
    }
    
    // MARK: Position
    
    func positionSubviews(){
        positionCancelButton()
        positionDoneButton()
        positionTimeTypeSegmentedControl(usingCancelButton: cancelButton)
        positionLeaveNowSegmentedControl(usingTimeTypeSegmentedControl: timeTypeSegmentedControl)
        positionDatepicker(usingSegmentedControl: timeTypeSegmentedControl)
        positionDisclaimerLabel(usingDatepicker: datepicker)
     }
    
    private func positionCancelButton(){
        let oldFrame = cancelButton.frame
        let newFrame = CGRect(x: spaceBtButtonAndSuperviewSide, y: spaceBtButtonAndSuprviewTop, width: oldFrame.width, height: oldFrame.height)
        
        cancelButton.frame = newFrame
    }
    
    private func positionDoneButton(){
        let oldFrame = doneButton.frame
        let newFrame = CGRect(x: self.frame.width - spaceBtButtonAndSuperviewSide - oldFrame.width, y: spaceBtButtonAndSuprviewTop, width: oldFrame.width, height: oldFrame.height)
        
        doneButton.frame = newFrame
    }
    
    private func positionTimeTypeSegmentedControl(usingCancelButton cancelButton: UIButton){
        timeTypeSegmentedControl.frame = CGRect(x: 0, y: cancelButton.frame.maxY + spaceBtButtonAndSegmentedControl, width: (self.frame.width*(343/375) - spaceBtSegmentControls)*(2/3), height: segmentedControlHeight)
        
        timeTypeSegmentedControl.center.x = self.frame.width/2 + timeTypeSegmentedControl.frame.width/4 + spaceBtSegmentControls/2
    }
    
    private func positionLeaveNowSegmentedControl(usingTimeTypeSegmentedControl timeTypeSegmentedControl: UISegmentedControl) {
        let width = (self.frame.width*(343/375) - spaceBtSegmentControls)*(1/3)
        leaveNowSegmentedControl.frame = CGRect(x: timeTypeSegmentedControl.frame.minX - spaceBtSegmentControls - width, y: timeTypeSegmentedControl.frame.minY, width: width, height: segmentedControlHeight)
    }
    
    private func positionDatepicker(usingSegmentedControl segmentedControl: UISegmentedControl){
        let oldFrame = datepicker.frame
        let newFrame = CGRect(x: 0, y: segmentedControl.frame.maxY + spaceBtSegmentControlAndDatePicker, width: oldFrame.width, height: oldFrame.height)
        
        datepicker.frame = newFrame
        
        datepicker.center.x = self.frame.width/2
    }
    
    private func positionDisclaimerLabel(usingDatepicker datepicker: UIDatePicker){
        disclaimerLabel.center.x = self.frame.width/2
        disclaimerLabel.center.y = datepicker.frame.maxY + (self.frame.height - datepicker.frame.maxY)/2
    }
    
    // MARK:  Add subviews
    
    func addSubviews(){
        addSubview(cancelButton)
        addSubview(doneButton)
        addSubview(timeTypeSegmentedControl)
        addSubview(leaveNowSegmentedControl)
        addSubview(datepicker)
//        addSubview(disclaimerLabel)
    }

}
