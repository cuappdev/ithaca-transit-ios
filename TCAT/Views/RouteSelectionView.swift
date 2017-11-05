//
//  RouteSelectionView.swift
//  TCAT
//
//  Created by Monica Ong on 3/5/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class RouteSelectionView: UIView {

    // MARK: View vars
    
    var searcbarView: UIView = UIView()
    var fromLabel: UILabel = UILabel()
    var toLabel: UILabel = UILabel()
    var fromSearchbar: UIButton = UIButton()
    var toSearchbar: UIButton = UIButton()
    var routeLine: CircleLine!
    var swapButton: UIButton = UIButton()
    var datepickerButton: UIButton = UIButton()
    var bottomLine: UIView = UIView()
    
    // MARK: Spacing vars
    
    let lineWidth: CGFloat = 1.0
    let leadingSpace: CGFloat = 16.0
    let topSpace: CGFloat = 21.5
    let routeLineLeftSpace: CGFloat = 11.0
    let routeLineRightSpace: CGFloat = 14.0
    let searchbarTextSpaceFromLeft: CGFloat = 12.0
    let searchbarHeight: CGFloat = 28
    let swapPadding: CGFloat = 16.0
    let datepickerButtonHeight: CGFloat = 40.0
    let datepickerImageWidth: CGFloat = 1.5
    let datepickerTitleLeadingSpace: CGFloat = 12.0
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        styleSearchbarView()
        styleLabel(fromLabel)
        styleSearchbar(fromSearchbar)
        styleLabel(toLabel)
        styleSearchbar(toSearchbar)
        styleRouteLine()
        styleSwapButton()
        styleDatepickerButton()
        styleBottomLine()
        
        setLabel(fromLabel, withText: "From")
        setLabel(toLabel, withText: "To")
        setSwapButton(withImage: #imageLiteral(resourceName: "swap"))
        setDatpickerButton(withImage: #imageLiteral(resourceName: "clock"))
        setDatepickerButton(withTitle: "Leave now")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Style
    
    private func styleSearchbarView(){
        searcbarView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 103)
        searcbarView.backgroundColor = .white
    }
    
    private func styleLabel(_ label: UILabel){
        fromLabel.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        label.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 14.0)
        label.textColor = .black
    }
    
    private func styleSearchbar(_ searchbar: UIButton){
        searchbar.frame = CGRect(x: 0, y: 0, width: 243, height: searchbarHeight)
        searchbar.backgroundColor = .tableBackgroundColor
        searchbar.setTitleColor(.primaryTextColor, for: .normal)
        searchbar.titleLabel?.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 14.0)
        searchbar.contentHorizontalAlignment = .left
        searchbar.contentEdgeInsets = UIEdgeInsetsMake(0, searchbarTextSpaceFromLeft, 0, 0)
        searchbar.layer.cornerRadius = searchbarHeight/4
        searchbar.layer.masksToBounds = true
    }
    
    private func styleRouteLine(){
        routeLine = CircleLine(color: .mediumGrayColor)
    }
    
    private func styleSwapButton(){
        swapButton.frame = CGRect(x: 0, y: 0, width: 20, height: 25)
        swapButton.imageView?.contentMode = .scaleAspectFit
    }
    
    private func styleDatepickerButton(){
        datepickerButton.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: datepickerButtonHeight)
        
        datepickerButton.contentMode = .scaleAspectFit
        
        datepickerButton.tintColor = .mediumGrayColor
        datepickerButton.setTitleColor(.mediumGrayColor, for: .normal)
        datepickerButton.titleLabel?.font = UIFont(name: FontNames.SanFrancisco.Regular, size: 14.0)
        
        datepickerButton.backgroundColor = .optionsTimeBackgroundColor
        
        datepickerButton.contentHorizontalAlignment = .left
        datepickerButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: leadingSpace, bottom: 0, right: 0)
        datepickerButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: leadingSpace + datepickerImageWidth + datepickerTitleLeadingSpace, bottom: 0, right: 0)
    }
    
    private func styleBottomLine(){
        bottomLine.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: lineWidth)
        bottomLine.backgroundColor = .lineColor
    }
        
    // MARK: Set data
    
    private func setLabel(_ label: UILabel, withText text: String){
        label.text = text
        label.sizeToFit()
    }
    
    private func setSwapButton(withImage image: UIImage){
        swapButton.setImage(image, for: .normal)
    }
    
    private func setDatpickerButton(withImage image: UIImage){
        datepickerButton.setImage(image, for: .normal)
    }
    
    private func setDatepickerButton(withTitle title: String){
        datepickerButton.setTitle(title, for: .normal)
    }
    
    // MARK: Position
    
    func positionSubviews(){
        positionLabelHorizontally(fromLabel)
        positionLabelHorizontally(toLabel)
        positionRouteLineHorizontally(usingFromLabel: fromLabel)
        
        positionFromSearchbar(usingRouteLine: routeLine)
        positionToSearchbar(usingFromSearchbar: fromSearchbar)
        
        positionLabelVertically(fromLabel, usingSearchbar: fromSearchbar)
        positionLabelVertically(toLabel, usingSearchbar: toSearchbar)
        positionRouteLineVertically(usingFromLabel: fromLabel)
        
        positionSearchbarView(usingFromSearchbar: fromSearchbar, usingToSearchbar: toSearchbar)
        positionDatepickerButton(usingSearchbarView: searcbarView)
        positionBottomLine(usingDatepickerButton: datepickerButton)
        
        resizeSearchbar(fromSearchbar, usingSwapButton: swapButton)
        resizeSearchbar(toSearchbar, usingSwapButton: swapButton)
        
        positionSwapButton(usingFromSearchBar: fromSearchbar, usingRouteLine: routeLine)
    }
    
    private func positionLabelHorizontally(_ label: UILabel){
        let oldFrame = label.frame
        let newFrame = CGRect(x: leadingSpace, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height)
        
        label.frame = newFrame
    }
    
    private func positionRouteLineHorizontally(usingFromLabel fromLabel: UILabel){
        let oldFrame = routeLine.frame
        let newFrame = CGRect(x: fromLabel.frame.maxX + routeLineLeftSpace, y: oldFrame.minY, width: oldFrame.width , height: oldFrame.height)
        
        routeLine.frame = newFrame
    }
    
    private func positionFromSearchbar(usingRouteLine routeLine: CircleLine){
        let oldFrame = fromSearchbar.frame
        let newFrame = CGRect(x: routeLine.frame.maxX + routeLineRightSpace, y: topSpace, width: oldFrame.width, height: oldFrame.height)
        
        fromSearchbar.frame = newFrame
    }
    
    private func positionToSearchbar(usingFromSearchbar fromSearchbar: UIButton){
        let oldFrame = toSearchbar.frame
        let newFrame = CGRect(x: fromSearchbar.frame.minX, y: fromSearchbar.frame.maxY + leadingSpace, width: oldFrame.width, height: oldFrame.height)
        
         toSearchbar.frame = newFrame
    }
    
    private func positionLabelVertically(_ label: UILabel, usingSearchbar searchbar: UIButton){
        label.center.y = searchbar.center.y
    }
    
    private func positionRouteLineVertically(usingFromLabel fromLabel: UILabel){
        let oldFrame = routeLine.frame
        let newFrame = CGRect(x: oldFrame.minX, y: fromLabel.frame.minY + 4, width: oldFrame.width, height: oldFrame.height)
        
        routeLine.frame = newFrame
    }
    
    private func positionSearchbarView(usingFromSearchbar fromSearchbar: UIButton, usingToSearchbar toSearchbar: UIButton){
        let oldFrame = searcbarView.frame
        let newFrame = CGRect(x: 0, y: lineWidth, width: oldFrame.width, height: topSpace + fromSearchbar.frame.height + leadingSpace + toSearchbar.frame.height + (3*topSpace/4))
        
        searcbarView.frame = newFrame
    }
    
    private func positionDatepickerButton(usingSearchbarView searchbarView: UIView){
        let oldFrame = datepickerButton.frame
        let newFrame = CGRect(x: 0,  y: searchbarView.frame.maxY + lineWidth, width: oldFrame.width, height: oldFrame.height)
        
        datepickerButton.frame = newFrame
    }
    
    private func positionBottomLine(usingDatepickerButton datepickerButton: UIButton){
        let oldFrame = bottomLine.frame
        let newFrame = CGRect(x: 0, y: datepickerButton.frame.maxY - lineWidth, width: oldFrame.width, height: oldFrame.height)
        
        bottomLine.frame = newFrame
    }
    
    private func resizeSearchbar(_ searchbar: UIButton, usingSwapButton swapButton: UIButton){
        var resizedSearchbarFrame = searchbar.frame
        resizedSearchbarFrame.size.width = self.frame.width - searchbar.frame.minX - swapButton.frame.width - 2*swapPadding
        
        searchbar.frame = resizedSearchbarFrame
    }
    
    private func positionSwapButton(usingFromSearchBar fromSearchbar: UIButton, usingRouteLine routeLine: CircleLine){
        let oldFrame = swapButton.frame
        let newFrame = CGRect(x: fromSearchbar.frame.maxX + swapPadding, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height)
        
        swapButton.frame = newFrame
        
        swapButton.center.y = routeLine.center.y
    }
    
    // MARK: Add subviews
    
    func addSubviews(){
        addSubview(searcbarView)
        searcbarView.addSubview(fromSearchbar)
        searcbarView.addSubview(fromLabel)
        searcbarView.addSubview(routeLine)
        searcbarView.addSubview(swapButton)
        searcbarView.addSubview(toSearchbar)
        searcbarView.addSubview(toLabel)
        addSubview(datepickerButton)
        addSubview(bottomLine)
    }
}
