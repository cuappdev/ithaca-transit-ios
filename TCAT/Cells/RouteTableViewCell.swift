//
//  RouteTableViewCell.swift
//  TCAT
//
//  Created by Monica Ong on 2/13/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {

    //Data
    var departureTime: Date?
    var arrivalTime: Date?
    var stops: [String] = []
    var busNums: [Int] = []
    var distance: Double = 0 //of first stop
    
    //View
    var travelTimeLabel: UILabel = UILabel()
    var departTimeLabel: UILabel = UILabel()
    var stopLabels: [UILabel] = []
    var stopDots: [DirectionCircle] = []
    var busIcons: [UIView] = []
    var walkLines: [DottedLine] = []
    var busLine: UIView = UIView()
    var distanceLabel: UILabel = UILabel()
    
    var topLine: UIView = UIView()
    var bottomLine: UIView = UIView()
    var spaceBtCells: UIView = UIView()
    
    //Spacing
    let spaceXFromSuperviewLeft: CGFloat = 18.0
    let spaceYToCellBorder: CGFloat = 18.0

    let spaceYTimeLabelFromSuperviewTop: CGFloat = 18.0
    let spaceYDepartLabelFromSuperviewRight: CGFloat = 12.0

    let spaceYTimeLabelAndDot: CGFloat = 26.0

    let busLineWidthX: CGFloat = 1.0
    let busLineLengthY: CGFloat = 21.0
    
    let spaceXBtBusIconAndDot: CGFloat = 12.0
    let spaceXBtDotAndStopLabel: CGFloat = 17.5
    let spaceXBtStopLabelAndDistLabel: CGFloat = 5.5
    
    let cellBorderWidthY: CGFloat = 0.75
    let cellSpaceWidthY: CGFloat = 4.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //Set up time label text, frame
        travelTimeLabel.frame = CGRect(x: spaceXFromSuperviewLeft, y: spaceYTimeLabelFromSuperviewTop, width: 135, height: 20)
        travelTimeLabel.font = UIFont(name: "SFUIText-Medium", size: 14.0)
        travelTimeLabel.textColor = .primaryTextColor
        contentView.addSubview(travelTimeLabel)
        
        //Set up depart label text, &  frame
        departTimeLabel.frame = CGRect(x: 0, y: travelTimeLabel.frame.minY, width: 135, height: 20)
        departTimeLabel.font = UIFont(name: "SFUIText-Medium", size: 14.0)
        departTimeLabel.textColor = .tcatBlueColor
        contentView.addSubview(departTimeLabel)
        
        //Set up top seperator line
        topLine = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: cellBorderWidthY))
        topLine.backgroundColor = .lineColor
        contentView.addSubview(topLine)
        
        //Set up bus line
        busLine = UIView(frame: CGRect(x: 0, y: 0, width: busLineWidthX, height: busLineLengthY))
        busLine.backgroundColor = .tcatBlueColor
        contentView.addSubview(busLine)
        
    }
    
    
    override func prepareForReuse() {
        //Remove dyamically placed views from superview
        for stopNumButton in stopDots{
            stopNumButton.removeFromSuperview()
        }
        for stopLabel in stopLabels{
            stopLabel.removeFromSuperview()
        }
        for busIcon in busIcons{
            busIcon.removeFromSuperview()
        }
        for line in walkLines{
            line.removeFromSuperview()
        }
        //Remove seperator betweeen cells
        spaceBtCells.removeFromSuperview()
        bottomLine.removeFromSuperview()
        
        //Clear the arrays that hold the dynamically placed views
        stopDots.removeAll()
        stopLabels.removeAll()
        busIcons.removeAll()
        walkLines.removeAll()
    }
    
    //Call this function after pass all data to cell in order to set cell with this data
    func setData(){
        //Set data
        
        //Input travel time
        travelTimeLabel.text = "\(Time.string(from: departureTime!)) - \(Time.string(from: arrivalTime!))"
        travelTimeLabel.sizeToFit()
        
        //Generate time string based on time until departure
        let timeUntilDeparture = Time.dateComponents(from: Date(), to: departureTime!)
        var timeStr = ""
        if(timeUntilDeparture.day! > 0){
            timeStr += "\(timeUntilDeparture.day!) d "
        }
        if(timeUntilDeparture.hour! > 0){
            timeStr += "\(timeUntilDeparture.hour!) hr "
        }
        if(timeUntilDeparture.minute! > 0 ){
            timeStr += "\(timeUntilDeparture.minute!) min"
        }
        if timeStr.isEmpty{
            timeStr = "0 min"
        }
        
        //Input depart time
        departTimeLabel.text = "Departs in \(timeStr)"
        departTimeLabel.sizeToFit()
        
        //Create stopDots & busIcons
        for i in 0...(busNums.count-1){
            if(i == (busNums.count - 1)){
                let circleLineBlue = DirectionCircle(.finishOn)
                circleLineBlue.backgroundColor = .white
                stopDots.append(circleLineBlue)
            }else{
                let circleDotBlue = DirectionCircle(.standardOn)
                stopDots.append(circleDotBlue)
            }
            if(busNums[i] == -2){
                let walkIcon = UIImageView(image: UIImage(named: "walk"))
                walkIcon.contentMode = .scaleAspectFit
                busIcons.append(walkIcon)
            }else if(busNums[i] != -1){ //Don't add pins
                busIcons.append(BusIcon(size: .small, number: busNums[i]))
            }
        }
        
        //Create stops text
        for i in 0...((stops.count)-1) {
            stopLabels.append(UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20)))
            stopLabels[i].text = stops[i]
            stopLabels[i].font = UIFont(name: "SFUIText-Regular", size: 14.0)
            stopLabels[i].textColor = .primaryTextColor
            stopLabels[i].sizeToFit()
        }
        
        //Set up distance label
        distanceLabel.font = UIFont(name: "SFUIText-Regular", size: 12.0)
        distanceLabel.textColor = .mediumGrayColor
        let roundDigit = distance >= 10 ? 0 : 1
        distanceLabel.text = "\(distance.roundToPlaces(places: roundDigit)) mi away"
        distanceLabel.sizeToFit()
        
        //Position views
        
        //Position depart time label
        departTimeLabel.center.x = contentView.frame.width - spaceYDepartLabelFromSuperviewRight - (departTimeLabel.frame.width/2)
        
        //Positon stop dots positions
        for i in 0...(stopDots.count-1){
            if(i == 0){ //set position of first pins
                stopDots[i].center.y = travelTimeLabel.frame.maxY + spaceYTimeLabelAndDot + (stopDots[i].frame.height/2)
            }else{//set position of other pins & arrows
                stopDots[i].center.x = stopDots[i-1].center.x
                stopDots[i].center.y = stopDots[i-1].frame.maxY + busLineLengthY + (stopDots[i-1].frame.height/2) //for dots w/ lines use dot w/out lines height to keep line width btn dots uniform
            }
        }
        
        //Position bus icons (& create walk lines)
        for i in 0...(busIcons.count-1){
            busIcons[i].center.y = (stopDots[i].center.y + stopDots[i+1].center.y)/2
            if let walkIcon = busIcons[i] as? UIImageView{
                walkIcon.center.x = spaceXFromSuperviewLeft + (busIcons[i-1].frame.width/2)
                //create walk lines
                let topDot = stopDots[i]
                let bottomDot = stopDots[i+1]
                let line = DottedLine(frame: CGRect(x: 0, y: topDot.frame.maxY, width: 1.0, height: bottomDot.frame.minY - topDot.frame.maxY))
                line.backgroundColor = .white
                line.tag = i
                walkLines.append(line)
            }else{
                busIcons[i].center.x = spaceXFromSuperviewLeft + (busIcons[i].frame.width/2)
            }
        }
        
        //Postion first dot relative to bus icon & rest of dots relative to previous dot
        for i in 0...(stopDots.count-1){
            if(i==0){
               stopDots[i].center.x =  busIcons[i].frame.maxX + spaceXBtBusIconAndDot + (stopDots[i].frame.width/2)
            }else{
                stopDots[i].center.x = stopDots[i-1].center.x
            }
        }
        
        //Position walk lines
        for line in walkLines{
            let i = line.tag
            line.center.x = stopDots[i].center.x - 0.5 //so to cover up blue line
        }
        
        //Position bus line
        busLine.center.x = stopDots[0].center.x
        busLine.frame = CGRect(x: stopDots[0].center.x - busLineWidthX, y: stopDots[0].center.y, width: busLineWidthX, height: stopDots[stopDots.count-1].center.y - stopDots[0].center.y)
        
        //Position stop labels
        for i in 0...(stopLabels.count-1){
            if(i == 0){//postion first label relative to stopDot
              stopLabels[i].center.x = stopDots[i].frame.maxX + spaceXBtDotAndStopLabel + (stopLabels[i].frame.width/2)
            }else{ //left align rest of labels with first label
                let oldFrame = stopLabels[i].frame
                let newFrame = CGRect(x: stopLabels[0].frame.minX, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height)
                stopLabels[i].frame = newFrame
            }
            stopLabels[i].center.y = stopDots[i].center.y
        }
        
        //Position distance label
        distanceLabel.frame = CGRect(x: stopLabels[0].frame.maxX + spaceXBtStopLabelAndDistLabel, y: stopLabels[0].frame.minY, width: 90, height: 20)
        distanceLabel.sizeToFit()
        
        //Add subviews to view
        for stopNumButton in stopDots{
            contentView.addSubview(stopNumButton)
        }
        for stopLabel in stopLabels{
            contentView.addSubview(stopLabel)
        }
        for busIcon in busIcons{
            contentView.addSubview(busIcon)
        }
        for line in walkLines{
            contentView.addSubview(line)
        }
        
        contentView.addSubview(distanceLabel)
        
        //Set up & position line and spacing btn cells
        spaceBtCells = UIView(frame: CGRect(x: 0, y: contentView.frame.height - cellSpaceWidthY, width: UIScreen.main.bounds.width, height: cellSpaceWidthY))
        spaceBtCells.backgroundColor = .tableBackgroundColor
        contentView.addSubview(spaceBtCells)
        
        bottomLine = UIView(frame: CGRect(x: 0, y: spaceBtCells.frame.minY + cellBorderWidthY, width: UIScreen.main.bounds.width, height: cellBorderWidthY))
        bottomLine.backgroundColor = .lineColor
        contentView.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
