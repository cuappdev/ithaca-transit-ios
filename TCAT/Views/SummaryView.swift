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
    
    /// The live indicator
    fileprivate var liveIndicator = LiveIndicator(size: .small, color: .clear)
    
    /// The secondary label (Trip Duration)
    fileprivate var secondaryLabel = UILabel()
    
    /// Whether route icons have been set or not
    fileprivate var didSetRoutes: Bool = false
    
    /// The device's bounds
    fileprivate var main = UIScreen.main.bounds
    /// Constant for label padding
    fileprivate let textLabelPadding: CGFloat = 16
    /// Identifier for bus route icons
    fileprivate let iconTag: Int = 14850
    
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
        
        // MARK: Route Icons
        
        /// Constant for spacing for various elements
        let spacing: CGFloat = 12
        
        /// The center to use for the next bus icon. Initalized for 0-1 bus(es).
        var iconCenter = CGPoint(x: DetailIconView.width / 2, y: safeAreaCenterY)
        
        subviews.filter { $0.tag == iconTag }.removeViewsFromSuperview()
        
        // Create and place bus icons
        let busRoutes: [Int] = route.directions.flatMap {
            return $0.type == .depart ? $0.routeNumber : nil
        }
        
        // Show walking glyph
        if busRoutes.count == 0 {
            
            // Create and add bus icon
            let walkIcon = UIImageView(image: #imageLiteral(resourceName: "walk"))
            walkIcon.tag = iconTag
            walkIcon.contentMode = .scaleAspectFit
            // Ideally, have a larger higher-res version for this. But we need to release.
            walkIcon.frame.size = CGSize(width: walkIcon.frame.size.width * 2, height: walkIcon.frame.size.height * 2)
            walkIcon.tintColor = .mediumGrayColor
            walkIcon.center = iconCenter
            addSubview(walkIcon)
            
        }
        
        // Place one sole bus icon
        else if busRoutes.count == 1 {
            
            // Create and add bus icon
            let busIcon = BusIcon(type: .directionLarge, number: busRoutes.first!)
            busIcon.tag = iconTag
            busIcon.center = iconCenter
            addSubview(busIcon)
            
        }
        
        // Place up to 2 bus icons. This will not support more buses without changes
        else {
            
            // Adjust initial variables
            let exampleBusIcon = BusIcon(type: .directionSmall, number: 0)
            iconCenter.y = tabInsetHeight + safeAreaCenterY - (spacing / 4) - exampleBusIcon.frame.height
            
            for (index, route) in busRoutes.enumerated() {
                
                // Create and add bus icon
                let busIcon = BusIcon(type: .directionSmall, number: route)
                busIcon.tag = iconTag
                busIcon.center = iconCenter
                addSubview(busIcon)
                
                // Adjust center point
                iconCenter.y += busIcon.frame.height + (spacing / 2)

                // Stop once two buses have been placed
                if index == 1 { break }
                
            }
            
        }
        
        // MARK: Labels
        
        var color: UIColor = .primaryTextColor
        
        // Create space for Live Indicator
        let testLabel = UILabel()
        testLabel.text = " "
        testLabel.sizeToFit()
        let sizeOfSpace = testLabel.frame.size.width
        var space = ""
        let numberOfSpaces = Int(ceil(liveIndicator.frame.size.width / sizeOfSpace))
        for _ in 1...numberOfSpaces {
            space += " "
        }
        
        // MARK: Main Label and Live Indicator Formatting
        
        let extraLabelPadding: CGFloat = 6
        
        mainLabel.frame.origin.x = DetailIconView.width + extraLabelPadding
        mainLabel.frame.size.width = frame.maxX - mainLabel.frame.origin.x - textLabelPadding
        
        if let departDirection = (route.directions.filter { $0.type == .depart }).first {
            
            var fragment = ""
            
            if let delay = departDirection.delay {
                fragment = " \(space)" // Include space for live indicator
                if delay >= 60 {
                    color = .liveRedColor
                } else {
                    color = .liveGreenColor
                }
                
                liveIndicator.setColor(to: color)
                
            } else {
                liveIndicator.setColor(to: .clear)
            }
            
            let content = "Depart at \(departDirection.startTimeWithDelayDescription)\(fragment) from \(departDirection.name)"
            // This changes font to standard size. Label's font is different.
            var attributedString = bold(pattern: departDirection.startTimeWithDelayDescription, in: content)
            attributedString = bold(pattern: departDirection.name, in: attributedString)
            
            let range = (attributedString.string as NSString).range(of: departDirection.startTimeWithDelayDescription)
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
            
            mainLabel.attributedText = attributedString
            
            if let stringRect = mainLabel.boundingRect(of: departDirection.startTimeWithDelayDescription + " ") {
                liveIndicator.frame.origin.x = stringRect.maxX
                liveIndicator.center.y = stringRect.midY
            } else {
                print("Couldn't find rectangle :/")
            }
            
        } else {
            let content = route.directions.first?.locationNameDescription ?? "Route Directions"
            mainLabel.attributedText = bold(pattern: route.directions.first?.name ?? "", in: content)
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
        mainLabel.frame.origin.x = DetailIconView.width + extraLabelPadding
        mainLabel.frame.size.width = frame.maxX - mainLabel.frame.origin.x - textLabelPadding
        
        // MARK: Secondary Label
        
        secondaryLabel.text = "Trip Duration: \(route.totalDuration) minute\(route.totalDuration == 1 ? "" : "s")"
        secondaryLabel.sizeToFit()
        secondaryLabel.frame.origin.x = mainLabel.frame.origin.x
        
        // Adjust labels vertically
        let labelSpacing = spacing / 3
        let totalLabelHeight = mainLabel.frame.size.height + secondaryLabel.frame.size.height + labelSpacing
        let maximumY = safeAreaCenterY + (totalLabelHeight / 2)
        secondaryLabel.frame.origin.y = maximumY - secondaryLabel.frame.height
        mainLabel.frame.origin.y = secondaryLabel.frame.origin.y - mainLabel.frame.height - (labelSpacing)
        
    }
    
}
