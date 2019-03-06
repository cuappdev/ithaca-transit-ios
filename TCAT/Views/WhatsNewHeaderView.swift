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
    func dismissView()
}

class WhatsNewHeaderView: UIView {

    var whatsNewDelegate: WhatsNewDelegate?
    var card: WhatsNewCard
    
    // e.g. "New In Ithaca Transit" blue label
    var smallHeaderLabel: UILabel!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    
    var buttonContainerView: UIView!
    var primaryButton: UIButton!
    var secondaryButton: UIButton?
    
    private var titleToTop: Constraint?
    private var updateNameToTitle: Constraint?
    private var updateDescToUpdateName: Constraint?
    private var buttonToUpdateDesc: Constraint?
    private var buttonToBottom: Constraint?
    private var updateDescriptionHeight: Constraint?
    
    let containerPadding = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
    
    init(card: WhatsNewCard) {
        self.card = card
        
        super.init(frame: .zero)
        backgroundColor = Colors.white
        layer.cornerRadius = 16
        clipsToBounds = true
        
        createWhatsNewHeader()
        createUpdateTitle(title: card.title)
        createUpdateDescription(desc: card.description)
        createButtonContainerView()
        createPrimaryActionButton()
        createSecondaryActionButton()
        
        setupConstraints()
    }

    func createWhatsNewHeader() {
        smallHeaderLabel = UILabel()
        smallHeaderLabel.text = card.label.uppercased()
        smallHeaderLabel.font = .getFont(.semibold, size: 12)
        smallHeaderLabel.textColor = Colors.tcatBlue

        addSubview(smallHeaderLabel)
    }

    func createUpdateTitle(title: String) {
        titleLabel = UILabel()
        titleLabel.text = card.title
        titleLabel.font = .getFont(.bold, size: 18)

        addSubview(titleLabel)
    }

    func createUpdateDescription(desc: String) {
        descriptionLabel = UILabel()
        descriptionLabel.text = card.description
        descriptionLabel.font = .getFont(.regular, size: 14)
        descriptionLabel.textColor = Colors.metadataIcon
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.isUserInteractionEnabled = true
        
        addSubview(descriptionLabel)
    }
    
    func createButtonContainerView() {
        buttonContainerView = UIView()
        addSubview(buttonContainerView)
    }

    func createPrimaryActionButton() {
        guard let title = card.primaryActionTitle else { return }
        primaryButton = UIButton()
        primaryButton.setTitle(title, for: .normal)
        primaryButton.titleLabel?.font = .getFont(.semibold, size: 14)
        primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        primaryButton.backgroundColor = Colors.tcatBlue
        primaryButton.setTitleColor(Colors.white, for: .normal)
        primaryButton.layer.cornerRadius = primaryButton.intrinsicContentSize.height / 2
        primaryButton.clipsToBounds = true

        buttonContainerView.addSubview(primaryButton)
    }
    
    func createSecondaryActionButton() {
        guard let title = card.secondaryActionTitle else { return }
        let secondaryButton = UIButton()
        secondaryButton.setTitle(title, for: .normal)
        secondaryButton.titleLabel?.font = .getFont(.medium, size: 14)
        secondaryButton.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
        secondaryButton.backgroundColor = Colors.metadataIcon
        secondaryButton.setTitleColor(Colors.white, for: .normal)
        secondaryButton.layer.cornerRadius = secondaryButton.intrinsicContentSize.height / 2
        secondaryButton.clipsToBounds = true
        
        buttonContainerView.addSubview(secondaryButton)
        
        self.secondaryButton = secondaryButton
    }

