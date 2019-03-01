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
}

class WhatsNewHeaderView: UIView {

    var whatsNewDelegate: WhatsNewDelegate?
    
    var updateTitle: UILabel!
    var dismissButton: UIButton!
    var updateDescription: UILabel!
    var whatsNewHeader: UILabel!
    var backgroundView: UIView!
    
    private var titleToTop: Constraint?
    private var updateNameToTitle: Constraint?
    private var updateDescToUpdateName: Constraint?
    private var dismissButtonToUpdateDesc: Constraint?
    private var dismissButtonToBottom: Constraint?
    private var updateDescriptionHeight: CGFloat = 0
    
    let containerPadding = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)

    init(updateName: String, description: String) {
        super.init(frame: .zero)

        backgroundColor = Colors.white
        layer.cornerRadius = 16
        clipsToBounds = true

        createUpdateDescription(description: description)
        createWhatsNewHeader()
        createUpdateTitle(title: updateName)
        createDismissButton()
    }

    func createWhatsNewHeader() {
        whatsNewHeader = UILabel()
        whatsNewHeader.text = "NEW IN ITHACA TRANSIT"
        whatsNewHeader.font = .getFont(.semibold, size: 12)
        whatsNewHeader.textColor = Colors.tcatBlue

        addSubview(whatsNewHeader)
    }

    func createUpdateTitle(title: String) {
        updateTitle = UILabel()
        updateTitle.text = title
        updateTitle.font = .getFont(.bold, size: 18)

        addSubview(updateTitle)
    }

    func createUpdateDescription(description: String) {
        updateDescription = UILabel()
        updateDescription.text = description
        updateDescription.font = .getFont(.regular, size: 14)
        updateDescription.textColor = Colors.metadataIcon
        updateDescription.numberOfLines = 0
        updateDescription.textAlignment = .center

        addSubview(updateDescription)
    }

    func createDismissButton() {
        dismissButton = UIButton()
        dismissButton.setTitle("OK", for: .normal)
        dismissButton.titleLabel?.font = .getFont(.semibold, size: 14)
        dismissButton.addTarget(self, action: #selector(okButtonPressed), for: .touchUpInside)
        dismissButton.backgroundColor = Colors.tcatBlue
        dismissButton.setTitleColor(Colors.white, for: .normal)
        dismissButton.layer.cornerRadius = dismissButton.intrinsicContentSize.height/2
        dismissButton.clipsToBounds = true

        addSubview(dismissButton)
        
        setupConstraints()
    }

    func setupConstraints() {

        whatsNewHeader.snp.makeConstraints { (make) in
            titleToTop = make.top.equalToSuperview().offset(16).constraint
            make.centerX.equalToSuperview()
            make.height.equalTo(whatsNewHeader.intrinsicContentSize.height)
            make.width.equalTo(whatsNewHeader.intrinsicContentSize.width)
        }

        updateTitle.snp.makeConstraints { (make) in
            updateNameToTitle = make.top.equalTo(whatsNewHeader.snp.bottom).offset(8).constraint
            make.centerX.equalToSuperview()
            make.height.equalTo(updateTitle.intrinsicContentSize.height)
            make.width.equalTo(updateTitle.intrinsicContentSize.width)
        }

        updateDescription.snp.makeConstraints { (make) in
            let value = CGFloat(32)
            updateDescToUpdateName = make.top.equalTo(updateTitle.snp.bottom).offset(6).constraint
            make.leading.trailing.equalToSuperview().inset(value)
            if let description = updateDescription.text
            {
                // Take total width and subtract various insets used in layout
                let headerViewCardPadding = containerPadding.left + containerPadding.right
                let widthValue = UIScreen.main.bounds.width - headerViewCardPadding - (value * 2)
                
                let heightValue = ceil(description.heightWithConstrainedWidth(width: widthValue, font: updateDescription.font))
                updateDescriptionHeight = ceil(heightValue)
                make.height.equalTo(ceil(heightValue))
            }
        }

        dismissButton.snp.makeConstraints { (make) in
            dismissButtonToUpdateDesc = make.top.equalTo(updateDescription.snp.bottom).offset(12).constraint
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            dismissButtonToBottom = make.bottom.equalToSuperview().inset(16).constraint
        }
    }
    
    func calculateCardHeight() -> CGFloat {
        if let titleToTop = titleToTop, let updateNameToTitle = updateNameToTitle, let updateDescToUpdateName = updateDescToUpdateName, let dismissButtonToUpdateDesc = dismissButtonToUpdateDesc, let dismissButtonToBottom = dismissButtonToBottom {
            
            let titleToTopVal = titleToTop.layoutConstraints[0].constant
            let titleHeight = whatsNewHeader.intrinsicContentSize.height
            
            let titleSpace = titleToTopVal + titleHeight
            
            let updateNameToTitleVal = updateNameToTitle.layoutConstraints[0].constant
            let updateNameHeight = updateTitle.intrinsicContentSize.height
            
            let updateNameSpace = updateNameToTitleVal + updateNameHeight
            
            let updateDescToUpdateNameVal = updateDescToUpdateName.layoutConstraints[0].constant
            
            let updateDescSpace = updateDescToUpdateNameVal + updateDescriptionHeight
            
            let dismissButtonToUpdateDescVal = dismissButtonToUpdateDesc.layoutConstraints[0].constant
            let dismissButtonHeight = dismissButton.intrinsicContentSize.height
            
            let dismissButtonSpace = dismissButtonToUpdateDescVal + dismissButtonHeight
            
            let bottomOffset = -dismissButtonToBottom.layoutConstraints[0].constant
            
            return ceil(titleSpace + updateNameSpace + updateDescSpace + dismissButtonSpace + bottomOffset)
        } else {
            return 0
        }
    }

    @objc func okButtonPressed() {
        whatsNewDelegate?.okButtonPressed()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
