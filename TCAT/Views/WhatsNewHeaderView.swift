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
    
    var descHasHyperLink: Bool = false
    var hyperLinkText: String? = nil
    var appLink: String? = nil
    var webLink: String? = nil
    
    private var titleToTop: Constraint?
    private var updateNameToTitle: Constraint?
    private var updateDescToUpdateName: Constraint?
    private var dismissButtonToUpdateDesc: Constraint?
    private var dismissButtonToBottom: Constraint?
    private var updateDescriptionHeight: Constraint?
    
    let containerPadding = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)

    init(updateName: String, description: String,
         descHasHyperLink: Bool = false,
         hyperLinkText: String? = nil,
         appLink: String? = nil,
         webLink: String? = nil) {
        super.init(frame: .zero)

        backgroundColor = Colors.white
        layer.cornerRadius = 16
        clipsToBounds = true
        
        if descHasHyperLink {
            self.descHasHyperLink = descHasHyperLink
            self.hyperLinkText = hyperLinkText
            self.webLink = webLink
            self.appLink = appLink
        }

        createUpdateDescription(desc: description)
        createWhatsNewHeader()
        createUpdateTitle(title: updateName)
        createDismissButton()
    }

    func createWhatsNewHeader() {
        whatsNewHeader = UILabel()
        whatsNewHeader.text = Constants.WhatsNew.whatsNewHeaderTitle
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

    func createUpdateDescription(desc: String) {
        updateDescription = UILabel()
        updateDescription.font = .getFont(.regular, size: 14)
        updateDescription.textColor = Colors.metadataIcon
        updateDescription.numberOfLines = 0
        updateDescription.textAlignment = .center
        updateDescription.isUserInteractionEnabled = true
        
        if descHasHyperLink {
            addHyperLink(description: desc)
        } else {
            updateDescription.text = description
        }

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
                updateDescriptionHeight = make.height.equalTo(ceil(heightValue)).constraint
            }
        }

        dismissButton.snp.makeConstraints { (make) in
            dismissButtonToUpdateDesc = make.top.equalTo(updateDescription.snp.bottom).offset(12).constraint
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            dismissButtonToBottom = make.bottom.equalToSuperview().inset(16).constraint
        }
    }
    
    func addHyperLink(description: String) {
        if let hyperLinkText = hyperLinkText {
            let attributedString = NSMutableAttributedString(string: description)
            
            // Highlight the hyperlink in tcatBlue
            var range1 = (description as NSString).range(of: hyperLinkText)
            range1.location -= 1
            range1.length += 1 // These two lines are to take into account the "@"
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.tcatBlue, range: range1)
            updateDescription.attributedText = attributedString
            
            // Make it tappable
            let linkTappedRecognizer = UITapGestureRecognizer()
            linkTappedRecognizer.addTarget(self, action: #selector(labelTapped))
            updateDescription.addGestureRecognizer(linkTappedRecognizer)
        }
    }
    
    func calculateCardHeight() -> CGFloat {
        if let titleToTop = titleToTop, let updateNameToTitle = updateNameToTitle, let updateDescToUpdateName = updateDescToUpdateName, let updateDescriptionHeight = updateDescriptionHeight, let dismissButtonToUpdateDesc = dismissButtonToUpdateDesc, let dismissButtonToBottom = dismissButtonToBottom {
            
            let titleToTopVal = titleToTop.layoutConstraints[0].constant
            let titleHeight = whatsNewHeader.intrinsicContentSize.height
            
            let titleSpace = titleToTopVal + titleHeight
            
            let updateNameToTitleVal = updateNameToTitle.layoutConstraints[0].constant
            let updateNameHeight = updateTitle.intrinsicContentSize.height
            
            let updateNameSpace = updateNameToTitleVal + updateNameHeight
            
            let updateDescToUpdateNameVal = updateDescToUpdateName.layoutConstraints[0].constant
            let updateDescHeight = updateDescriptionHeight.layoutConstraints[0].constant
            
            let updateDescSpace = updateDescToUpdateNameVal + updateDescHeight
            
            let dismissButtonToUpdateDescVal = dismissButtonToUpdateDesc.layoutConstraints[0].constant
            let dismissButtonHeight = dismissButton.intrinsicContentSize.height
            
            let dismissButtonSpace = dismissButtonToUpdateDescVal + dismissButtonHeight
            
            let bottomOffset = -dismissButtonToBottom.layoutConstraints[0].constant
            
            return ceil(titleSpace + updateNameSpace + updateDescSpace + dismissButtonSpace + bottomOffset)
        } else {
            return 0
        }
    }

    @objc func labelTapped(gesture: UITapGestureRecognizer) {
        if let hyperLinkText = hyperLinkText, let text = updateDescription.text, let range = text.range(of: hyperLinkText) {
            let linkRange = text.nsRange(from: range)
            if gesture.didTapAttributedTextInLabel(label: updateDescription, inRange: linkRange) {
                // Open the corresponding app if possible
                if let appLink = appLink, let appURL = URL(string: appLink), UIApplication.shared.canOpenURL(appURL) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(appURL as URL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(appURL as URL)
                    }
                } else if let webLink = webLink, let webURL = URL(string: webLink) {
                    //redirect to safari because the user doesn't have specified app
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(webURL as URL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(webURL as URL)
                    }
                }
            }
        }
    }

    @objc func okButtonPressed() {
        whatsNewDelegate?.okButtonPressed()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension UITapGestureRecognizer {
    // Helper function to see if a tap was in the specified range within a UILabel
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint.init(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                               y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint.init(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                          y: locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
