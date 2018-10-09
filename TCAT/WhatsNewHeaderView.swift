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
        whatsNewHeader.font = UIFont(name: Constants.Fonts.SanFrancisco.Semibold, size: 10)
        whatsNewHeader.textColor = UIColor.tcatBlueColor
        
        addSubview(whatsNewHeader)
    }
    
    func createUpdateTitle(updateName: String) {
        updateTitle = UILabel()
        updateTitle.text = updateName
        updateTitle.font = UIFont(name: Constants.Fonts.SanFrancisco.Bold, size: 16)
        
        addSubview(updateTitle)
    }
    
    
    func createUpdateDescription (description: String) {
        updateDescription = UILabel()
        updateDescription.text = description
        updateDescription.font = UIFont(name: Constants.Fonts.SanFrancisco.Regular, size: 14)
        updateDescription.textColor = UIColor.mediumGrayColor
        updateDescription.numberOfLines = 0
        updateDescription.textAlignment = .center
        
        addSubview(updateDescription)
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
            make.top.equalTo(updateTitle.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
            if let text = updateDescription.text, frame.width != 0 {
                print(frame.width)
                make.height.equalTo(text.heightWithConstrainedWidth(width: frame.width - 80, font: updateDescription.font))
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
