//
//  NotificationToggleTableViewCell.swift
//  TCAT
//
//  Created by HAIYING WENG on 11/3/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

class NotificationToggleTableViewCell: UITableViewCell {

    private let firstHairline = UIView()
    private let hairline = UIView()
    private let notifSwitch = UISwitch()
    private let notifTitleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        hairline.backgroundColor = Colors.tableViewSeparator
        contentView.addSubview(hairline)
        
        notifSwitch.onTintColor = Colors.tcatBlue
        notifSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        notifSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        contentView.addSubview(notifSwitch)
        
        notifTitleLabel.font = .getFont(.regular, size: 14)
        notifTitleLabel.textColor = Colors.primaryText
        contentView.addSubview(notifTitleLabel)
        
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        let notifTitleLeadingInset = 16
        let notifTitleTrailingInset = 10
        let switchTrailingInset = 15
        
        hairline.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        notifTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(notifTitleLeadingInset)
            make.trailing.equalTo(notifSwitch.snp.leading).offset(notifTitleTrailingInset)
        }
        
        notifSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-switchTrailingInset)
        }
    }
    
    func setupFirstCellHairline() {
        firstHairline.backgroundColor = Colors.tableViewSeparator
        contentView.addSubview(firstHairline)
        
        firstHairline.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func configure(for notifTitle: String) {
        notifTitleLabel.text = notifTitle
    }
    
    @objc private func switchValueChanged() {
        print("switch value changed")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
