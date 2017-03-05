//
//  RouteTableViewCell.swift
//  TCAT
//
//  Created by Monica Ong on 2/13/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

//N2SELF: Got to put this in the colors extensions/make colors extension
extension UIColor {
    @nonobjc static let departTimeColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
    @nonobjc static let travelTimeColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
    @nonobjc static let stopLabelColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
    @nonobjc static let stopNumColor1 = UIColor(red: 243/255, green: 156/255, blue: 18/255, alpha: 1.0)
    @nonobjc static let stopNumColor2 = UIColor(red: 255/255, green: 97/255, blue: 116/255, alpha: 1.0)
    @nonobjc static let distanceLabelColor = UIColor(red: 187/255, green: 187/255, blue: 187/255, alpha: 1.0)
    @nonobjc static let pinColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)

}

//N2SELF: got to change -1 to mean pins
class RouteTableViewCell: UITableViewCell {

    //Data
    var departureTime: Date?
    var arrivalTime: Date?
    var stops: [String] = [] //mainStops
    var stopNums: [Int] = [] //mainStopsNum, 0 for pins
    var distance: Double? //of first stop
    
    //View
    var travelTimeLabel: UILabel = UILabel()
    var departTimeLabel: UILabel = UILabel()
    var stopLabels: [UILabel] = []
    var stopNumButtons: [UIButton] = []
    var arrows: [UIImageView] = []
    var distanceLabel: UILabel = UILabel()
    var header: UIView = UIView()
    
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
        //Set font, font size, color, & frame
        travelTimeLabel.frame = CGRect(x: 0, y: 0, width: 135, height: 20)
        travelTimeLabel.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        travelTimeLabel.textColor = .travelTimeColor
        
        departTimeLabel.frame = CGRect(x: 0, y: 0, width: 135, height: 20)
        departTimeLabel.font = UIFont(name: "SFUIText-Regular", size: 14.0)
        departTimeLabel.textColor = .departTimeColor
        
        distanceLabel.frame = CGRect(x: 0, y: 0, width: 90, height: 20)
        distanceLabel.font = UIFont(name: "SFUIText-Regular", size: 12.0)
        distanceLabel.textColor = .distanceLabelColor
        
