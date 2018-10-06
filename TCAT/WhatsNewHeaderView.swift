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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createBackgroundView()
        createUpdateDescription()
        createWhatsNewHeader()
        createUpdateTitle()
        createDismissButton()
        updateConstraints()
    }
    
    func createBackgroundView() {
        backgroundView = UIView()
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 14
        backgroundView.clipsToBounds = true
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.borderColor = UIColor.tableBackgroundColor.cgColor
        
        let wholeCardTapped = UITapGestureRecognizer()
        wholeCardTapped.addTarget(self, action: #selector(cardTapped))
        backgroundView.addGestureRecognizer(wholeCardTapped)
        
        addSubview(backgroundView)
    }
    
    func createWhatsNewHeader() {
        whatsNewHeader = UILabel()
        whatsNewHeader.text = "NEW IN ITHACA TRANSIT"
        whatsNewHeader.font = UIFont(name: Constants.Fonts.SanFrancisco.Semibold, size: 10)
        whatsNewHeader.textColor = UIColor.tcatBlueColor
        
        backgroundView.addSubview(whatsNewHeader)
    }
    
    func createUpdateTitle() {
        updateTitle = UILabel()
        updateTitle.text = "App Shortcuts for Favorites"
        updateTitle.font = UIFont(name: Constants.Fonts.SanFrancisco.Bold, size: 16)
        
        backgroundView.addSubview(updateTitle)
    }
    
    
    func createUpdateDescription () {
        updateDescription = UILabel()
        updateDescription.text = "Force Touch the app icon to search your favorites even faster."
        updateDescription.font = UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 14)
        updateDescription.textColor = UIColor.mediumGrayColor
        updateDescription.numberOfLines = 0
        updateDescription.textAlignment = .center
        
        backgroundView.addSubview(updateDescription)
    }
    
    func createDismissButton() {
        dismissButton = UIButton()
        dismissButton.setTitle("OK", for: .normal)
        dismissButton.titleLabel?.font = UIFont(name: Constants.Fonts.SanFrancisco.Semibold, size: 14)
        dismissButton.addTarget(self, action: #selector(okButtonPressed), for: .touchUpInside)
        dismissButton.backgroundColor = UIColor.tcatBlueColor
        dismissButton.setTitleColor(.white, for: .normal)
        dismissButton.layer.cornerRadius = dismissButton.intrinsicContentSize.height/2
        dismissButton.clipsToBounds = true
        
        backgroundView.addSubview(dismissButton)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        backgroundView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width - 32)
            make.height.equalTo(150)
            make.bottom.equalTo(snp.bottom)
        }
        
        whatsNewHeader.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(whatsNewHeader.intrinsicContentSize.height)
            make.width.equalTo(whatsNewHeader.intrinsicContentSize.width)
            make.bottom.equalTo(updateTitle.snp.top).offset(-8)
        }
        
        updateTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(updateTitle.intrinsicContentSize.height)
            make.width.equalTo(updateTitle.intrinsicContentSize.width)
            make.bottom.equalTo(updateDescription.snp.top).offset(-6)
        }
        
        updateDescription.snp.makeConstraints { (make) in
            make.bottom.equalTo(dismissButton.snp.top).offset(-12)
            make.centerX.equalToSuperview()
            if let text = updateDescription.text {
                make.height.equalTo(text.heightWithConstrainedWidth(width: 300, font: updateDescription.font))
            } else {
                make.height.equalTo(0)
            }
            
            make.width.equalTo(300)
        }
        dismissButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(dismissButton.intrinsicContentSize.height)
            make.bottom.equalTo(snp.bottom).offset(-16)
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
