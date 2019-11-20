//
//  RoundedShadowView.swift
//  TCAT
//
//  Created by Omar Rasheed on 4/16/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

class RoundShadowedView: UIView {

    var containerView: UIView!

    init(cornerRadius: CGFloat) {
        super.init(frame: .zero)

        backgroundColor = .clear

        layer.shadowColor = Colors.secondaryText.cgColor
        layer.shadowOffset = CGSize(width: 0, height: cornerRadius / 4)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = cornerRadius / 4

        containerView = UIView()
        containerView.backgroundColor = .white

        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.masksToBounds = true

        addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func addSubview(_ view: UIView) {
        if view.isEqual(containerView) {
            super.addSubview(view)
        } else {
            containerView.addSubview(view)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
