//
//  RouteSelectionView.swift
//  TCAT
//
//  Created by Monica Ong on 3/5/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class RouteSelectionView: UIView {
    
    var searchBar: SearchBarView!

    var fromToView: UIView!
    var fromLabel: UILabel!
    var toLabel: UILabel!
    var fromSearch: UIButton!
    var toSearch: UIButton!
    var busPath: CircleLine!
    var swapButton: UIButton!
    
    var timeButton: UIButton!
    
    let lineWidth: CGFloat = 1.0
    let leadingSpace: CGFloat = 16.0
    let topSpace: CGFloat = 21.5
    let busPathLeftSpace: CGFloat = 13.0
    let busPathRightSpace: CGFloat = 16.0
    let btnLabelSpace: CGFloat = 16.0
    let searchTextSpaceFromLeft: CGFloat = 12.0
    let searchHeight: CGFloat = 28
    let spaceBtSearchBtns: CGFloat = 12.0
    let swapPadding: CGFloat = 16.0
    let topBottomTimeSpace: CGFloat = 9.0
    let timeButtonHeight: CGFloat = 40.0
    let timeImageWidth: CGFloat = 1.5
    let timeTitleLeadingSpace: CGFloat = 12.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        fromLabel = UILabel(frame: CGRect(x: leadingSpace, y: 0, width: 40, height: 20))
        fromLabel.text = "From"
        fromLabel.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        fromLabel.textColor = .black
        fromLabel.sizeToFit()
        
        fromSearch = UIButton(frame: CGRect(x: btnLabelSpace, y: topSpace, width: 243, height: searchHeight))
        fromSearch.backgroundColor = .tableBackgroundColor
        fromSearch.setTitleColor(.primaryTextColor, for: .normal)
        fromSearch.titleLabel?.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        fromSearch.contentHorizontalAlignment = .left
        fromSearch.contentEdgeInsets = UIEdgeInsetsMake(0, searchTextSpaceFromLeft, 0, 0)
        fromSearch.layer.cornerRadius = searchHeight/4
        fromSearch.layer.masksToBounds = true
        fromLabel.center.y = fromSearch.center.y
        
        busPath = CircleLine(color: .mediumGrayColor, frame: CGRect(x: fromLabel.frame.maxX + busPathLeftSpace, y: fromLabel.frame.midY - 4, width: 16, height: 52))
        fromSearch.frame = CGRect(x: busPath.frame.maxX + busPathRightSpace, y: topSpace, width: 243, height: searchHeight)
        
        toLabel = UILabel(frame: CGRect(x: fromLabel.frame.minX, y: 0, width: 20, height: 20))
        toLabel.text = "To"
        toLabel.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        toLabel.textColor = .black
        toLabel.sizeToFit()
        
        toSearch = UIButton(frame: CGRect(x: toLabel.frame.maxX + btnLabelSpace, y: fromSearch.frame.maxY + leadingSpace, width: fromSearch.frame.width, height: fromSearch.frame.height))
        toSearch.backgroundColor = .tableBackgroundColor
        toSearch.setTitleColor(.primaryTextColor, for: .normal)
        toSearch.titleLabel?.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        toSearch.contentHorizontalAlignment = .left
        toSearch.contentEdgeInsets = UIEdgeInsetsMake(0, searchTextSpaceFromLeft, 0, 0)
        toSearch.layer.cornerRadius = fromSearch.layer.cornerRadius
        toSearch.layer.masksToBounds = true
        
        swapButton = UIButton(frame: CGRect(x: 0, y: 0, width: 14, height: 18))
        swapButton.setImage(UIImage(named: "swap"), for: .normal)
        swapButton.imageView?.contentMode = .scaleAspectFit
        
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
        timeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: leadingSpace + timeImageWidth + timeTitleLeadingSpace, bottom: 0, right: 0)
    }
    
    func positionAndAddViews(){
        //Position views
        fromToView = UIView(frame: CGRect(x: 0, y: lineWidth, width: self.frame.width, height: topSpace + fromSearch.frame.height + leadingSpace + toSearch.frame.height + (3*topSpace/4)))
        fromToView.backgroundColor = .white
        
        timeButton.frame = CGRect(x: 0,  y: fromToView.frame.maxY + lineWidth, width: self.frame.width, height: timeButtonHeight)
        
        //Change width of search fields
        var fromSearchFrame = fromSearch.frame
        fromSearchFrame.size.width = self.frame.width - fromSearch.frame.minX - swapButton.frame.width - 2*swapPadding
        fromSearch.frame = fromSearchFrame
        
        swapButton.frame = CGRect(x: fromSearch.frame.maxX + swapPadding, y: 0, width: 14, height: 18)
        swapButton.center.y = busPath.center.y
        
        toSearch.frame = CGRect(x: fromSearch.frame.minX, y: fromSearch.frame.maxY + spaceBtSearchBtns, width: fromSearch.frame.width, height: fromSearch.frame.height)
        toLabel.center.y = toSearch.center.y //recenter tolabel after change toSearch's frame

        //Add views as subviews
        addSubview(fromToView)
        fromToView.addSubview(fromSearch)
        fromToView.addSubview(fromLabel)
        fromToView.addSubview(busPath)
        fromToView.addSubview(swapButton)
        fromToView.addSubview(toSearch)
        fromToView.addSubview(toLabel)
        addSubview(timeButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
