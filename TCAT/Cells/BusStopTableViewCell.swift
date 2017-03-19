//
//  BusStopTableViewCell.swift
//  TCAT
//
//  Created by Matthew Barker on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class BusStopTableViewCell: UITableViewCell {
    
    var titleLabel: UILabel!
    let cellHeight: CGFloat = 68
    
    var connectorTop: UIView!
    var connectorBottom: UIView!
    var statusCircle: DirectionCircle!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 160, y: 0, width: 20, height: 20)
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        titleLabel.textColor = UIColor(red: 74 / 255, green: 74 / 255, blue: 74 / 255, alpha: 1)
        titleLabel.text = "Bus Stop Name"
        titleLabel.sizeToFit()
        titleLabel.center.y = cellHeight / 2
        contentView.addSubview(titleLabel)
        
        connectorTop = UIView(frame: CGRect(x: 20, y: 0, width: 2, height: cellHeight / 2))
        connectorTop.frame.origin.x -= connectorTop.frame.width / 2
        connectorTop.backgroundColor = UIColor(red: 7 / 255, green: 157 / 255, blue: 220 / 255, alpha: 1)
        contentView.addSubview(connectorTop)
        
        connectorBottom = UIView(frame: CGRect(x: 20, y: cellHeight / 2, width: 2, height: cellHeight / 2))
        connectorBottom.frame.origin.x -= connectorBottom.frame.width / 2
        connectorBottom.backgroundColor = UIColor(red: 7 / 255, green: 157 / 255, blue: 220 / 255, alpha: 1)
        contentView.addSubview(connectorBottom)
        
        statusCircle = DirectionCircle(.busStop)
        statusCircle.center = self.center
        statusCircle.center.y = cellHeight / 2
        statusCircle.frame.origin.x = 20 - (statusCircle.frame.width / 2)
        contentView.addSubview(statusCircle)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("Something bad happened"); fatalError("init(coder:) has not been implemented")
    }
    
    func setCell(_ name: String) {

        titleLabel.text = name
        titleLabel.sizeToFit()
        
    }
    
    func getCellHeight() -> CGFloat { return cellHeight }
    
}
