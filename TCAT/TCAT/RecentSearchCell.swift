//
//  RecentSearchCell.swift
//  TCAT
//
//  Created by Austin Astorga on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class RecentSearchCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView?.frame = CGRect(x: 10, y: 5, width: 20, height: 20)
        self.imageView?.contentMode = .scaleAspectFit
        self.imageView?.center.y = self.bounds.height / 2.0
        
        self.textLabel?.frame = CGRect(x: 40, y: 0, width: self.frame.width - 45, height: 20)
        self.textLabel?.center.y = self.bounds.height / 2.0
        self.textLabel?.font = UIFont.systemFont(ofSize: 13)
        
    }
    
}
