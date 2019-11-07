//
//  HeaderView.swift
//  TCAT
//
//  Created by Austin Astorga on 11/19/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import SnapKit
import UIKit

protocol HeaderViewDelegate: class {
    func clearRecentSearches()
}

enum ButtonOption {
    case add
    case clear
    case none
}

class HeaderView: UITableViewHeaderFooterView {

    private weak var headerViewDelegate: HeaderViewDelegate?

    static let separatorViewHeight: CGFloat = 1

    private var button: UIButton?
    private var label: UILabel!

//    @objc private func addNewFavorite(sender: UIButton) {
//        headerViewDelegate?.presentFavoritePicker()
//    }

    @objc private func clearRecentSearches(sender: UIButton) {
        headerViewDelegate?.clearRecentSearches()
    }

    init(
        labelText: String? = nil,
        buttonType: ButtonOption = .none,
        separatorVisible: Bool = false,
        delegate: HeaderViewDelegate? = nil
    ) {
        super.init(reuseIdentifier: nil)

        self.headerViewDelegate = delegate

        if labelText != nil {
            label = UILabel()
            label.font = .getFont(.regular, size: 14)
            label.textColor = Colors.metadataIcon
            label.text = labelText
            contentView.addSubview(label)

            label.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.bottom.equalToSuperview().offset(-10)
            }
            createButton(type: buttonType)
        }

        if separatorVisible {
            let separatorView = UIView()
            separatorView.backgroundColor = Colors.backgroundWash
            contentView.addSubview(separatorView)

            separatorView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(20)
                make.height.equalTo(HeaderView.separatorViewHeight)
                make.top.equalToSuperview()
            }
        }
    }

    private func createButton(type: ButtonOption) {
        button = UIButton(type: .system)
        button?.setTitleColor(Colors.tcatBlue, for: .normal)

        switch type {
//        case .add:
//            button?.setTitle(Constants.Buttons.add, for: .normal)
//            button?.addTarget(self, action: #selector(addNewFavorite), for: .touchUpInside)
        case .clear:
            button?.setTitle(Constants.Buttons.clear, for: .normal)
            button?.addTarget(self, action: #selector(clearRecentSearches), for: .touchUpInside)
        default: return
        }

        if let button = button {
            contentView.addSubview(button)
            button.snp.makeConstraints { make in
                make.centerY.equalTo(label.snp.centerY)
                make.trailing.equalToSuperview().offset(-12)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
