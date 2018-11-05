//
//  SummaryView.swift
//  TCAT
//
//  Created by Matthew Barker on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class SummaryView: UIView {
    
    /// The route being used for the summary view
    var route: Route!
    
    /// The puller tab used to indicate dragability
    private var tab = UIView(frame: CGRect(x: 0, y: 6, width: 32, height: 4))
    
    /// Three times the height of the tab view (spacing + tabHeight + spacing)
    private var tabInsetHeight: CGFloat = 12
    
    /// The usable height of the summaryView
    var safeAreaHeight: CGFloat {
        return frame.size.height - tabInsetHeight
    }
    
    /// The y-coordinate center of the safe area
    var safeAreaCenterY: CGFloat {
        return tabInsetHeight + safeAreaHeight / 2
    }
    
    /// The primary summary label
    private var mainLabel = UILabel()
    
    /// The live indicator
    private var liveIndicator = LiveIndicator(size: .small, color: .clear)
    
    /// The secondary label (Trip Duration)
    private var secondaryLabel = UILabel()
    
    /// Whether route icons have been set or not
    private var didSetRoutes: Bool = false
    
    /// The device's bounds
    private var main = UIScreen.main.bounds
    /// Constant for label padding
    private let textLabelPadding: CGFloat = 16
    /// Identifier for bus route icons
    private let iconTag: Int = 14850
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        
        // View Initialization
        let height: CGFloat = 80 + tabInsetHeight
        super.init(frame: CGRect(x: 0, y: 0, width: main.width, height: height))
        backgroundColor = Colors.backgroundWash
        roundCorners(corners: [.topLeft, .topRight], radius: 16)

        // Create puller tab
        tab.center.x = center.x
        tab.backgroundColor = Colors.metadataIcon
        tab.layer.cornerRadius = tab.frame.height / 2
        addSubview(tab)
        
        // Place and format top summary label
        mainLabel.font = .style(Fonts.SanFrancisco.regular, size: 16)
        mainLabel.textColor = Colors.primaryText
        mainLabel.numberOfLines = 1
        mainLabel.allowsDefaultTighteningForTruncation = true
        mainLabel.lineBreakMode = .byTruncatingTail
        addSubview(mainLabel)
        
        // Place and format secondary label
        secondaryLabel.font = .style(Fonts.SanFrancisco.regular, size: 12)
        secondaryLabel.textColor = Colors.metadataIcon
        addSubview(secondaryLabel)
        
        addSubview(liveIndicator)
            
    }
    
    /// Update summary card data and position accordingly
    func setRoute() {

        setBusIcons()
        
        var color: UIColor = Colors.primaryText
        
        // MARK: Main Label and Live Indicator Formatting
        
        let space = createStringWithSpaces()
        let extraLabelPadding: CGFloat = 6
        
        mainLabel.frame.origin.x = DetailIconView.width + extraLabelPadding
        mainLabel.frame.size.width = frame.maxX - mainLabel.frame.origin.x - textLabelPadding
        let mainLabelBoldFont: UIFont = .style(Fonts.SanFrancisco.semibold, size: 14)
        
        if let departDirection = (route.directions.filter { $0.type == .depart }).first {
            
            var fragment = ""
            
            if let delay = departDirection.delay {
                fragment = " \(space)" // Include space for live indicator
                if delay >= 60 {
                    color = Colors.lateRed
                } else {
                    color = Colors.liveGreen
                }
            } else {
                liveIndicator.setColor(to: .clear)
                color = Colors.primaryText
            }
            
            let content = "Depart at \(departDirection.startTimeWithDelayDescription)\(fragment) from \(departDirection.name)"
            // This changes font to standard size. Label's font is different.
            var attributedString = departDirection.startTimeWithDelayDescription.bold(
                                       in: content,
                                       from: mainLabel.font,
                                       to: mainLabelBoldFont)
            attributedString = departDirection.name.bold(in: attributedString, to: mainLabelBoldFont)
            
            let range = (attributedString.string as NSString).range(of: departDirection.startTimeWithDelayDescription)
            attributedString.addAttribute(.foregroundColor, value: color, range: range)
            
            mainLabel.attributedText = attributedString
            
            // Find time within label to place live indicator
            if let stringRect = mainLabel.boundingRect(of: departDirection.startTimeWithDelayDescription + " ") {
                liveIndicator.frame.origin.x = mainLabel.frame.minX + stringRect.maxX
                liveIndicator.center.y = mainLabel.frame.minY + stringRect.midY
                liveIndicator.setColor(to: departDirection.delay == nil ? .clear : color)
            } else {
                print("[SummaryView] Could not find phrase in label")
                liveIndicator.setColor(to: .clear)
            }
            
            
        } else {
            let content = route.directions.first?.locationNameDescription ?? "Route Directions"
            let pattern = route.directions.first?.name ?? ""
            mainLabel.attributedText = pattern.bold(in: content, from: mainLabel.font, to: mainLabelBoldFont)
        }
        
        // Calculate and adjust label based on number of lines
        let numOfLines = mainLabel.numberOfLines()
        if numOfLines != mainLabel.numberOfLines {
            mainLabel.numberOfLines = numOfLines
        }
        
        // Reset main label positioning
        mainLabel.sizeToFit()
        mainLabel.frame.origin.x = DetailIconView.width + extraLabelPadding
        mainLabel.frame.size.width = frame.maxX - mainLabel.frame.origin.x - textLabelPadding
        
        // MARK: Secondary Label
        
        secondaryLabel.text = "Trip Duration: \(route.totalDuration) minute\(route.totalDuration == 1 ? "" : "s")"
        secondaryLabel.sizeToFit()
        secondaryLabel.frame.origin.x = mainLabel.frame.origin.x
        
        adjustLabelPositions()
        
    }
    
    // Create string with enough space for Live Indicator
    func createStringWithSpaces() -> String {
        let testLabel = UILabel()
        testLabel.font = mainLabel.font
        testLabel.text = " "
        testLabel.sizeToFit()
        let sizeOfSpace = testLabel.frame.size.width
        var space = ""
        let numberOfSpaces = Int(ceil(liveIndicator.frame.size.width / sizeOfSpace))
        for _ in 1...numberOfSpaces {
            space += " "
        }
        return space
    }
    
    func adjustLabelPositions() {
        // Adjust labels vertically
        let labelSpacing: CGFloat = 4
        let totalLabelHeight = mainLabel.frame.size.height + secondaryLabel.frame.size.height + labelSpacing
        let maximumY = safeAreaCenterY + (totalLabelHeight / 2)
        secondaryLabel.frame.origin.y = maximumY - secondaryLabel.frame.height
        mainLabel.frame.origin.y = secondaryLabel.frame.origin.y - mainLabel.frame.height - (labelSpacing)
    }
    
    /// Add and place bus icons.
    func setBusIcons() {
        
        let spacing: CGFloat = 12
        
        /// The center to use for the next bus icon. Initalized for 0-1 bus(es).
        var iconCenter = CGPoint(x: DetailIconView.width / 2, y: safeAreaCenterY)
        
        subviews.filter { $0.tag == iconTag }.removeViewsFromSuperview()
        
        // Create and place bus icons
        let busRoutes: [Int] = route.directions.compactMap {
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
            walkIcon.tintColor = Colors.metadataIcon
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
        
    }
    
}
