//
//  WhatsNewPopupView.swift
//  TCAT
//
//  Created by Omar Rasheed on 9/26/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit
import SnapKit

protocol WhatsNewDelegate {
    func okButtonPressed()
    func cardPressed()
}

class WhatsNewHeaderView: UIView {

    var whatsNewDelegate: WhatsNewDelegate?
    var updateTitle: UILabel!
    var dismissButton: UIButton!
    var updateDescription: UILabel!
    var whatsNewHeader: UILabel!
    var backgroundView: UIView!
    let containerPadding = UIEdgeInsets(top: 16, left: 16, bottom: -32, right: 16)

    init (updateName: String, description: String) {
        super.init(frame: .zero)

        backgroundColor = .white

        layer.cornerRadius = 16
        clipsToBounds = true

        createUpdateDescription(description: description)
        createWhatsNewHeader()
        createUpdateTitle(updateName: updateName)
        createDismissButton()
    }

    func createWhatsNewHeader() {
        whatsNewHeader = UILabel()
        whatsNewHeader.text = "NEW IN ITHACA TRANSIT"
        whatsNewHeader.font = UIFont.style(Fonts.SanFrancisco.semibold, size: 12)
        whatsNewHeader.textColor = UIColor.tcatBlueColor

        addSubview(whatsNewHeader)
    }

    func createUpdateTitle(updateName: String) {
        updateTitle = UILabel()
        updateTitle.text = updateName
        updateTitle.font = UIFont.style(Fonts.SanFrancisco.Bold, size: 18)

        addSubview(updateTitle)
    }

    func createUpdateDescription (description: String) {
        updateDescription = UILabel()
        updateDescription.text = description
        updateDescription.font = UIFont.style(Fonts.SanFrancisco.Regular, size: 14)
        updateDescription.textColor = UIColor.mediumGrayColor
        updateDescription.numberOfLines = 0
        updateDescription.textAlignment = .center

        addSubview(updateDescription)
    }

    func createDismissButton() {
        dismissButton = UIButton()
        dismissButton.setTitle("OK", for: .normal)
        dismissButton.titleLabel?.font = UIFont.style(Fonts.SanFrancisco.Semibold, size: 14)
        dismissButton.addTarget(self, action: #selector(okButtonPressed), for: .touchUpInside)
        dismissButton.backgroundColor = UIColor.tcatBlueColor
        dismissButton.setTitleColor(.white, for: .normal)
        dismissButton.layer.cornerRadius = dismissButton.intrinsicContentSize.height/2
        dismissButton.clipsToBounds = true

        addSubview(dismissButton)
    }

    override func updateConstraints() {
        super.updateConstraints()

        whatsNewHeader.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(whatsNewHeader.intrinsicContentSize.height)
            make.width.equalTo(whatsNewHeader.intrinsicContentSize.width)
        }

        updateTitle.snp.makeConstraints { (make) in
            make.top.equalTo(whatsNewHeader.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(updateTitle.intrinsicContentSize.height)
            make.width.equalTo(updateTitle.intrinsicContentSize.width)
        }

        updateDescription.snp.makeConstraints { (make) in
            let leadingOffset = CGFloat(32)
            let trailingOffset = CGFloat(-32)
            make.top.equalTo(updateTitle.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(leadingOffset)
            make.trailing.equalToSuperview().offset(trailingOffset)
            if let containerView = superview,
                let tableView = containerView.superview,
                let wholeView = tableView.superview,
                let description = updateDescription.text {
                let totalWidthPadding = containerPadding.left + containerPadding.right + leadingOffset + trailingOffset
                make.height.equalTo(description.heightWithConstrainedWidth(width: wholeView.frame.width - totalWidthPadding, font: updateDescription.font))
            }
        }

        dismissButton.snp.makeConstraints { (make) in
            make.top.equalTo(updateDescription.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(dismissButton.intrinsicContentSize.height)
        }

        snp.makeConstraints { (make) in
            make.bottom.equalTo(dismissButton.snp.bottom).offset(16)
        }
    }

    @objc func okButtonPressed() {
        whatsNewDelegate?.okButtonPressed()
    }

    @objc func cardTapped() {
        whatsNewDelegate?.cardPressed()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
