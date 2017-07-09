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
    var segmentedControl: UISegmentedControl = UISegmentedControl()
    let segmentedControlOptions: [String] = ["Arrive By", "Leave At"]
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
    
    // MARK: Init
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        styleDatepicker()
        styleSegmentedControl()
        styleCancelButton()
        styleDoneButton()
        styleDisclaimerLabel()

        setDatepickerSettings()
        setSegmentedControl(withItems: segmentedControlOptions)
        setCancelButton(withTitle: "Cancel")
        setDoneButton(withTitle: "Done")
        setDisclaimerLabel(withText: "Results are shown for buses departing up to 30 minutes after the selected time")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Style
    
    private func styleDatepicker(){
        datepicker.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: datePickerHeight)
    }
    
    private func styleSegmentedControl(){
        segmentedControl.frame = CGRect(x: 0, y: 0, width: self.frame.width*(343/375), height: segmentedControlHeight)
        segmentedControl.tintColor = .tcatBlueColor
        let segmentControlFont = UIFont(name: "SFUIText-Regular", size: 13.0)
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: segmentControlFont!], for: .normal)
    }
    
    private func styleCancelButton(){
        cancelButton.frame = CGRect(x: 0, y: 0, width: 60, height: buttonHeight)
        cancelButton.titleLabel?.font = UIFont(name: "SFUIText-Regular", size: 17.0)
        cancelButton.setTitleColor(.mediumGrayColor, for: .normal)
    }
    
    private func styleDoneButton(){
        doneButton.frame = CGRect(x: 0, y: 0, width: 55, height: buttonHeight)
        doneButton.titleLabel?.font = UIFont(name: "SFUIText-Regular", size: 17.0)
        doneButton.setTitleColor(.tcatBlueColor, for: .normal)
    }
    
    private func styleDisclaimerLabel(){
        disclaimerLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width*(343/375), height: labelHeight)
        disclaimerLabel.textColor = .mediumGrayColor
        disclaimerLabel.font = UIFont(name: "SFUIText-Regular", size: 12.0)
        disclaimerLabel.numberOfLines = 0
        disclaimerLabel.lineBreakMode = .byWordWrapping
        disclaimerLabel.textAlignment = .center
    }
    
    // MARK: Set data
    
    private func setDatepickerSettings(){
        let now = Date()
        datepicker.minimumDate = now
        
        let next6Days = now.addingTimeInterval(6*24*60*60)
        datepicker.maximumDate = next6Days //set maximum date to 6 days from now
        
        datepicker.minuteInterval = 5
    }
    
    private func setSegmentedControl(withItems titles: [String]){
        for i in 0...titles.count - 1{
            segmentedControl.insertSegment(withTitle: titles[i], at: i, animated: false)
        }
        segmentedControl.selectedSegmentIndex = 1
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
        positionSegmentedControl(usingCancelButton: cancelButton)
        positionDatepicker(usingSegmentedControl: segmentedControl)
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
    
    private func positionSegmentedControl(usingCancelButton cancelButton: UIButton){
        let oldFrame = segmentedControl.frame
        let newFrame = CGRect(x: 0, y: cancelButton.frame.maxY + spaceBtButtonAndSegmentedControl, width: oldFrame.width, height: oldFrame.height)
        
        segmentedControl.frame = newFrame
        
        segmentedControl.center.x = self.frame.width/2
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
        addSubview(segmentedControl)
        addSubview(datepicker)
        addSubview(disclaimerLabel)
    }

}
