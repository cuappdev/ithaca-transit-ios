//
//  LoadingIndicator.swift
//  LoadingIndicator
//
//  Created by Rob Phillips on 11/8/17.
//  Copyright © 201 cuappdev. All rights reserved.
//
//  See LICENSE for full license agreement.
//

import UIKit

class LoadingIndicator: RPCircularProgress {
    
    required init() {
        super.init()
        
        enableIndeterminate()
        trackTintColor = .mediumGrayColor
        progressTintColor = .searchBarPlaceholderTextColor
        thicknessRatio = 0.25
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
