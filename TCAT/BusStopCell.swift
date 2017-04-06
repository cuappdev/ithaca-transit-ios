//
//  BusStopCell.swift
//  TCAT
//
//  Created by Austin Astorga on 3/21/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class BusStopCell: UITableViewCell {
    let labelWidthConstant = 45
    let labelXPosition = 40
    let imageHeight = 20
    let imageWidth = 20
    let labelHeight = 20
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView?.frame = CGRect(x: 10, y: 5, width: imageWidth, height: imageHeight)
        imageView?.contentMode = .scaleAspectFit
        imageView?.center.y = bounds.height / 2.0
        imageView?.image = #imageLiteral(resourceName: "bus")
        imageView?.tintColor = .tcatBlueColor
        
        textLabel?.frame = CGRect(x: labelXPosition, y: 0, width: frame.width - labelWidthConstant, height: labelHeight)
        textLabel?.center.y = bounds.height / 2.0
        textLabel?.font = .systemFont(ofSize: 13)
    }

}
