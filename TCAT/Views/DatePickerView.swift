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
    let arriveDepartOptions: [String] = ["Depart at", "Arrive by"]
    
    let leadingSpace: CGFloat = 17.5
    let topSpace: CGFloat = 29.0
    let spaceBtSegmentControlAndDatePicker: CGFloat = 8.0
    
    override init(frame: CGRect){
        super.init(frame: frame)
        arriveDepartBar = UISegmentedControl(items: arriveDepartOptions)
        arriveDepartBar.frame = CGRect(x: 30, y: topSpace, width: self.frame.width*(2/3), height: 23)
        arriveDepartBar.tintColor = .tcatBlue
        arriveDepartBar.selectedSegmentIndex = 0 //Depart at default option
        
        datePicker = UIDatePicker()
        
        cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        cancelButton.setTitleColor(.timeIconColor, for: .normal)
        
        doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        doneButton.setTitleColor(.tcatBlue, for: .normal)
    }
    
    
    func positionAndAddViews(){
        arriveDepartBar.center.x = self.frame.width/2
        datePicker.frame = CGRect(x: 0, y: arriveDepartBar.frame.maxY + spaceBtSegmentControlAndDatePicker, width: self.frame.width, height: 172)
        cancelButton.frame = CGRect(x: 0, y: datePicker.frame.maxY, width: self.frame.width/2, height: 55)
        doneButton.frame = CGRect(x: cancelButton.frame.maxX, y: cancelButton.frame.minY, width: self.frame.width/2, height: cancelButton.frame.height)
        
        //Add views
        addSubview(arriveDepartBar)
        addSubview(datePicker)
        addSubview(cancelButton)
        addSubview(doneButton)
     }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
