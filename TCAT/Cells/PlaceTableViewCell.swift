//
//  SearchResultsCell.swift
//  TCAT
//
//  Created by Austin Astorga on 3/22/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    
    var place: Place?
    
    let labelWidthPadding: CGFloat = 45.0
    let labelXPosition: CGFloat = 40.0
    
    let imageHeight: CGFloat = 20.0
    let imageWidth: CGFloat = 20.0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        imageView?.image = reuseIdentifier == Constants.Cells.currentLocationIdentifier ? #imageLiteral(resourceName: "location") : #imageLiteral(resourceName: "pin")
        imageView?.tintColor = place?.type == .busStop ? Colors.tcatBlue : Colors.metadataIcon
        
        textLabel?.frame.origin.x = labelXPosition
        textLabel?.frame.size.width = frame.width - labelWidthPadding
        textLabel?.font = .getFont(.regular, size: 13)

        detailTextLabel?.frame.origin.x = labelXPosition
        detailTextLabel?.frame.size.width = frame.width - labelWidthPadding
        detailTextLabel?.textColor = Colors.metadataIcon
        detailTextLabel?.font = .getFont(.regular, size: 12)
        
    }
}
