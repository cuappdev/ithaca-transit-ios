//
//  LiveIndicator.swift
//  TCAT
//
//  Created by Matthew Barker on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class SummaryView: UIView {
    
    /// Height of summary view
    static var height: CGFloat = 80
    
    fileprivate var main = UIScreen.main.bounds
    
    /// The puller tab used to indicate dragability
    fileprivate var tab = UIView(frame: CGRect(x: 0, y: 6, width: 32, height: 4))
    
    /// The primary summary label
    fileprivate var mainLabel = UILabel()
    
    /// The secondary label (Trip Duration)
    fileprivate var secondaryLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(route: Route) {
        
        // View Initialization
        super.init(frame: CGRect(x: 0, y: 0, width: main.width, height: SummaryView.height))
        backgroundColor = .summaryBackgroundColor
        roundCorners(corners: [.topLeft, .topRight], radius: 16)

        // Create puller tab
        let tabHeight = (tab.frame.origin.y + tab.frame.height) / 2
        tab.center.x = center.x
        tab.backgroundColor = .mediumGrayColor
        tab.layer.cornerRadius = tab.frame.height / 2
        addSubview(tab)
        
        /// The edge of the next bus icon
        var icon_maxY: CGFloat = 24
        
        /// True if first icon to be placed
        var first = true
        
        /// The center to use for the next bus icon
        var iconCenter = CGPoint(x: icon_maxY, y: (frame.height / 2) + tabHeight)
        
        // Create and place bus icons
        let busRoutes: [Int] = route.directions.flatMap { return $0.type == .depart ? $0.routeNumber : nil }
        for route in busRoutes {

            let busType: BusIconType = busRoutes.count > 1 ? .directionSmall : .directionLarge
            let busIcon = BusIcon(type: busType, number: route)
            
            if first {
                iconCenter.x += busIcon.frame.width / 2
                first = false
            }
            
            busIcon.center = iconCenter
            addSubview(busIcon)
            iconCenter.x += busIcon.frame.width + 12
            icon_maxY += busIcon.frame.width + 12
            
        }
        
        // Place and format top summary label
        let textLabelPadding: CGFloat = 16
        var mainLabelText: String = ""
        
        if let departDirection = (route.directions.filter { $0.type == .depart }).first {
            mainLabelText = "Depart at \(departDirection.startTimeDescription) from \(departDirection.name)"
        } else {
            mainLabelText = route.directions.first?.locationNameDescription ?? "Route Directions"
        }

        mainLabel.text = mainLabelText
        mainLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        mainLabel.textColor = .primaryTextColor
        mainLabel.sizeToFit()
        mainLabel.frame.origin.x = icon_maxY + textLabelPadding
        mainLabel.frame.size.width = frame.maxX - mainLabel.frame.origin.x - textLabelPadding
        mainLabel.center.y = (bounds.height / 2) + tabHeight - (mainLabel.frame.height / 2)
        mainLabel.allowsDefaultTighteningForTruncation = true
        mainLabel.lineBreakMode = .byTruncatingTail
        addSubview(mainLabel)
        
        // Place and format secondary label
        secondaryLabel.text = "Trip Duration: \(route.totalDuration) minute\(route.totalDuration == 1 ? "" : "s")"
        secondaryLabel.font = .systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        secondaryLabel.textColor = .mediumGrayColor
        secondaryLabel.sizeToFit()
        secondaryLabel.frame.origin.x = icon_maxY + textLabelPadding
        secondaryLabel.center.y = (bounds.height / 2) + tabHeight + (secondaryLabel.frame.height / 2)
        addSubview(secondaryLabel)
        
    }
    
}
