//
//  EateryCollectionViewCell.swift
//  TCAT
//
//  Created by Jayson Hahn on 4/24/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Foundation
import Kingfisher
import UIKit

class EateryCollectionViewCell: UICollectionViewCell {

    private var nameLabel = UILabel()
    private var openStatus = UILabel()
    private var favoriteButton = UIButton()
    private var subTitleLabel = UILabel()
    private var stack = UIStackView()
    private var statusLabel = UILabel()
    private var eateryImage = UIImageView()

    private var isFavorited = false
    private var acceptsBRBs = true
    private var acceptsCash = false
    private var acceptsMealSwiptes = false


    static let reuse = "EateryCellReuseIdentifier"

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
//        contentView.layer.borderColor = UIColor.black.cgColor
//        contentView.layer.borderWidth = 3

        setupNameLabel()
        setupSubTitleLabel()
        setupStatusLabel()
        setupImageView()
        setupFavoriteButton()
        setupPaymentMethodsStack()
        setupConstraints()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(eatery: Eatery) {
        self.acceptsCash = eatery.paymentAcceptsCash
        self.acceptsBRBs = eatery.paymentAcceptsBrbs
        self.acceptsMealSwiptes = eatery.paymentAcceptsMealSwipes
        nameLabel.text = eatery.name
        let url = URL(string: eatery.imageUrl)
        eateryImage.kf.setImage(with: url)
        subTitleLabel.text = eatery.location
        statusLabel.attributedText = formatStatus(EateryStatus(eatery.events))
    }

    func setupNameLabel() {
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1)
        nameLabel.textAlignment = .left
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
    }

    func setupSubTitleLabel() {
        subTitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subTitleLabel.textColor = UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1)
        subTitleLabel.textAlignment = .left
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subTitleLabel)
    }

    func setupStatusLabel() {
        statusLabel.font = .systemFont(ofSize: 14, weight: .regular)
        statusLabel.textAlignment = .left
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(statusLabel)
    }

    func setupImageView() {
        eateryImage.contentMode = .scaleAspectFill
        eateryImage.clipsToBounds = true
        eateryImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(eateryImage)
    }

    func setupFavoriteButton() {
        let imageString =  isFavorited ? "FavoriteSelected" : "FavoriteUnselected"
        favoriteButton.setImage(UIImage(named: imageString), for: .normal)
        favoriteButton.addTarget(self, action: #selector(favoriteEatery), for: .touchUpInside)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(favoriteButton)
    }

    @objc func favoriteEatery() {
        isFavorited.toggle()
        let imageString =  isFavorited ? "FavoriteSelected" : "FavoriteUnselected"
        favoriteButton.setImage(UIImage(named: imageString), for: .normal)
    }

    func setupConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(eateryImage.snp.bottom).offset(16)
        }

        subTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.leading  )
            make.top.equalTo(nameLabel.snp.bottom)
        }

        statusLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.leading  )
            make.top.equalTo(subTitleLabel.snp.bottom)
        }

        eateryImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }

        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(eateryImage.snp.bottom).offset(14)
            make.trailing.equalToSuperview().inset(16)
        }

        stack.snp.makeConstraints { make in
            make.top.equalTo(eateryImage.snp.bottom).offset(14)
            make.trailing.equalToSuperview().inset(24)
            make.leading.equalTo(nameLabel.snp.trailing)
        }
    }

    private func formatStatus(_ status: EateryStatus) -> NSAttributedString {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short // Set the date formatter to only show the time

        let statusString = NSMutableAttributedString()
        let font = UIFont.systemFont(ofSize: 14, weight: .regular)

        switch status {
        case .open(let event):
            let timeString = dateFormatter.string(from: event.endDate)
            statusString.append(NSAttributedString(
                string: "Open",
                attributes: [.foregroundColor: UIColor(hex: "#1BAF5D"), .font: font]
            ))
            statusString.append(NSAttributedString(
                string: " - until \(timeString)",
                attributes: [.foregroundColor: UIColor.gray, .font: font]
            ))

        case .closed(let event):
            let timeString = dateFormatter.string(from: event.startDate)
            statusString.append(NSAttributedString(
                string: "Closed",
                attributes: [.foregroundColor: UIColor(hex: "D82D4D"), .font: font]
            ))
            statusString.append(NSAttributedString(
                string: " - until \(timeString)",
                attributes: [.foregroundColor: UIColor(hex: "616161"), .font: font]
            ))

        case .openingSoon(let event):
            let timeString = dateFormatter.string(from: event.startDate)
            statusString.append(NSAttributedString(
                string: "Closed",
                attributes: [.foregroundColor: UIColor(hex: "D82D4D"), .font: font]
            ))
            statusString.append(NSAttributedString(
                string: " - until \(timeString)",
                attributes: [.foregroundColor: UIColor(hex: "616161"), .font: font]
            ))

        case .closingSoon(let event):
            let timeString = dateFormatter.string(from: event.endDate)
            let image = UIImage(systemName: "exclamationmark.triangle")?.withTintColor(UIColor(hex: "FE8F13"))
            if let image = image {
                statusString.append(NSAttributedString(attachment: NSTextAttachment(image: image)))
            }
            statusString.append(NSAttributedString(
                string: "Closing in \(timeString)",
                attributes: [.foregroundColor: UIColor(hex: "FE8F13"), .font: font]
            ))

        case .closeUntilUnknown:
            statusString.append(NSAttributedString(
                string: "Closed",
                attributes: [.foregroundColor: UIColor(hex: "D82D4D"), .font: font]
            ))
        }

        return statusString
    }

    func setupPaymentMethodsStack() {
//        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fill
        stack.alignment = .fill
        print(acceptsMealSwiptes)
        if acceptsMealSwiptes {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "MealSwipes")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor(hex: "4A90E2")
            imageView.contentMode = .scaleAspectFit

            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(24)
            }

            stack.addArrangedSubview(imageView)
        }

        if acceptsBRBs {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "BRBs")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor(hex: "F2655D")
            imageView.contentMode = .scaleAspectFit

            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(24)
            }

            stack.addArrangedSubview(imageView)
        }

        if acceptsCash {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "Cash")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor(hex: "63C774")
            imageView.contentMode = .scaleAspectFit

            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(24)
            }

            stack.addArrangedSubview(imageView)
        }

//        stack.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
//        stack.cornerRadiusView.backgroundColor = .white
//        stack.shadowColor = UIColor.Eatery.black
//        stack.shadowOffset = CGSize(width: 0, height: 4)
//        stack.shadowOpacity = 0.25
//        stack.shadowRadius = 4
        stack.roundCorners(corners: .allCorners, radius: 10)
        stack.layer.borderColor = UIColor(hex: "DADADA").cgColor
        stack.layer.borderWidth = 1.2

        contentView.addSubview(stack)
    }

}
