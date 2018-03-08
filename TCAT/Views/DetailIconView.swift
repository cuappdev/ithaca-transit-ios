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
    
    fileprivate let constant: CGFloat = 16
    fileprivate var shouldAddSubviews: Bool = true
    
    var type: IconType!
    var time: String!
    
    var timeLabel = UILabel()
    var connectorTop: UIView!
    var connectorBottom: UIView!
    var statusCircle: Circle!
    
    init(height: CGFloat, type: IconType, time: String, firstStep: Bool, lastStep: Bool) {
        
//        print("""
//            [DetailView] Init
//                 height: \(height)
//                   type: \(type),
//                   time: \(time),
//              firstStep: \(firstStep),
//               lastStep: \(lastStep)
//        """)
        
        self.type = type
        self.time = time
        let frame = CGRect(x: 0, y: 0, width: 114, height: height)
        super.init(frame : frame)
        
        // Format and place time label
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textColor = .primaryTextColor
        changeTime(time)
        
        let linePosition = frame.maxX - constant
        
        connectorTop = UIView(frame: CGRect(x: linePosition, y: 0, width: 4, height: self.frame.height / 2))
        connectorTop.frame.origin.x -= connectorTop.frame.width / 2
        connectorBottom = UIView(frame: CGRect(x: linePosition, y: self.frame.height / 2, width: 4, height: self.frame.height / 2))
        connectorBottom.frame.origin.x -= connectorBottom.frame.width / 2
        
        if type == .noBus {
            if lastStep {
                statusCircle = Circle(size: .large, color: .lineDotColor, style: .bordered)
                connectorTop.backgroundColor = .lineDotColor
                connectorBottom.backgroundColor = .clear
            } else {
                statusCircle = Circle(size: .small, color: .lineDotColor, style: .solid)
                connectorTop.backgroundColor = .lineDotColor
                connectorBottom.backgroundColor = .lineDotColor
                if firstStep {
                    connectorTop.backgroundColor = .clear
                }
            }
        } else {
            if lastStep {
                statusCircle = Circle(size: .large, color: .tcatBlueColor, style: .bordered)
                connectorTop.backgroundColor = .tcatBlueColor
                connectorBottom.backgroundColor = .clear
            } else {
                statusCircle = Circle(size: .small, color: .tcatBlueColor, style: .solid)
                if type == .busStart {
                    connectorTop.backgroundColor = .lineDotColor
                    connectorBottom.backgroundColor = .tcatBlueColor
                } else {
                    connectorTop.backgroundColor = .tcatBlueColor
                    connectorBottom.backgroundColor = .lineDotColor
                }
                if firstStep {
                    connectorTop.backgroundColor = .clear
                }
            }
        }
        
        if firstStep && lastStep {
            connectorTop.backgroundColor = .clear
            connectorBottom.backgroundColor = .clear
        }
        
        statusCircle.center = self.center
        statusCircle.frame.origin.x = linePosition - (statusCircle.frame.width / 2)
        
        if shouldAddSubviews {
            addSubview(timeLabel)
            addSubview(connectorTop)
            addSubview(connectorBottom)
            addSubview(statusCircle)
            shouldAddSubviews = false
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func changeTime(_ time: String) {
        timeLabel.text = time
        timeLabel.sizeToFit()
        timeLabel.center = self.center
        timeLabel.frame.origin.x = constant
    }
    
}
