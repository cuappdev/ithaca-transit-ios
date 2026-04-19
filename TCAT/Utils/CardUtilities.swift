//
//  CardUtilities.swift
//  TCAT
//
//  Created by Gabriel Castillo on 4/19/26.
//  Copyright © 2026 cuappdev. All rights reserved.
//

import UIKit

/// Passes touches through to the map for any region not occupied by a subview.
class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        return hit == self ? nil : hit
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
