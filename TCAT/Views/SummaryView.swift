//
//  LiveIndicator.swift
//  TCAT
//
//  Created by Matthew Barker on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class SummaryView: UIView {
    
    /// The route being used for the summary view
    var route: Route! {
        didSet { setRoute() }
    }
    
    /// The puller tab used to indicate dragability
    fileprivate var tab = UIView(frame: CGRect(x: 0, y: 6, width: 32, height: 4))
    
    /// Three times the height of the tab view (spacing + tabHeight + spacing)
    fileprivate var tabInsetHeight: CGFloat = 12
    
    /// The usable height of the summaryView
    var safeAreaHeight: CGFloat {
        return frame.size.height - tabInsetHeight
    }
    
    /// The y-coordinate center of the safe area
    var safeAreaCenterY: CGFloat {
        return tabInsetHeight + safeAreaHeight / 2
    }
    
    /// The primary summary label
    fileprivate var mainLabel = UILabel()
    
    /// The secondary label (Trip Duration)
    fileprivate var secondaryLabel = UILabel()
    
    /// Whether route icons have been set or not
    fileprivate var didSetRoutes: Bool = false
    
    /// The device's bounds
    fileprivate var main = UIScreen.main.bounds
    /// Constant for label padding
    fileprivate let textLabelPadding: CGFloat = 16
    /// Identifier for bus route icons
    fileprivate let busIconTag: Int = 14850
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(route: Route? = nil) {
        
        // View Initialization
        let height: CGFloat = 80 + tabInsetHeight
        super.init(frame: CGRect(x: 0, y: 0, width: main.width, height: height))
        backgroundColor = .summaryBackgroundColor
        roundCorners(corners: [.topLeft, .topRight], radius: 16)

        // Create puller tab
        tab.center.x = center.x
        tab.backgroundColor = .mediumGrayColor
        tab.layer.cornerRadius = tab.frame.height / 2
        addSubview(tab)
        
        // Place and format top summary label
        mainLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        mainLabel.textColor = .primaryTextColor
        mainLabel.numberOfLines = 1
        mainLabel.allowsDefaultTighteningForTruncation = true
        mainLabel.lineBreakMode = .byTruncatingTail
        addSubview(mainLabel)
        
        // Place and format secondary label
        secondaryLabel.font = .systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        secondaryLabel.textColor = .mediumGrayColor
        addSubview(secondaryLabel)
        
        if route != nil {
            setRoute()
        }
            
    }
    
    /// Change the height of the view
    func setHeight(to newHeight: CGFloat) {
        frame.size.height = newHeight
        setRoute() // go back and adjust positions based on change
    }
    
    /// Update summary card data and position accordingly
    func setRoute() {
        
        /// Constant for spacing for various elements
        let spacing: CGFloat = 10
        /// The edge of the next bus icon
        var iconMaximumX: CGFloat = 20
        /// The center to use for the next bus icon. Initalized for one bus
        var iconCenter = CGPoint(x: iconMaximumX, y: safeAreaCenterY)
        
        // MARK: Route Icons
        
        subviews.filter { $0.tag == busIconTag }.removeViewsFromSuperview()
        
        // Create and place bus icons
        let busRoutes: [Int] = route.directions.flatMap { return $0.type == .depart ? $0.routeNumber : nil }
        
        // Place one sole bus icon
        if busRoutes.count == 1 {
            
            let busIcon = BusIcon(type: .directionLarge, number: busRoutes.first!)
            busIcon.tag = busIconTag
            iconCenter.x += busIcon.frame.width / 2
            busIcon.center = iconCenter
            iconMaximumX += busIcon.frame.width + spacing
            addSubview(busIcon)
            
        }
        
        // Place up to 2 bus icons. This will not support more buses without changes
        else {
            
            // Get starting y point above center line
            let initalY = safeAreaCenterY - spacing / 2 - BusIcon(type: .directionSmall, number: 0).frame.height
            iconCenter = CGPoint(x: iconMaximumX, y: initalY)
            
            for (index, route) in busRoutes.enumerated() {
                
                let busIcon = BusIcon(type: .directionSmall, number: route)
                busIcon.tag = busIconTag
                iconCenter.x += busIcon.frame.width + spacing
                busIcon.center = iconCenter
                iconMaximumX = busIcon.frame.width + spacing
                addSubview(busIcon)
                iconCenter.y += busIcon.frame.height + spacing

                // Stop once two buses have been placed
                if index == 1 { break }
                
            }
            
        }
        
        // MARK: Main Label Positioning

        mainLabel.frame.origin.x = iconMaximumX + textLabelPadding
        mainLabel.frame.size.width = frame.maxX - mainLabel.frame.origin.x - textLabelPadding
        
        if let departDirection = (route.directions.filter { $0.type == .depart }).first {
            mainLabel.text = "Depart at \(departDirection.startTimeDescription) from \(departDirection.name)"
        } else {
            mainLabel.text = route.directions.first?.locationNameDescription ?? "Route Directions"
        }
        
        // Calculate and adjust label based on number of lines
        let numOfLines = mainLabel.numberOfLines()
        // let difference = numOfLines - mainLabel.numberOfLines
        if numOfLines != mainLabel.numberOfLines {
            // let delta = CGFloat(difference) * mainLabel.font.lineHeight
            mainLabel.numberOfLines = numOfLines
            setHeight(to: frame.size.height)
        }
        
        // Reset main label positioning
        mainLabel.sizeToFit()
        mainLabel.frame.origin.x = iconMaximumX + textLabelPadding
        mainLabel.frame.size.width = frame.maxX - mainLabel.frame.origin.x - textLabelPadding
        
        // MARK: Secondary Label
        
        secondaryLabel.text = "Trip Duration: \(route.totalDuration) minute\(route.totalDuration == 1 ? "" : "s")"
        secondaryLabel.sizeToFit()
        secondaryLabel.frame.origin.x = iconMaximumX + textLabelPadding
        
        // Adjust labels vertically
        let labelSpacing = spacing / 3
        let totalLabelHeight = mainLabel.frame.size.height + secondaryLabel.frame.size.height + labelSpacing
        let maximumY = safeAreaCenterY + (totalLabelHeight / 2)
        secondaryLabel.frame.origin.y = maximumY - secondaryLabel.frame.height
        mainLabel.frame.origin.y = secondaryLabel.frame.origin.y - mainLabel.frame.height - (labelSpacing)
        
    }
    
}
