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
    var solidCircle: Circle!
    var line: SolidLine!
    var borderedCircle: Circle!
    var swapButton: UIButton = UIButton()
    var datepickerButton: UIButton = UIButton()
    var topLine: UIView = UIView()
    var bottomLine: UIView = UIView()
    
    // MARK: Spacing vars
    
    let lineWidth: CGFloat = 1.0
    let leadingSpace: CGFloat = 16.0
    let topSpace: CGFloat = 21.5
    let solidCircleLeftSpace: CGFloat = 11.0
    let solidCircleRightSpace: CGFloat = 14.0
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
        styleLine(topLine)
        styleDatepickerButton()
        styleLine(bottomLine)
        
        setLabel(fromLabel, withText: "From")
        setLabel(toLabel, withText: "To")
        setSwapButton(withImage: #imageLiteral(resourceName: "swap"))
        setDatpickerButton(withImage: #imageLiteral(resourceName: "clock"))
        
        positionSubviews()
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Style
    
    private func styleSearchbarView() {
        searcbarView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 103)
        searcbarView.backgroundColor = Colors.white
    }
    
    private func styleLabel(_ label: UILabel) {
        fromLabel.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        label.font = .getFont(.regular, size: 14.0)
        label.textColor = Colors.primaryText
    }
    
    private func styleSearchbar(_ searchbar: UIButton) {
        searchbar.frame = CGRect(x: 0, y: 0, width: 243, height: searchbarHeight)
        searchbar.backgroundColor = Colors.backgroundWash
        searchbar.setTitleColor(Colors.primaryText, for: .normal)
        searchbar.titleLabel?.font = .getFont(.regular, size: 14.0)
        searchbar.contentHorizontalAlignment = .left
        searchbar.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: searchbarTextSpaceFromLeft, bottom: 0, right: 0)
        searchbar.layer.cornerRadius = searchbarHeight/4
        searchbar.layer.masksToBounds = true
    }
    
    private func styleRouteLine() {
        solidCircle = Circle(size: .small, style: .solid, color: Colors.metadataIcon)
        line = SolidLine(height: 27.0, color: Colors.metadataIcon)
        borderedCircle = Circle(size: .medium, style: .bordered, color: Colors.metadataIcon)
    }
    
    private func styleSwapButton() {
        swapButton.frame = CGRect(x: 0, y: 0, width: 20, height: 25)
        swapButton.imageView?.contentMode = .scaleAspectFit
    }
    
    private func styleDatepickerButton() {
        datepickerButton.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: datepickerButtonHeight)
        
        datepickerButton.contentMode = .scaleAspectFit
        
        datepickerButton.tintColor = Colors.metadataIcon
        datepickerButton.setTitleColor(Colors.metadataIcon, for: .normal)
        datepickerButton.titleLabel?.font = .getFont(.regular, size: 14.0)
        
        datepickerButton.backgroundColor = Colors.white
        
        datepickerButton.contentHorizontalAlignment = .left
        datepickerButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: leadingSpace, bottom: 0, right: 0)
        datepickerButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: leadingSpace + datepickerImageWidth + datepickerTitleLeadingSpace, bottom: 0, right: 0)
    }
    
    private func styleLine(_ line: UIView) {
        line.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: lineWidth)
        line.backgroundColor = Colors.dividerTextField
    }
        
    // MARK: Set data
    
    private func setLabel(_ label: UILabel, withText text: String) {
        label.text = text
        label.sizeToFit()
    }
    
    private func setSwapButton(withImage image: UIImage) {
        swapButton.setImage(image, for: .normal)
        swapButton.tintColor = Colors.metadataIcon
    }
    
    private func setDatpickerButton(withImage image: UIImage) {
        datepickerButton.setImage(image, for: .normal)
    }
    
    func setDatepicker(withDate date: Date, withSearchTimeType searchTimeType: SearchType) {
        let dateString = Time.dateString(from: date)
        var title = ""
        
        if Calendar.current.isDateInToday(date) || Calendar.current.isDateInTomorrow(date) {
            let verb = (searchTimeType == .arriveBy) ? "Arrive" : (searchTimeType == .leaveNow) ? "Leave now" : "Leave" //Use simply,"arrive" or "leave"
            let day = Calendar.current.isDateInToday(date) ? "" : "tomorrow " //if today don't put day
            title = (searchTimeType == .leaveNow) ? "\(verb) (\(day.capitalizingFirstLetter())\(Time.timeString(from: date)))" : "\(verb) \(day)at \(Time.timeString(from: date))"
        }else{
            let verb = (searchTimeType == .arriveBy) ? "Arrive by" : "Leave on" //Use "arrive by" or "leave on"
            title = "\(verb) \(dateString)"
        }
        
        datepickerButton.setTitle(title, for: .normal)
    }
    
    // MARK: Position
    
    func positionSubviews() {
        positionLabelHorizontally(fromLabel)
        positionLabelHorizontally(toLabel)
        postionSolidCircleHorizontally(usingFromLabel: fromLabel)
        
        positionFromSearchbar(usingSolidCircle: solidCircle)
        positionToSearchbar(usingFromSearchbar: fromSearchbar)
        
        positionSolidCircleVertically(usingFromSearchbar: fromSearchbar)
        positionBorderedCircle(usingSolidCircle: solidCircle, usingToSearchbar: toSearchbar)
        positionLine(usingSolidCircle: solidCircle, usingBorderedCircle: borderedCircle)

        positionLabelVertically(fromLabel, usingSearchbar: fromSearchbar)
        positionLabelVertically(toLabel, usingSearchbar: toSearchbar)
        
        positionSearchbarView(usingFromSearchbar: fromSearchbar, usingToSearchbar: toSearchbar)
        positionDatepickerButton(usingSearchbarView: searcbarView)
        positionTopLine(usingDatepickerButton: datepickerButton)
        positionBottomLine(usingDatepickerButton: datepickerButton)
        
        resizeSearchbar(fromSearchbar, usingSwapButton: swapButton)
        resizeSearchbar(toSearchbar, usingSwapButton: swapButton)
        
        positionSwapButton(usingFromSearchBar: fromSearchbar, usingLine: line)
    }
    
    private func positionLabelHorizontally(_ label: UILabel) {
        let oldFrame = label.frame
        let newFrame = CGRect(x: leadingSpace, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height)
        
        label.frame = newFrame
    }
    
    private func postionSolidCircleHorizontally(usingFromLabel fromLabel: UILabel) {
        solidCircle.center.x = fromLabel.frame.maxX + solidCircleLeftSpace + (solidCircle.frame.width/2)
    }
    
    private func positionFromSearchbar(usingSolidCircle solidCircle: Circle) {
        let oldFrame = fromSearchbar.frame
        let newFrame = CGRect(x: solidCircle.frame.maxX + solidCircleRightSpace, y: topSpace, width: oldFrame.width, height: oldFrame.height)
        
        fromSearchbar.frame = newFrame
    }
    
    private func positionToSearchbar(usingFromSearchbar fromSearchbar: UIButton) {
        let oldFrame = toSearchbar.frame
        let newFrame = CGRect(x: fromSearchbar.frame.minX, y: fromSearchbar.frame.maxY + leadingSpace, width: oldFrame.width, height: oldFrame.height)
        
         toSearchbar.frame = newFrame
    }
    
    private func positionSolidCircleVertically(usingFromSearchbar fromSearchbar: UIButton) {
        solidCircle.center.y = fromSearchbar.center.y
    }
    
    private func positionBorderedCircle(usingSolidCircle solidCircle: Circle, usingToSearchbar toSearchbar: UIButton) {
        borderedCircle.center.x = solidCircle.center.x
        borderedCircle.center.y = toSearchbar.center.y
    }
    
    private func positionLine(usingSolidCircle solidCircle: Circle, usingBorderedCircle borderedCircle: Circle) {
        line.center.x = solidCircle.center.x
        
        let oldFrame = line.frame
        let newFrame = CGRect(x: oldFrame.minX, y: solidCircle.center.y, width: oldFrame.width, height: 1 + borderedCircle.frame.minY - solidCircle.center.y)
        
        line.frame = newFrame
    }
    
    private func positionLabelVertically(_ label: UILabel, usingSearchbar searchbar: UIButton) {
        label.center.y = searchbar.center.y
    }
    
    private func positionSearchbarView(usingFromSearchbar fromSearchbar: UIButton, usingToSearchbar toSearchbar: UIButton) {
        let oldFrame = searcbarView.frame
        let newFrame = CGRect(x: 0, y: lineWidth, width: oldFrame.width, height: topSpace + fromSearchbar.frame.height + leadingSpace + toSearchbar.frame.height + (3*topSpace/4))
        
        searcbarView.frame = newFrame
    }
    
    private func positionDatepickerButton(usingSearchbarView searchbarView: UIView) {
        let oldFrame = datepickerButton.frame
        let newFrame = CGRect(x: 0,  y: searchbarView.frame.maxY + lineWidth, width: oldFrame.width, height: oldFrame.height)
        
        datepickerButton.frame = newFrame
    }
    
    private func positionTopLine(usingDatepickerButton datepickerButton: UIButton) {
        let oldFrame = topLine.frame
        let newFrame = CGRect(x: 0, y: datepickerButton.frame.minY - lineWidth, width: oldFrame.width, height: oldFrame.height)
        
        topLine.frame = newFrame
    }
    
    private func positionBottomLine(usingDatepickerButton datepickerButton: UIButton) {
        let oldFrame = bottomLine.frame
        let newFrame = CGRect(x: 0, y: datepickerButton.frame.maxY - lineWidth, width: oldFrame.width, height: oldFrame.height)
        
        bottomLine.frame = newFrame
    }
    
    private func resizeSearchbar(_ searchbar: UIButton, usingSwapButton swapButton: UIButton) {
        var resizedSearchbarFrame = searchbar.frame
        resizedSearchbarFrame.size.width = self.frame.width - searchbar.frame.minX - swapButton.frame.width - 2*swapPadding
        
        searchbar.frame = resizedSearchbarFrame
    }
    
    private func positionSwapButton(usingFromSearchBar fromSearchbar: UIButton, usingLine line: UIView) {
        let oldFrame = swapButton.frame
        let newFrame = CGRect(x: fromSearchbar.frame.maxX + swapPadding, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height)
        
        swapButton.frame = newFrame
        
        swapButton.center.y = line.center.y
    }
    
    // MARK: Add subviews
    
    func addSubviews() {
        addSubview(searcbarView)
        searcbarView.addSubview(fromSearchbar)
        searcbarView.addSubview(fromLabel)
        searcbarView.addSubview(solidCircle)
        searcbarView.addSubview(line)
        searcbarView.addSubview(borderedCircle)
        searcbarView.addSubview(swapButton)
        searcbarView.addSubview(toSearchbar)
        searcbarView.addSubview(toLabel)
        addSubview(topLine)
        addSubview(datepickerButton)
        addSubview(bottomLine)
    }
}
