//
//  HeaderView.swift
//  TCAT
//
//  Created by Austin Astorga on 11/19/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import SnapKit

protocol HeaderViewDelegate {
    func displayFavoritesTVC()
    func clearRecentSearches()
}

enum buttonOption {
    case add
    case clear
    case none
}
class HeaderView: UITableViewHeaderFooterView {
    
    var headerViewDelegate: HeaderViewDelegate?

    var label: UILabel = {
        let label = UILabel()
        label.font = .getFont(.regular, size: 14)
        label.textColor = Colors.metadataIcon
        return label
    }()

    var button: UIButton?

    @objc func addNewFavorite(sender: UIButton) {
        headerViewDelegate?.displayFavoritesTVC()
    }
    
    @objc func clearRecentSearches(sender: UIButton) {
        headerViewDelegate?.clearRecentSearches()
    }

    func setupView(labelText: String, buttonType: buttonOption) {
        label.text = labelText
        contentView.addSubview(label)

        label.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-10)
        }
        createButton(type: buttonType)
    }

    func createButton(type: buttonOption) {
        button = UIButton(type: .system)
        button?.setTitleColor(Colors.tcatBlue, for: .normal)
        
        switch type {
        case .add:
            button?.setTitle("Add", for: .normal)
            button?.addTarget(self, action: #selector(addNewFavorite), for: .touchUpInside)
        case .clear:
            button?.setTitle("Clear", for: .normal)
            button?.addTarget(self, action: #selector(clearRecentSearches), for: .touchUpInside)
        default: return
        }
        
        if let button = button {
            contentView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.centerY.equalTo(label.snp.centerY)
                make.trailing.equalToSuperview().offset(-12)
            }
        }
    }
}
