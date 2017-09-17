//
//  SearchResultsCell.swift
//  TCAT
//
//  Created by Austin Astorga on 3/22/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class SearchResultsCell: UITableViewCell {
    let labelWidthConstant: CGFloat = 45.0
    let labelXPosition: CGFloat = 40.0
    let imageHeight: CGFloat = 20.0
    let imageWidth: CGFloat = 20.0
    let labelHeight: CGFloat = 20.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
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
        imageView?.image = reuseIdentifier == "cornellDestinations" ? #imageLiteral(resourceName: "bus") : #imageLiteral(resourceName: "pin")
        imageView?.tintColor = reuseIdentifier == "cornellDestinations" ? .tcatBlueColor : nil
        
        textLabel?.frame = CGRect(x: labelXPosition, y: 8.0, width: frame.width - labelWidthConstant, height: labelHeight)
        textLabel?.font = .systemFont(ofSize: 13)
        
        detailTextLabel?.frame = CGRect(x: labelXPosition, y: 0, width: frame.width - labelWidthConstant, height: labelHeight)
        detailTextLabel?.center.y = bounds.height - 15.0
        detailTextLabel?.textColor = .mediumGrayColor
        detailTextLabel?.font = .systemFont(ofSize: 12)
    }
}