        //Set up header size
        header.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: 25)
        
        //Set up & activate constraints for header
        self.addSubview(header)
        
        let headerTopConstraint = NSLayoutConstraint(item: header, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let headerRightConstraint = NSLayoutConstraint(item: header, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        let headerLeftConstraint = NSLayoutConstraint(item: header, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1.0, constant: 0.0)
        
        headerTopConstraint.identifier = "headerTopConstraint"
        headerRightConstraint.identifier = "headerRightConstraint"
        headerLeftConstraint.identifier = "headerLeftConstraint"
        
        NSLayoutConstraint.activate([headerTopConstraint, headerRightConstraint, headerLeftConstraint])
    }
    
    /*Call this function after pass all data to cell 
      * in order to set cell with this data
     */
    func setData(){
        
        //Set up time label text, frame & (activate) constraints
        travelTimeLabel.text = "\(Time.string(from: departureTime!)) - \(Time.string(from: arrivalTime!))"
        travelTimeLabel.sizeToFit()
        
        header.addSubview(travelTimeLabel)
        
        let timeTopConstraint = NSLayoutConstraint(item: travelTimeLabel, attribute: .top, relatedBy: .equal, toItem: header, attribute: .top, multiplier: 1.0, constant: 8.0)
        let timeLeftConstraint = NSLayoutConstraint(item: travelTimeLabel, attribute: .leading, relatedBy: .equal, toItem: header, attribute: .leading, multiplier: 1.0, constant: 8.0)
        let timeBottomConstraint = NSLayoutConstraint(item: travelTimeLabel, attribute: .bottom, relatedBy: .equal, toItem: header, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        timeTopConstraint.identifier = "timeTopConstraint"
        timeLeftConstraint.identifier = "timeLeftConstraint"
        timeBottomConstraint.identifier = "timeBottomConstraint"
        
        NSLayoutConstraint.activate([timeTopConstraint, timeLeftConstraint, timeBottomConstraint])
        
        //Generate depart label text
        //Generate time string based on time until departure
        let timeUntilDeparture = Time.dateComponents(from: Date(), to: departureTime!)
        var timeStr = ""
        if(timeUntilDeparture.day! > 1){
            timeStr += "\(timeUntilDeparture.day) days"
        }else if(timeUntilDeparture.day! > 0){
            timeStr += "\(timeUntilDeparture.day) day"
        }
        if(timeUntilDeparture.hour! > 1){
            timeStr += "\(timeUntilDeparture.hour) hours"
        }else if(timeUntilDeparture.hour! > 0){
            timeStr += "\(timeUntilDeparture.hour) hour"
        }
        if(timeUntilDeparture.minute! > 0 ){
            timeStr += "\(timeUntilDeparture.minute) min"
        }
        
        //Set up depart lable text, frame, & (activate) constraints
        departTimeLabel.text = "Departs in \(timeStr)"
        departTimeLabel.sizeToFit()
        
        header.addSubview(departTimeLabel)
        
        let departTopConstraint = NSLayoutConstraint(item: departTimeLabel, attribute: .top, relatedBy: .equal, toItem: travelTimeLabel, attribute: .top, multiplier: 1.0, constant: 0.0)
        let departRightConstraint = NSLayoutConstraint(item: header, attribute: .trailing, relatedBy: .equal, toItem: departTimeLabel, attribute: .trailing, multiplier: 1.0, constant: 8)
        let departBottomConstraint = NSLayoutConstraint(item: departTimeLabel, attribute: .bottom, relatedBy: .equal, toItem: travelTimeLabel, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        departTopConstraint.identifier = "departTopConstraint"
        departRightConstraint.identifier = "departRightConstraint"
        departBottomConstraint.identifier = "departBottomConstraint"
        
        NSLayoutConstraint.activate([departTopConstraint,departRightConstraint,departBottomConstraint])
        
        
        //Set up stops text & frame
        for i in 0...((stops.count)-1) {
            stopLabels[i] = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
            stopLabels[i].text = stops[i]
            stopLabels[i].font = UIFont(name: "SFUIText-Regular", size: 14.0)
            stopLabels[i].textColor = .stopLabelColor
            stopLabels[i].sizeToFit()
            
            self.addSubview(stopLabels[i])
        }
        
        //Set up stopNumButtons & format
        for i in 0...(stopNums.count-1){
            stopNumButtons[i] = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            if(stopNums[i] == 0){ //pin
                stopNumButtons[i].setImage(UIImage(named: "pin"), for: .normal)
                stopNumButtons[i].contentMode = .scaleAspectFit
                stopNumButtons[i].tintColor = .pinColor
                
            }else{
                stopNumButtons[i].setTitle("\(stopNums[i])", for: .normal)
                stopNumButtons[i].titleLabel?.font = UIFont(name: "SFUIDisplay-Regular", size: 13.0)
                stopNumButtons[i].setTitleColor(.white, for: .normal)
                stopNumButtons[i].backgroundColor = .stopNumColor1
                stopNumButtons[i].layer.cornerRadius = stopNumButtons[i].frame.width/2
                stopNumButtons[i].layer.masksToBounds = true //Do i need this?
            }
            stopNumButtons[i].sizeToFit()
            self.addSubview(stopNumButtons[i])
        }
        
        //Create arrows (one less arrows than stops buttons)
        for i in 0...stopNumButtons.count-2{
            arrows[i] = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 6))
            arrows[i].image = UIImage(named: "arrow")
            arrows[i].contentMode = .scaleAspectFit
            self.addSubview(arrows[i])
        }
        
        //Set (& activate) first stop label, num, and distance label
        let stopNum1LeftConstraint = NSLayoutConstraint(item: stopNums[0], attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1.0, constant: 8.0)
        let stopNum1TopConstraint = NSLayoutConstraint(item: stopNums[0], attribute: .top, relatedBy: .equal, toItem: header, attribute: .bottom, multiplier: 1.0, constant: 8.0)
        let stopLabel1LeftConstraint = NSLayoutConstraint(item: stopLabels[0], attribute: .leading, relatedBy: .equal, toItem: stopNums[0], attribute: .trailing, multiplier: 1.0, constant: 8.0)
        let stopLabel1CenterConstraint = NSLayoutConstraint(item: stopLabels[0], attribute: .centerY, relatedBy: .equal, toItem: stopNums[0], attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let arrow1TopConstraint = NSLayoutConstraint(item: arrows[0], attribute: .top, relatedBy: .equal, toItem: stopNums[0], attribute: .bottom, multiplier: 1.0, constant: 8.0)
        let arrow1CenterConstraint = NSLayoutConstraint(item: arrows[0], attribute: .centerX, relatedBy: .equal, toItem: stopNums[0], attribute: .centerX, multiplier: 1.0, constant: 0.0)
        
        stopNum1LeftConstraint.identifier = "stopNum1LeftConstraint"
        stopNum1TopConstraint.identifier = "stopNum1TopConstraint"
        stopLabel1LeftConstraint.identifier = "stopLabel1LeftConstraint"
        stopLabel1CenterConstraint.identifier = "stopLabel1CenterConstraint"
        arrow1TopConstraint.identifier = "arrow1TopConstraint"
        arrow1CenterConstraint.identifier = "arrow1CenterConstraint"
        
        NSLayoutConstraint.activate([stopNum1LeftConstraint,stopNum1TopConstraint,stopLabel1LeftConstraint,stopLabel1CenterConstraint,arrow1TopConstraint,arrow1CenterConstraint])
        
        //Set up & activate constraints for all stop nums & stop labels
        for i in 1...(stopLabels.count - 1) {
            let stopNumTopConstraint = NSLayoutConstraint(item: stopNums[i], attribute: .top, relatedBy: .equal, toItem: arrows[i-1], attribute: .bottom, multiplier: 1.0, constant: 8.0)
            let stopNumCenterXConstraint = NSLayoutConstraint(item: stopNums[i], attribute: .centerX, relatedBy: .equal, toItem: stopNums[i-1], attribute: .centerX, multiplier: 1.0, constant: 0.0)
            let stopLabelLeftConstraint = NSLayoutConstraint(item: stopLabels[i], attribute: .leading, relatedBy: .equal, toItem: stopLabels[i-1], attribute: .leading, multiplier: 1.0, constant: 0.0)
            let stopLabelCenterYConstraint = NSLayoutConstraint(item: stopLabels[i], attribute: .centerX, relatedBy: .equal, toItem: stopNums[i], attribute: .centerX, multiplier: 1.0, constant: 0.0)
            
            stopNumTopConstraint.identifier = "stopNum\(i)TopConstraint"
            stopNumCenterXConstraint.identifier = "stopNum\(i)CenterXConstraint"
            stopLabelLeftConstraint.identifier = "stopLabel\(i)LeftConstraint"
            stopLabelCenterYConstraint.identifier = "stopLabel\(i)CenterYConstraint"
            
            NSLayoutConstraint.activate([stopNumTopConstraint, stopNumCenterXConstraint, stopLabelLeftConstraint, stopLabelCenterYConstraint])
            
        }
        
        //Set up & activite constraints for all arrows
        for i in 1...(arrows.count-1){
            let arrowTopConstraint = NSLayoutConstraint(item: arrows[i], attribute: .bottom, relatedBy: .equal, toItem: stopNums[i], attribute: .centerX, multiplier: 1.0, constant: 0.0)
            let arrowCenterXConstraint = NSLayoutConstraint(item: arrows[i], attribute: .centerX, relatedBy: .equal, toItem: stopNums[0], attribute: .centerX, multiplier: 1.0, constant: 0.0)
            
            arrowTopConstraint.identifier = "arrow\(i)TopConstraint"
            arrowCenterXConstraint.identifier = "arrow\(i)CenterXConstraint"
            
            NSLayoutConstraint.activate([arrowTopConstraint,arrowCenterXConstraint])
        }
        
        //Set up & activate constrains for distance label
        distanceLabel.text = "\(distance) mi away"
        distanceLabel.sizeToFit()
        
        self.addSubview(distanceLabel)
        
        let distLabelLeftConstraint = NSLayoutConstraint(item: distanceLabel, attribute: .leading, relatedBy: .equal, toItem: stopLabels[0], attribute: .trailing, multiplier: 1.0, constant: 8.0)
        let distLabelCenterYConstraint = NSLayoutConstraint(item: distanceLabel, attribute: .centerY, relatedBy: .equal, toItem: stopNums[0], attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        distLabelLeftConstraint.identifier = "distanceLabelLeftConstraint"
        distLabelCenterYConstraint.identifier = "distanceLabelCenterYConstraint"
        
        NSLayoutConstraint.activate([distLabelLeftConstraint, distLabelCenterYConstraint])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
    }

}