    func setupConstraints() {
        
        let titleToTopPadding: CGFloat = 16

        smallHeaderLabel.snp.makeConstraints { (make) in
            titleToTop = make.top.equalToSuperview().offset(titleToTopPadding).constraint
            make.centerX.equalToSuperview()
            make.height.equalTo(smallHeaderLabel.intrinsicContentSize.height)
            make.width.equalTo(smallHeaderLabel.intrinsicContentSize.width)
        }
        
        let labelToTitlePadding: CGFloat = 8

        titleLabel.snp.makeConstraints { (make) in
            updateNameToTitle = make.top.equalTo(smallHeaderLabel.snp.bottom).offset(labelToTitlePadding).constraint
            make.centerX.equalToSuperview()
            make.height.equalTo(titleLabel.intrinsicContentSize.height)
            make.width.equalTo(titleLabel.intrinsicContentSize.width)
        }
        
        let titletoDescriptionPadding: CGFloat = 6
        let descriptionInset: CGFloat = 32

        descriptionLabel.snp.makeConstraints { (make) in
            updateDescToUpdateName = make.top.equalTo(titleLabel.snp.bottom).offset(titletoDescriptionPadding).constraint
            make.leading.trailing.equalToSuperview().inset(descriptionInset)
            if let description = descriptionLabel.text {
                // Take total width and subtract various insets used in layout
                let headerViewCardPadding = containerPadding.left + containerPadding.right
                let widthValue = UIScreen.main.bounds.width - headerViewCardPadding - (descriptionInset * 2)
                let heightValue = ceil(description.heightWithConstrainedWidth(width: widthValue, font: descriptionLabel.font))
                updateDescriptionHeight = make.height.equalTo(ceil(heightValue)).constraint
            }
        }
        
        let descriptionToButtonPadding: CGFloat = 12
        let buttonToBottomPadding: CGFloat = 16
        
        buttonContainerView.snp.makeConstraints { (make) in
            buttonToUpdateDesc = make.top.equalTo(descriptionLabel.snp.bottom).offset(descriptionToButtonPadding).constraint
            buttonToBottom = make.bottom.equalToSuperview().inset(buttonToBottomPadding).constraint
            make.centerX.equalToSuperview()
        }

        // Padding for space between buttons
        let buttonWidthPadding: CGFloat = (secondaryButton != nil) ? 16 : 0
        let buttonWidth: CGFloat = 80
        
        primaryButton.snp.makeConstraints { (make) in
            make.centerY.top.bottom.right.equalToSuperview()
            make.width.equalTo(buttonWidth)
        }
        
        secondaryButton?.snp.makeConstraints { (make) in
            make.centerY.top.bottom.left.equalToSuperview()
            make.width.equalTo(buttonWidth)
            make.right.equalTo(primaryButton.snp.left).offset(-buttonWidthPadding)
        }

    }
    
    func calculateCardHeight() -> CGFloat {
        guard
            let titleToTop = titleToTop,
            let updateNameToTitle = updateNameToTitle,
            let updateDescToUpdateName = updateDescToUpdateName,
            let updateDescriptionHeight = updateDescriptionHeight,
            let dismissButtonToUpdateDesc = buttonToUpdateDesc,
            let dismissButtonToBottom = buttonToBottom
            else {
                return 0
        }
            
        let titleToTopVal = titleToTop.layoutConstraints[0].constant
        let titleHeight = smallHeaderLabel.intrinsicContentSize.height
        
        let titleSpace = titleToTopVal + titleHeight
        
        let updateNameToTitleVal = updateNameToTitle.layoutConstraints[0].constant
        let updateNameHeight = titleLabel.intrinsicContentSize.height
        
        let updateNameSpace = updateNameToTitleVal + updateNameHeight
        
        let updateDescToUpdateNameVal = updateDescToUpdateName.layoutConstraints[0].constant
        let updateDescHeight = updateDescriptionHeight.layoutConstraints[0].constant
        
        let updateDescSpace = updateDescToUpdateNameVal + updateDescHeight
        
        let dismissButtonToUpdateDescVal = dismissButtonToUpdateDesc.layoutConstraints[0].constant
        let buttonHeight = primaryButton.intrinsicContentSize.height
        
        let dismissButtonSpace = dismissButtonToUpdateDescVal + buttonHeight
        
        let bottomOffset = -dismissButtonToBottom.layoutConstraints[0].constant
        
        return ceil(titleSpace + updateNameSpace + updateDescSpace + dismissButtonSpace + bottomOffset)
    }
    
    @objc func primaryButtonTapped() {
        if let link = card.primaryActionWebLink {
            open(link, optionalAppLink: card.primaryActionAppLink) {
                self.whatsNewDelegate?.dismissView()
            }
        } else {
            self.whatsNewDelegate?.dismissView()
        }
    }
    
    @objc func secondaryButtonTapped() {
        if let link = card.secondaryActionWebLink {
            open(link, optionalAppLink: card.secondaryActionAppLink) {
                self.whatsNewDelegate?.dismissView()
            }
        } else {
            self.whatsNewDelegate?.dismissView()
        }
    }
    
    func open(_ link: String, optionalAppLink: String?, linkOpened: @escaping (() -> Void)) {
        if
            let appLink = optionalAppLink,
            let appURL = URL(string: appLink),
            UIApplication.shared.canOpenURL(appURL)
        {
            // Open link in an installed app.
            UIApplication.shared.open(appURL, options: [:]) { _ in
                linkOpened()
            }
        }
        
        else if let webURL = URL(string: link) {
            // Open link in Safari.
            UIApplication.shared.open(webURL, options: [:]) { _ in
                linkOpened()
            }
        }
    }

    @objc func dismissButtonPressed() {
        whatsNewDelegate?.dismissView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
