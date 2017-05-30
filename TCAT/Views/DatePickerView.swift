//
//  DatePickerView.swift
//  TCAT
//
//  Created by Monica Ong on 3/14/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class DatePickerView: UIView {

    var cancelButton: UIButton!
    var doneButton: UIButton!
    var datePicker: UIDatePicker!
    var arriveDepartBar: UISegmentedControl!
    let arriveDepartOptions: [String] = ["Arrive By", "Leave At"]
    var disclaimerLabel: UILabel!
    
    let buttonHeight: CGFloat = 20
    let segmentControlHeight: CGFloat = 29
    let datePickerHeight: CGFloat = 164.5
    let labelHeight: CGFloat = 28
    
    let spaceBtButtonAndSuprviewTop: CGFloat = 16.0
    let spaceBtButtonAndSuperviewSide: CGFloat = 12.0
    let spaceBtButtonAndSegmentedControl: CGFloat = 16.0
    let spaceBtSegmentControlAndDatePicker: CGFloat = 8.0
    
    override init(frame: CGRect){
        super.init(frame: frame)
        arriveDepartBar = UISegmentedControl(items: arriveDepartOptions)
        arriveDepartBar.tintColor = .tcatBlueColor
        arriveDepartBar.selectedSegmentIndex = 1
        let segmentControlFont = UIFont(name: "SFUIText-Regular", size: 13.0)
        arriveDepartBar.setTitleTextAttributes([NSFontAttributeName: segmentControlFont!], for: .normal)
        
        datePicker = UIDatePicker()
        let now = Date()
        datePicker.minimumDate = now //set minimum date now
        let next6Days = now.addingTimeInterval(6*24*60*60)
        datePicker.maximumDate = next6Days //set maximum date to 6 days from now
        datePicker.minuteInterval = 5 //time increments by 5 mins
        
        cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "SFUIText-Regular", size: 17.0)
        cancelButton.setTitleColor(.mediumGrayColor, for: .normal)
        
        doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = UIFont(name: "SFUIText-Regular", size: 17.0)
        doneButton.setTitleColor(.tcatBlueColor, for: .normal)
        
        disclaimerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width*(343/375), height: labelHeight))
        disclaimerLabel.textColor = .mediumGrayColor
        disclaimerLabel.font = UIFont(name: "SFUIText-Regular", size: 12.0)
        disclaimerLabel.text = "Results are shown for buses departing up to 30 minutes after the selected time"
        disclaimerLabel.numberOfLines = 0
        disclaimerLabel.lineBreakMode = .byWordWrapping
        disclaimerLabel.textAlignment = .center
        disclaimerLabel.sizeToFit()
    }
    
    func positionAndAddViews(){
        cancelButton.frame = CGRect(x: spaceBtButtonAndSuperviewSide, y: spaceBtButtonAndSuprviewTop, width: 60, height: buttonHeight)
        
        doneButton.frame = CGRect(x: 0, y: spaceBtButtonAndSuprviewTop, width: 55, height: buttonHeight)
        let newFrame = CGRect(x: self.frame.width - spaceBtButtonAndSuperviewSide - doneButton.frame.width, y: doneButton.frame.minY, width: doneButton.frame.width, height: doneButton.frame.height)
        doneButton.frame = newFrame
        
        arriveDepartBar.frame = CGRect(x: 0, y: cancelButton.frame.maxY + spaceBtButtonAndSegmentedControl, width: self.frame.width*(343/375), height: segmentControlHeight)
        arriveDepartBar.center.x = self.frame.width/2
        
        datePicker.frame = CGRect(x: 0, y: arriveDepartBar.frame.maxY + spaceBtSegmentControlAndDatePicker, width: self.frame.width, height: datePickerHeight)
        datePicker.center.x = self.frame.width/2

        disclaimerLabel.center.x = self.frame.width/2
        disclaimerLabel.center.y = datePicker.frame.maxY + (self.frame.height - datePicker.frame.maxY)/2
        
        //Add views
        addSubview(cancelButton)
        addSubview(doneButton)
        addSubview(arriveDepartBar)
        addSubview(datePicker)
        addSubview(disclaimerLabel)
     }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
