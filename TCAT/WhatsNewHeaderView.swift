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
        super.init(frame: .zero)
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
        backgroundView.layer.borderColor = UIColor(red: 233/255, green: 235/255, blue: 238/255, alpha: 1).cgColor
        
        let wholeCardTapped = UITapGestureRecognizer()
        wholeCardTapped.addTarget(self, action: #selector(cardTapped))
        backgroundView.addGestureRecognizer(wholeCardTapped)
        
        addSubview(backgroundView)
    }
    
    func createWhatsNewHeader() {
        whatsNewHeader = UILabel()
        whatsNewHeader.text = "NEW IN ITHACA TRANSIT"
        whatsNewHeader.font = UIFont(name: Constants.Fonts.SanFrancisco.Semibold, size: 10)
        whatsNewHeader.textColor = UIColor(red: 8/255, green: 160/255, blue: 224/255, alpha: 1)
        
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
        updateDescription.textColor = UIColor(red: 144/255, green: 148/255, blue: 156/255, alpha: 1)
        updateDescription.numberOfLines = 0
        updateDescription.textAlignment = .center
        
        backgroundView.addSubview(updateDescription)
    }
    
    func createDismissButton() {
        dismissButton = UIButton()
        dismissButton.setTitle("OK", for: .normal)
        dismissButton.titleLabel?.font = UIFont(name: Constants.Fonts.SanFrancisco.Semibold, size: 14)
        dismissButton.addTarget(self, action: #selector(okButtonPressed), for: .touchUpInside)
        dismissButton.backgroundColor = UIColor(red: 8/255, green: 160/255, blue: 224/255, alpha: 1)
        dismissButton.setTitleColor(.white, for: .normal)
        dismissButton.layer.cornerRadius = 14.5
        dismissButton.clipsToBounds = true
        
        backgroundView.addSubview(dismissButton)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        backgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(snp.top).offset(16)
            make.leading.equalTo(snp.leading).offset(16)
            make.trailing.equalTo(snp.trailing).offset(-16)
            make.height.equalTo(160)
        }
        
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
            make.top.equalTo(updateTitle.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(updateDescription.intrinsicContentSize.height * 2.5)
            make.width.equalTo(300)
        }
        dismissButton.snp.makeConstraints { (make) in
            make.top.equalTo(updateDescription.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(dismissButton.intrinsicContentSize.height)
            print(dismissButton.intrinsicContentSize.height)
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
