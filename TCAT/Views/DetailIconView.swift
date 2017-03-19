//
//  DetailIconView.swift
//  TCAT
//
//  Created by Matthew Barker on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

enum IconType: String {
    case noBus // show just the time of instruction
    case busStart // shows icon and time (in color) with start of connector
    case busEnd // same as above, with end of connector
}

class DetailIconView: UIView {
    
    var type: IconType!
    var time: String!
    
    var timeLabel = UILabel()
    var connectorTop: UIView!
    var connectorBottom: UIView!
    var statusCircle: DirectionCircle!

    init (height: CGFloat, type: IconType, time: String, firstStep: Bool, lastStep: Bool) {
        
        self.type = type
        self.time = time
        let frame = CGRect(x: 0, y: 0, width: 114, height: height)
        super.init(frame : frame)
                
        connectorTop = UIView(frame: CGRect(x: 20, y: 0, width: 2, height: self.frame.height / 2))
        connectorTop.frame.origin.x -= connectorTop.frame.width / 2
        connectorBottom = UIView(frame: CGRect(x: 20, y: self.frame.height / 2, width: 2, height: self.frame.height / 2))
        connectorBottom.frame.origin.x -= connectorBottom.frame.width / 2
        addSubview(connectorTop)
        addSubview(connectorBottom)
        
        if type == .noBus {
            if lastStep {
                statusCircle = DirectionCircle(.finishOff)
                connectorTop.backgroundColor = UIColor(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1)
                connectorBottom.backgroundColor = .clear
            } else {
                statusCircle = DirectionCircle(.standardOff)
                connectorTop.backgroundColor = UIColor(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1)
                connectorBottom.backgroundColor = UIColor(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1)
                if firstStep {
                    connectorTop.backgroundColor = .clear
                }
            }
        } else {
            if lastStep {
                statusCircle = DirectionCircle(.finishOn)
                connectorTop.backgroundColor = UIColor(red: 7 / 255, green: 157 / 255, blue: 220 / 255, alpha: 1)
                connectorBottom.backgroundColor = .clear
            } else {
                statusCircle = DirectionCircle(.standardOn)
                if type == .busStart {
                    connectorTop.backgroundColor = UIColor(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1)
                    connectorBottom.backgroundColor = UIColor(red: 7 / 255, green: 157 / 255, blue: 220 / 255, alpha: 1)
                } else {
                    connectorTop.backgroundColor = UIColor(red: 7 / 255, green: 157 / 255, blue: 220 / 255, alpha: 1)
                    connectorBottom.backgroundColor = UIColor(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1)
                }
                if firstStep {
                    connectorTop.backgroundColor = .clear
                }
            }
        }

        statusCircle.center = self.center
        statusCircle.frame.origin.x = 20 - (statusCircle.frame.width / 2)
        addSubview(statusCircle)
        
        // Format and place time label
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textColor = .black
        timeLabel.text = time
        timeLabel.sizeToFit()
        timeLabel.center = self.center
        timeLabel.center.x = statusCircle.frame.maxX + (frame.width - statusCircle.frame.maxX) / 2.0
        addSubview(timeLabel)
        
        switch type.rawValue {
            case IconType.noBus.rawValue: break
            
            case IconType.busStart.rawValue: break
            
            case IconType.busEnd.rawValue: break
            
            default: break
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
