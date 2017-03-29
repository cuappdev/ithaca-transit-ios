//
//  RouteSelectionView.swift
//  TCAT
//
//  Created by Monica Ong on 3/5/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class RouteSelectionView: UIView {
    
    var fromToView: UIView!
    var fromLabel: UILabel!
    var toLabel: UILabel!
    var fromSearch: UITextField!
    var toSearch: UITextField!
    
    var timeButton: UIButton!
    
    let lineWidth: CGFloat = 1.0
    let leadingSpace: CGFloat = 17.5
    let topSpace: CGFloat = 21.5
    let btnLabelSpace: CGFloat = 16.0
    let searchTrailingSpace: CGFloat = 12.0
    let topBottomTimeSpace: CGFloat = 9.0
    let timeButtonHeight: CGFloat = 40.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fromLabel = UILabel(frame: CGRect(x: leadingSpace, y: 0, width: 40, height: 20))
        fromLabel.text = "From"
        fromLabel.sizeToFit()
        fromLabel.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        fromLabel.textColor = .black
        
        fromSearch = UITextField(frame: CGRect(x: fromLabel.frame.maxX + btnLabelSpace, y: topSpace, width: 277, height: 28))
        fromLabel.center.y = fromSearch.center.y
        fromSearch.backgroundColor = .yellow
        
        toLabel = UILabel(frame: CGRect(x: fromLabel.frame.minX, y: 0, width: 20, height: 20))
        toLabel.text = "To"
        toLabel.sizeToFit()
        toLabel.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        toLabel.textColor = .black
        
        toSearch = UITextField(frame: CGRect(x: toLabel.frame.maxX + btnLabelSpace, y: fromSearch.frame.maxY + leadingSpace, width: 277, height: 28))
        toLabel.center.y = toSearch.center.y
        toSearch.backgroundColor = .yellow
        
        timeButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: timeButtonHeight))
        timeButton.setImage(#imageLiteral(resourceName: "clock"), for: .normal)
        timeButton.contentMode = .scaleAspectFit
        timeButton.tintColor = .mediumGrayColor
        timeButton.setTitle("Leave now", for: .normal)
        timeButton.setTitleColor(.mediumGrayColor, for: .normal)
        timeButton.titleLabel?.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        timeButton.backgroundColor = .optionsTimeBackgroundColor
        timeButton.contentHorizontalAlignment = .left
        timeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: leadingSpace, bottom: 0, right: 0)
        timeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: leadingSpace*1.5, bottom: 0, right: 0)
        
    }
    
    func positionAndAddViews(){
        //Position views
        fromToView = UIView(frame: CGRect(x: 0, y: lineWidth, width: self.frame.width, height: topSpace + fromSearch.frame.height + leadingSpace + toSearch.frame.height + (3*topSpace/4)))
        fromToView.backgroundColor = .white
        
        timeButton.frame = CGRect(x: 0,  y: fromToView.frame.maxY + lineWidth, width: self.frame.width, height: timeButtonHeight)
        
        //Change width of search fields
        var fromSearchFrame = fromSearch.frame
        fromSearchFrame.size.width = self.frame.width - fromSearch.frame.minX - searchTrailingSpace
        fromSearch.frame = fromSearchFrame
        
        toSearch.frame = CGRect(x: fromSearch.frame.minX, y: fromSearch.frame.maxY + topSpace, width: fromSearch.frame.width, height: fromSearch.frame.height)
        
        //Add views as subviews
        addSubview(fromToView)
        fromToView.addSubview(fromSearch)
        fromToView.addSubview(fromLabel)
        fromToView.addSubview(toSearch)
        fromToView.addSubview(toLabel)
        addSubview(timeButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
