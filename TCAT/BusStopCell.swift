//
//  BusStopCell.swift
//  TCAT
//
//  Created by Austin Astorga on 3/21/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class BusStopCell: UITableViewCell {

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
        
        imageView?.frame = CGRect(x: 10, y: 5, width: 20, height: 20)
        imageView?.contentMode = .scaleAspectFit
        imageView?.center.y = bounds.height / 2.0
        imageView?.image = #imageLiteral(resourceName: "bus")
        imageView?.tintColor = .tcatBlueColor
        
        textLabel?.frame = CGRect(x: 40, y: 0, width: frame.width - 45, height: 20)
        textLabel?.center.y = bounds.height / 2.0
        textLabel?.font = .systemFont(ofSize: 13)
    }

}
