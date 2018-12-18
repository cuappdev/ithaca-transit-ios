//
//  ServiceAlertTableViewCell.swift
//  TCAT
//
//  Created by Omar Rasheed on 12/7/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit

class ServiceAlertTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    static let identifier: String = "serviceAlertCell"
    private let fileName: String = "serviceAlertTableViewCell"
    var alert: Alert?
    
    var timeSpanLabel: UILabel!
    var descriptionLabel: UILabel!
    var affectedRoutesLabel: UILabel!
    var affectedRoutesStackView: UIStackView!
    var affectedRoutesCollectionView: UICollectionView?
    
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
        // setupAffectedRoutesStackView()
        if let routes = alert?.routes, !routes.isEmpty {
            setupAffectedRoutesCollectionView()
            setupaffectedRoutesLabel()
        }
        
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
    
    func setupAffectedRoutesCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        affectedRoutesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        affectedRoutesCollectionView?.delegate = self
        affectedRoutesCollectionView?.dataSource = self
        affectedRoutesCollectionView?.allowsSelection = false
        affectedRoutesCollectionView?.isScrollEnabled = false
        affectedRoutesCollectionView?.register(ServiceAlertCollectionViewCell.self, forCellWithReuseIdentifier: ServiceAlertCollectionViewCell.identifier)
        
        contentView.addSubview(affectedRoutesCollectionView!)
    }
    
    func setupAffectedRoutesStackView() {
        if let routes = alert?.routes {
            var subviews = [BusIcon]()
            for route in routes {
                subviews.append(BusIcon(type: .directionSmall, number: route))
            }
            affectedRoutesStackView = UIStackView(arrangedSubviews: subviews)
        }
        
        affectedRoutesStackView.axis = .horizontal
        affectedRoutesStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        contentView.addSubview(affectedRoutesStackView)
    }
    
    func setupConstraints() {
        let borderInset = 16
        
        timeSpanLabel.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview().inset(borderInset).labeled("timeSpanLabel: Top, Leading, Trailing")
            make.height.equalTo(timeSpanLabel.intrinsicContentSize.height).labeled("timeSpanLabel: Height")
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(timeSpanLabel.snp.bottom).offset(12).labeled("descriptionLabel: Top")
            make.leading.equalTo(timeSpanLabel).labeled("descriptionLabel: Leading")
            make.trailing.equalToSuperview().inset(borderInset).labeled("descriptionLabel: Trailing")
            if let text = descriptionLabel.text {
                
                let width = contentView.frame.width - (CGFloat)(2 * borderInset)
                
                let heightValue = ceil(text.heightWithConstrainedWidth(width: width, font: descriptionLabel.font))
                make.height.equalTo(ceil(heightValue)).labeled("descriptionLabel: Height")
            } else {
                make.height.equalTo(0).labeled("descriptionLabel: Height")
            }
        }
        
        if let collectionView = affectedRoutesCollectionView {
            
            affectedRoutesLabel.snp.makeConstraints { (make) in
                make.leading.equalTo(timeSpanLabel).labeled("AffectedRoutesLabel: Leading")
                make.top.equalTo(descriptionLabel.snp.bottom).offset(32).labeled("affectedRoutesLabel: Top")
                make.width.equalTo(affectedRoutesLabel.intrinsicContentSize.width).labeled("affectedRoutesLabel: Width")
                make.height.equalTo(30).labeled("affectedRoutesLabel: Height")
            }
            
            collectionView.snp.makeConstraints { (make) in
                make.top.equalTo(affectedRoutesLabel.snp.bottom).offset(12).labeled("affectedRoutesCollectionView: Top")
                make.leading.equalTo(timeSpanLabel).labeled("affectedRoutesCollectionView: Leading")
                make.trailing.bottom.equalToSuperview().inset(borderInset).labeled("affectedRoutesCollectionView: Trailing, Bottom")
            }
        } else {
            descriptionLabel.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().inset(borderInset).labeled("descriptionLabel: Bottom")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 48, height: 24)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (alert?.routes.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = affectedRoutesCollectionView?.dequeueReusableCell(withReuseIdentifier: ServiceAlertCollectionViewCell.identifier, for: indexPath) as? ServiceAlertCollectionViewCell
        
        if cell == nil {
            cell = ServiceAlertCollectionViewCell(frame: .zero)
        }
        
        cell?.routeNumber = alert?.routes[indexPath.item]
        cell?.setIcon()
        //cell?.layoutSubviews()
        
        return cell!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private class ServiceAlertCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "serviceAlertCell"
    
    var routeNumber: Int!

    func setIcon() {
        let icon = BusIcon(type: .directionSmall, number: routeNumber)
        
        contentView.addSubview(icon)
        
        icon.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
