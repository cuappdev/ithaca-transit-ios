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
    var stops: [String] = [] //mainStops
    var stopNums: [Int] = [] //mainStopsNum, 0 for pins
    var distance: Double = 0 //of first stop
    
    //View
    var travelTimeLabel: UILabel = UILabel()
    var departTimeLabel: UILabel = UILabel()
    var stopLabels: [UILabel] = []
    var stopNumButtons: [UIButton] = []
    var arrows: [UIImageView] = []
    var distanceLabel: UILabel = UILabel()
    
    //Spacing
    let space: CGFloat = 8.0
    
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
        travelTimeLabel.frame = CGRect(x: space*1.5, y: space, width: 135, height: 20)
        travelTimeLabel.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        travelTimeLabel.textColor = .travelTimeColor
        contentView.addSubview(travelTimeLabel)
        
        //Set up depart label text, &  frame
        departTimeLabel.frame = CGRect(x: 0, y: travelTimeLabel.frame.minY, width: 135, height: 20)
        departTimeLabel.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        departTimeLabel.textColor = .departTimeColor
        contentView.addSubview(departTimeLabel)
    }
    
    override func prepareForReuse() {
        //Remove dyamically placed views from superview
        for arrow in arrows{
            arrow.removeFromSuperview()
        }
        for stopNumButton in stopNumButtons{
            stopNumButton.removeFromSuperview()
        }
        for stopLabel in stopLabels{
            stopLabel.removeFromSuperview()
        }
        //Clear the arrays that hold the dynamically placed views
        arrows.removeAll()
        stopNumButtons.removeAll()
        stopLabels.removeAll()
    }
    
    //Call this function after pass all data to cell in order to set cell with this data
    func setData(){
        //Set data
        
        //Input travel time
        travelTimeLabel.text = "\(Time.string(from: departureTime!)) - \(Time.string(from: arrivalTime!))"
        travelTimeLabel.sizeToFit()
        
        //Generate time string based on time until departure
        let timeUntilDeparture = Time.dateComponents(from: departureTime!, to: Date())
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
        
        //Input depart time
        departTimeLabel.text = "Departs in \(timeStr)"
        departTimeLabel.sizeToFit()
        
        //Create stopNumButtons & format
        for i in 0...(stopNums.count-1){
            stopNumButtons.append(UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30)))
            if(stopNums[i] == -1){ //pin
                stopNumButtons[i].setImage(UIImage(named: "pin"), for: .normal)
                stopNumButtons[i].contentMode = .scaleAspectFit
                stopNumButtons[i].tintColor = .pinColor
            }else{
                stopNumButtons[i].setTitle("\(stopNums[i])", for: .normal)
                stopNumButtons[i].titleLabel?.font = UIFont(name: "SFUIDisplay-Regular", size: 13.0)
                stopNumButtons[i].setTitleColor(.white, for: .normal)
                stopNumButtons[i].backgroundColor = .stopNumColor1
                stopNumButtons[i].layer.cornerRadius = stopNumButtons[i].frame.width/2
                stopNumButtons[i].layer.masksToBounds = true
            }
            stopNumButtons[i].sizeToFit()
        }
        
        //Create arrows (one less arrows than stops buttons)
        for i in 0...stopNumButtons.count-2{
            arrows.append(UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 6)))
            arrows[i].image = UIImage(named: "arrow")
            arrows[i].contentMode = .scaleAspectFit
        }
        
        //Create stops text
        for i in 0...((stops.count)-1) {
            stopLabels.append(UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20)))
            stopLabels[i].text = stops[i]
            stopLabels[i].font = UIFont(name: "SFUIText-Regular", size: 14.0)
            stopLabels[i].textColor = .stopLabelColor
            stopLabels[i].sizeToFit()
        }
        
        //Set up distance label
        distanceLabel.font = UIFont(name: "SFUIText-Regular", size: 12.0)
        distanceLabel.textColor = .distanceLabelColor
        distanceLabel.text = "\(distance) mi away"
        distanceLabel.sizeToFit()
        
        //Position views
        
        //Position depart time label
        departTimeLabel.center.x = contentView.frame.width - space - (departTimeLabel.frame.width/2)
        
        //Positon buttons & arrows positions
        for i in 0...(stopNumButtons.count-1){
            if(i == 0){ //set position of first pins
                stopNumButtons[i].center.x = space + (stopNumButtons[i].frame.width/2)
                stopNumButtons[i].center.y = travelTimeLabel.frame.maxY + space + (stopNumButtons[i].frame.height/2)
            }else{//set position of other pins & arrows
                arrows[i-1].center.x = stopNumButtons[i-1].center.x
                stopNumButtons[i].center.x = stopNumButtons[i-1].center.x
                
                arrows[i-1].center.y = stopNumButtons[i-1].frame.maxY + space + (arrows[i-1].frame.height/2)
                stopNumButtons[i].center.y = arrows[i-1].frame.maxY + space + (stopNumButtons[i].frame.height/2)
            }
        }
        
        //Position stops
        for i in 0...(stopLabels.count-1){
            stopLabels[i].center.x = stopNumButtons[i].frame.maxX + space + (stopLabels[i].frame.width/2)
            stopLabels[i].center.y = stopNumButtons[i].center.y
        }
        
        //Position distance label
        distanceLabel.frame = CGRect(x: stopLabels[0].frame.maxX + space, y: stopLabels[0].frame.minY, width: 90, height: 20)
        
        //Add subviews to view
        for stopNumButton in stopNumButtons{
            contentView.addSubview(stopNumButton)
        }
        for arrow in arrows{
            contentView.addSubview(arrow)
        }
        for stopLabel in stopLabels{
            contentView.addSubview(stopLabel)
        }
        
        contentView.addSubview(distanceLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
