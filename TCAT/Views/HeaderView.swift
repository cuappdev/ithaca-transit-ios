//
//  HeaderView.swift
//  TCAT
//
//  Created by Austin Astorga on 11/19/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import SnapKit

protocol AddFavoritesDelegate {
    func displayFavoritesTVC()
}

class HeaderView: UITableViewHeaderFooterView {
    
    var addFavoritesDelegate: AddFavoritesDelegate?

    var label: UILabel = {
        let label = UILabel()
        label.font = .getFont(.regular, size: 14)
        label.textColor = Colors.metadataIcon
        return label
    }()

    var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.setTitleColor(Colors.tcatBlue, for: .normal)
        button.addTarget(self, action: #selector(addNewFavorite), for: .touchUpInside)
        return button
    }()

    @objc func addNewFavorite(sender: UIButton) {
        addFavoritesDelegate?.displayFavoritesTVC()
    }

    func setupView(labelText: String, displayAddButton: Bool = false) {
        label.text = labelText
        contentView.addSubview(label)

        label.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-6)
        }
        if displayAddButton {
            createAddButton()
        }
    }

    func createAddButton() {
        contentView.addSubview(addButton)
        addButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(label.snp.centerY)
            make.trailing.equalToSuperview().offset(-12)
        }
    }
}
