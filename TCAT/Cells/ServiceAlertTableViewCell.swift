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
    var rowNum: Int!
    
    let borderInset = 16
    
    var timeSpanLabel: UILabel!
    var descriptionLabel: UILabel!
    var affectedRoutesLabel: UILabel!
    var affectedRoutesStackView: UIStackView?
    var topSeparator: UIView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupTimeSpanLabel()
        setupDescriptionLabel()
    }
    
    func setData() {
        if let fromDate = alert?.fromDate, let toDate = alert?.toDate {
            timeSpanLabel.text = formatTimeString(fromDate, toDate: toDate)
        }
        descriptionLabel.text = alert?.message
        if let routes = alert?.routes, !routes.isEmpty {
            setupAffectedRoutesStackView()
            setupaffectedRoutesLabel()
        }
        
        if rowNum > 0 {
            setupTopSeparator()
        }
    }
    
    private func setupTimeSpanLabel() {
        
        timeSpanLabel = UILabel()
        timeSpanLabel.numberOfLines = 0
        timeSpanLabel.font = .getFont(.semibold, size: 18)
        timeSpanLabel.textColor = Colors.primaryText
        
        contentView.addSubview(timeSpanLabel)
    }
    
    private func setupDescriptionLabel() {
        
        descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .getFont(.regular, size: 14)
        descriptionLabel.textColor = Colors.primaryText
        
        
        contentView.addSubview(descriptionLabel)
    }
    
    private func setupaffectedRoutesLabel() {
        
        affectedRoutesLabel = UILabel()
        affectedRoutesLabel.font = .getFont(.semibold, size: 18)
        affectedRoutesLabel.textColor = Colors.primaryText
        affectedRoutesLabel.text = "Affected Routes"
        
        contentView.addSubview(affectedRoutesLabel)
    }
    
    private func setupAffectedRoutesStackView() {
        
        if var routes = alert?.routes, !routes.isEmpty {
            affectedRoutesStackView = UIStackView()
            for _ in 0..<rowCount() {
                var subviews = [BusIcon]()
                for _ in 0..<maxIconsPerRow() {
                    if !routes.isEmpty {
                        subviews.append(BusIcon(type: .directionSmall, number: routes.removeFirst()))
                    }
                }
                let rowStackView = UIStackView(arrangedSubviews: subviews)
                rowStackView.axis = .horizontal
                rowStackView.spacing = 10
                rowStackView.alignment = .leading
                affectedRoutesStackView?.addArrangedSubview(rowStackView)
            }
        }
        guard let stackView = affectedRoutesStackView else { return }
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.spacing = 10
        contentView.addSubview(stackView)
    }
    
    private func setupTopSeparator() {
        
        topSeparator = UIView()
        topSeparator?.backgroundColor = Colors.backgroundWash
        
        contentView.addSubview(topSeparator!)
    }
    
    override func updateConstraints() {
        
        if let topSeparator = topSeparator {
            topSeparator.snp.remakeConstraints { (make) in
                make.top.leading.trailing.equalToSuperview().labeled("topSeparator: Top, Leading, Trailing")
                make.height.equalTo(8).labeled("topSeparator: Height")
            }
            
            timeSpanLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(topSeparator.snp.bottom).offset(borderInset).labeled("timeSpanLabel: Top")
                make.leading.trailing.equalToSuperview().inset(borderInset).labeled("timeSpanLabel: Leading, Trailing")
                make.height.equalTo(timeSpanLabel.intrinsicContentSize.height).labeled("timeSpanLabel: Height")
            }
        } else {
            timeSpanLabel.snp.remakeConstraints { (make) in
                make.top.leading.trailing.equalToSuperview().inset(borderInset).labeled("timeSpanLabel: Top, Leading, Trailing")
                make.height.equalTo(timeSpanLabel.intrinsicContentSize.height).labeled("timeSpanLabel: Height")
            }
        }
        
        descriptionLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(timeSpanLabel.snp.bottom).offset(12).labeled("descriptionLabel: Top")
            make.leading.equalTo(timeSpanLabel).labeled("descriptionLabel: Leading")
            make.trailing.equalToSuperview().inset(borderInset).labeled("descriptionLabel: Trailing")
            if let text = descriptionLabel.text {
                
                let width = contentView.frame.width - (CGFloat)(2 * borderInset)
                
                let heightValue = ceil(text.heightWithConstrainedWidth(width: width, font: descriptionLabel.font))
                make.height.equalTo(ceil(heightValue)).labeled("descriptionLabel: Height")
            } else {
                make.height.equalTo(descriptionLabel.intrinsicContentSize.height).labeled("descriptionLabel: Height")
            }
        }
        
        if let stackView = affectedRoutesStackView {
            // When both a separator view and stackView are required
            affectedRoutesLabel.snp.remakeConstraints { (make) in
                make.leading.equalTo(timeSpanLabel).labeled("AffectedRoutesLabel: Leading")
                make.top.equalTo(descriptionLabel.snp.bottom).offset(24).labeled("affectedRoutesLabel: Top")
                make.width.equalTo(affectedRoutesLabel.intrinsicContentSize.width).labeled("affectedRoutesLabel: Width")
                make.height.equalTo(affectedRoutesLabel.intrinsicContentSize.height).labeled("affectedRoutesLabel: Height")
            }
            
            stackView.snp.remakeConstraints { (make) in
                make.top.equalTo(affectedRoutesLabel.snp.bottom).offset(8).labeled("affectedRoutesStackView: Top")
                make.leading.equalTo(timeSpanLabel).labeled("affectedRoutesStackView: Leading")
                make.trailing.bottom.equalToSuperview().inset(borderInset).labeled("affectedRoutesStackView: Trailing, Bottom")
            }
            
        } else {
            descriptionLabel.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().inset(borderInset).labeled("descriptionLabel: Bottom")
            }
        }
        super.updateConstraints()
    }
    
    private func formatTimeString(_ fromDate: String, toDate: String) -> String {
        
        // ISSUE IN PARSING STRING (HITS DEFAULT DATE.DISTANTPAST)
        
        let newformatter = DateFormatter()
        newformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sZZZZ"
        newformatter.locale = Locale(identifier: "en_US_POSIX")
        
        let fromDate = newformatter.date(from: fromDate)
        let toDate = newformatter.date(from: toDate)

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE M/d"

        if let unWrappedFromDate = fromDate, let unWrappedToDate = toDate {
            let formattedFromDate = formatter.string(from: unWrappedFromDate)
            let formattedToDate = formatter.string(from: unWrappedToDate)
            
            return "\(formattedFromDate) - \(formattedToDate)"
        }
        
        return "Time: Unknown"
    }
    
    private func maxIconsPerRow() -> Int {
        let iconWidth = Int(BusIconType.directionSmall.width)
        let screenWidth = Int(UIScreen.main.bounds.width)
        let minSpacing = 10
        let totalConstraintInset = borderInset * 2
        
        return (screenWidth - totalConstraintInset + minSpacing) / (iconWidth + minSpacing)
    }
    
    private func rowCount() -> Int {
        guard let routes = alert?.routes else { return 0 }
        
        if routes.count > maxIconsPerRow() {
            let addExtra = routes.count % maxIconsPerRow() > 0 ? 1 : 0
            let rowCount = routes.count / maxIconsPerRow()
            
            return rowCount + addExtra
        } else {
            return 1
        }
    }
    
    private func getDayOfWeek(_ today:Date) -> Int? {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: today)
        return weekDay
    }
    
    override func prepareForReuse() {
        if let stackView = affectedRoutesStackView {
            stackView.removeFromSuperview()
        }
        affectedRoutesStackView = nil
        
        if let routesLabel = affectedRoutesLabel {
            routesLabel.removeFromSuperview()
        }
        affectedRoutesLabel = nil
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
    

