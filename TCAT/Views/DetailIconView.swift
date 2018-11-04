//
//  DetailIconView.swift
//  TCAT
//
//  Created by Matthew Barker on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class DetailIconView: UIView {
    
    private let timeLabelConstant: CGFloat = 8
    private let constant: CGFloat = 16
    private var shouldAddSubviews: Bool = true
    
    static let width: CGFloat = 114
    
    var direction: Direction!
    
    var scheduledTimeLabel = UILabel()
    var delayedTimeLabel = UILabel()
    
    var connectorTop: UIView!
    var connectorBottom: UIView!
    var statusCircle: Circle!
    
    init(direction: Direction, height: CGFloat, firstStep: Bool, lastStep: Bool) {
        
        self.direction = direction
        
        let frame = CGRect(x: 0, y: 0, width: DetailIconView.width, height: height)
        super.init(frame: frame)
        
        // Format and place time labels
        scheduledTimeLabel.font = .style(Fonts.SanFrancisco.regular, size: 14)
        scheduledTimeLabel.textColor = .primaryTextColor
        delayedTimeLabel.font = .style(Fonts.SanFrancisco.regular, size: 14)
        delayedTimeLabel.textColor = .liveRedColor
        
        updateScheduledTime()
        updateDelayedTime()
        
        let linePosition = frame.maxX - constant
        
        connectorTop = UIView(frame: CGRect(x: linePosition, y: 0, width: 4, height: self.frame.height / 2))
        connectorTop.frame.origin.x -= connectorTop.frame.width / 2
        connectorBottom = UIView(frame: CGRect(x: linePosition, y: self.frame.height / 2, width: 4, height: self.frame.height / 2))
        connectorBottom.frame.origin.x -= connectorBottom.frame.width / 2
        
        if direction.type == .walk {
            if lastStep {
                statusCircle = Circle(size: .large, style: .bordered, color: .lineDotColor)
                connectorTop.backgroundColor = .lineDotColor
                connectorBottom.backgroundColor = .clear
            } else {
                statusCircle = Circle(size: .small, style: .solid, color: .lineDotColor)
                connectorTop.backgroundColor = .lineDotColor
                connectorBottom.backgroundColor = .lineDotColor
                if firstStep {
                    connectorTop.backgroundColor = .clear
                }
            }
        } else {
            if lastStep {
                statusCircle = Circle(size: .large, style: .bordered, color: .tcatBlueColor)
                connectorTop.backgroundColor = .tcatBlueColor
                connectorBottom.backgroundColor = .clear
            } else {
                statusCircle = Circle(size: .small, style: .solid, color: .tcatBlueColor)
                if direction.type == .depart {
                    connectorTop.backgroundColor = .lineDotColor
                    connectorBottom.backgroundColor = .tcatBlueColor
                } else if direction.type == .transfer {
                    connectorTop.backgroundColor = .tcatBlueColor
                    connectorBottom.backgroundColor = .tcatBlueColor
                } else { // type == .arrive
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
            addSubview(scheduledTimeLabel)
            addSubview(delayedTimeLabel)
            addSubview(connectorTop)
            addSubview(connectorBottom)
            addSubview(statusCircle)
            shouldAddSubviews = false
        }
        
    }
    
    // MARK: Utility Functions
    
    public func updateTimes(with newDirection: Direction, isLast: Bool = false) {
        DispatchQueue.main.async {
            self.updateScheduledTime(with: newDirection, isLast: isLast)
            self.updateDelayedTime(with: newDirection, isLast: isLast)
            self.setNeedsDisplay()
        }
    }
    
    /// Update scheduled label with direction's delay description. Use self.direction by default.
    func updateScheduledTime(with newDirection: Direction? = nil, isLast: Bool = false) {
        
        let direction: Direction = newDirection != nil ? newDirection! : self.direction
        var timeString: String
        
        if direction.type == .walk {
            timeString = isLast ? direction.endTimeWithDelayDescription : direction.startTimeWithDelayDescription
        } else {
            timeString = isLast ? direction.endTimeDescription : direction.startTimeDescription
        }
        
        scheduledTimeLabel.text = timeString
        scheduledTimeLabel.sizeToFit()
        scheduledTimeLabel.center = center
        scheduledTimeLabel.frame.origin.x = constant
        
        if direction.type == .walk {
            scheduledTimeLabel.textColor = .primaryTextColor
            hideDelayedLabel()
        }
        
        else {
            if let delay = direction.delay, delay < 60 {
                scheduledTimeLabel.textColor = .liveGreenColor
                hideDelayedLabel()
            } else {
                scheduledTimeLabel.textColor = .primaryTextColor
                scheduledTimeLabel.center.y -= timeLabelConstant
            }
        }
        
    }
    
    /// Update delayed label with direction's delay description. Use self.direction by default.
    func updateDelayedTime(with newDirection: Direction? = nil, isLast: Bool = false) {
        
        let direction: Direction = newDirection != nil ? newDirection! : self.direction
        let timeString = isLast ? direction.endTimeWithDelayDescription : direction.startTimeWithDelayDescription
        
        delayedTimeLabel.text = timeString
        delayedTimeLabel.sizeToFit()
        delayedTimeLabel.center.y = center.y + timeLabelConstant
        delayedTimeLabel.frame.origin.x = constant
        
        if let delay = direction.delay, delay >= 60, direction.type != .walk {
            delayedTimeLabel.isHidden = false
            delayedTimeLabel.textColor = .liveRedColor
        } else {
            hideDelayedLabel()
        }
        
    }
    
    func hideDelayedLabel() {
        delayedTimeLabel.isHidden = true
        scheduledTimeLabel.center = center
        scheduledTimeLabel.frame.origin.x = constant
    }
    
    // MARK: Other
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    func prepareForReuse() {
//        scheduledTimeLabel.removeFromSuperview()
//        connectorTop.removeFromSuperview()
//        connectorBottom.removeFromSuperview()
//        statusCircle.removeFromSuperview()
//    }
    
}
