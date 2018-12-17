//
//  ServiceAlertTableViewCell.swift
//  TCAT
//
//  Created by Omar Rasheed on 12/7/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit

class ServiceAlertTableViewCell: UITableViewCell {

    static let identifier: String = "serviceAlertCell"
    private let fileName: String = "serviceAlertTableViewCell"
    var alert: Alert?
    
    var timeSpanLabel: UILabel!
    var descriptionLabel: UILabel!
    var affectedRoutesLabel: UILabel!
    var affectedRoutesStackView: UIStackView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        timeSpanLabel = UILabel()
        descriptionLabel = UILabel()
        affectedRoutesLabel = UILabel()
        affectedRoutesStackView = UIStackView()
    }
    
    func setData() {
        setupTimeSpanLabel()
        setupDescriptionLabel()
        setupaffectedRoutesLabel()
        setupAffectedRoutesStackView()
        
        setupConstraints()
    }
    
    private func setupTimeSpanLabel() {
        
        timeSpanLabel.numberOfLines = 0
        timeSpanLabel.font = .getFont(.semibold, size: 14)
        timeSpanLabel.textColor = Colors.primaryText
        timeSpanLabel.text = formatTimeString()
        
        contentView.addSubview(timeSpanLabel)
    }
    
    private func formatTimeString() -> String{
        return "Wednesday, 4/4 - Thursday, 4/12"
    }
    
    private func setupDescriptionLabel() {
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .getFont(.semibold, size: 14)
        descriptionLabel.textColor = Colors.primaryText
        descriptionLabel.text = alert?.message
        
        contentView.addSubview(descriptionLabel)
    }
    
    private func setupaffectedRoutesLabel() {
        affectedRoutesLabel.font = .getFont(.semibold, size: 14)
        affectedRoutesLabel.textColor = Colors.primaryText
        affectedRoutesLabel.text = "Affected Routes: "
        
        contentView.addSubview(affectedRoutesLabel)
    }
    
    func setupAffectedRoutesStackView() {
        if let routes = alert?.routes {
            for route in routes {
                affectedRoutesStackView.addSubview(BusIcon(type: .directionSmall, number: route))
            }
        }
        
        affectedRoutesStackView.axis = .vertical
        affectedRoutesStackView.layoutMargins = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
        affectedRoutesStackView.isLayoutMarginsRelativeArrangement = true
        contentView.addSubview(affectedRoutesStackView)
    }
    
    func setupConstraints() {
        let borderInset = 16
        
        timeSpanLabel.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview().inset(borderInset)
            make.height.equalTo(timeSpanLabel.intrinsicContentSize.height)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(timeSpanLabel.snp.bottom).offset(12)
            make.leading.equalTo(timeSpanLabel)
            make.trailing.equalToSuperview().inset(borderInset)
            if let text = descriptionLabel.text, let superview = superview, let wholeView = superview.superview {
                
                let width = wholeView.frame.width - (CGFloat)(2 * borderInset)
                
                let heightValue = ceil(text.heightWithConstrainedWidth(width: width, font: descriptionLabel.font))
                make.height.equalTo(ceil(heightValue))
            }
        }
        
        affectedRoutesLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(timeSpanLabel)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(32)
            make.width.equalTo(affectedRoutesLabel.intrinsicContentSize.width)
            make.height.equalTo(affectedRoutesLabel.intrinsicContentSize.height)
        }
        
        affectedRoutesStackView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(borderInset)
            make.bottom.equalToSuperview().inset(borderInset)
            make.top.equalTo(affectedRoutesLabel.snp.bottom).offset(12)
            make.height.equalTo(100)
            make.leading.equalTo(timeSpanLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
