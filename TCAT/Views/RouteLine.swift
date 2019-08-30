//
//  RouteLine.swift
//  TCAT
//
//  Created by Monica Ong on 5/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit

class RouteLine: UIView {

    // MARK: Size vars

    fileprivate let width: CGFloat = 4
    fileprivate var height: CGFloat = 20

    static let extendedHeight: CGFloat = 28

    // MARK: Constraint vars

    override var intrinsicContentSize: CGSize {
        return CGSize(width: width, height: height)
    }

    init(overrideHeight: CGFloat? = nil) {
        if let overrideHeight = overrideHeight {
            self.height = overrideHeight
        }
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

class SolidLine: RouteLine {

    init(overrideHeight: CGFloat? = nil, color: UIColor) {
        super.init(overrideHeight: overrideHeight)

        backgroundColor = color
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class DottedLine: RouteLine {

    // MARK: Init
    init(overrideHeight: CGFloat? = nil, color: UIColor) {
        super.init(overrideHeight: overrideHeight)

        let dashSize = CGSize(width: width, height: 3.75)
        let dashSpace: CGFloat = (height - dashSize.height * 2) / 3
        let numDashes = 2
        var prevDash: UIView?

        for _ in 0..<numDashes {
            let dash = UIView()

            dash.backgroundColor = color
            dash.layer.cornerRadius = dashSize.height / 2
            dash.clipsToBounds = true

            addSubview(dash)

            dash.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.size.equalTo(dashSize)

                if let prevDash = prevDash {
                    make.top.equalTo(prevDash.snp.bottom).offset(dashSpace)
                } else {
                    make.top.equalToSuperview().offset(dashSpace)
                }
            }

            prevDash = dash
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
