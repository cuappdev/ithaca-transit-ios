//
//  EateryCardCollectionViewCell.swift
//  TCAT
//
//  Created by Angelina Chen on 3/5/25.
//  Copyright © 2025 Cornell AppDev. All rights reserved.
//

//import EateryModel
import UIKit
import Combine

//class EateryLargeCardView: UICollectionViewCell {
//
//    // MARK: - Properties (view)
//    
//    private let imageView = UIImageView()
//    private let imageTintView = UIView()
//    private let alertsStackView = UIStackView()
//
//    private let labelStackView = UIStackView()
//    private let titleLabel = UILabel()
//    private let subtitleLabels = [UILabel(), UILabel()]
//    private let favoriteButton = ButtonView(content: UIView())
//    private let favoriteButtonImage = UIImageView()
//
//    // MARK: - Properties (data)
//
//    private var cancellables = Set<AnyCancellable>()
//    private var eatery: Eatery?
//
//    static let reuse = "EateryLargeCardContentViewReuseId"
//
//    // MARK: - Init
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        setUpSelf()
//        setUpConstraints()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configure(eatery: Eatery, favorited: Bool) {
//        self.eatery = eatery
//        titleLabel.text = eatery.name
//        configureFavoriteButton(eatery: eatery, favorited: favorited)
//        configureImageView(imageUrl: eatery.imageUrl, isOpen: eatery.isOpen)
//        configureSubtitleLabels(eatery: eatery)
//        configureAlerts(status: eatery.status)
//    }
//
//    private func setUpSelf() {
//        contentView.insetsLayoutMarginsFromSafeArea = false
//        contentView.layoutMargins = .zero
//        contentView.backgroundColor = .white
//        contentView.clipsToBounds = true
//        contentView.layer.cornerRadius = 8
//        layer.shadowRadius = 4
//        layer.shadowOffset = CGSize(width: 0, height: 4)
//        layer.shadowColor = UIColor.Eatery.shadowLight.cgColor
//        layer.shadowOpacity = 0.25
//
//        contentView.addSubview(imageView)
//        setUpImageView()
//
//        contentView.addSubview(labelStackView)
//        setUpLabelStackView()
//
//        contentView.addSubview(favoriteButton)
//        setUpFavoriteButton()
//    }
//
//    private func setUpImageView() {
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//
//        imageView.addSubview(imageTintView)
//        setUpImageTintView()
//
//        imageView.addSubview(alertsStackView)
//        setUpAlertsStackView()
//    }
//
//    private func setUpImageTintView() {
//        imageTintView.backgroundColor = .white
//        imageTintView.alpha = 0
//    }
//
//    private func setUpAlertsStackView() {
//        alertsStackView.spacing = 8
//        alertsStackView.axis = .vertical
//        alertsStackView.alignment = .trailing
//        alertsStackView.distribution = .equalSpacing
//    }
//
//    private func setUpLabelStackView() {
//        labelStackView.axis = .vertical
//        labelStackView.spacing = 4
//        labelStackView.distribution = .fill
//        labelStackView.alignment = .fill
//        
//        labelStackView.addArrangedSubview(titleLabel)
//        setUpTitleLabel()
//
//        for subtitleLabel in subtitleLabels {
//            labelStackView.addArrangedSubview(subtitleLabel)
//            setUpSubtitleLabel(subtitleLabel)
//        }
//    }
//
//    private func setUpTitleLabel() {
//        titleLabel.numberOfLines = 0
//        titleLabel.lineBreakMode = .byWordWrapping
//        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
//        titleLabel.textColor = UIColor.Eatery.black
//    }
//
//    private func setUpSubtitleLabel(_ subtitleLabel: UILabel) {
//        subtitleLabel.font = .preferredFont(for: .subheadline, weight: .medium)
//        subtitleLabel.textColor = UIColor.Eatery.gray05
//        subtitleLabel.numberOfLines = 0
//        subtitleLabel.lineBreakMode = .byWordWrapping
//    }
//
//    private func setUpFavoriteButton() {
//        favoriteButton.addSubview(favoriteButtonImage)
//        favoriteButton.content.contentMode = .scaleAspectFill
//    }
//
//    private func configureFavoriteButton(eatery: Eatery, favorited: Bool) {
//
//        favoriteButtonImage.image = UIImage(named: "Favorite\(favorited ? "Selected" : "Unselected")")
//        favoriteButton.buttonPress { [weak self] _ in
//            guard let self else { return }
//            let coreDataStack = AppDelegate.shared.coreDataStack
//            let metadata = coreDataStack.metadata(eateryId: eatery.id)
//            metadata.isFavorite.toggle()
//            coreDataStack.save()
//
//            NotificationCenter.default.post(
//                name: UIViewController.notificationName,
//                object: nil,
//                userInfo: [ UIViewController.notificationUserInfoKey : metadata.isFavorite ]
//            )
//        }
//    }
//
//    private func configureImageView(imageUrl: URL?, isOpen: Bool) {
//        imageView.image = UIImage()
//        imageView.setImage(with: imageUrl)
//        imageTintView.alpha = isOpen ? 0 : 0.5
//        imageView.id = imageUrl?.absoluteString
//    }
//    
//    private func configureSubtitleLabels(eatery: Eatery) {
//        subtitleLabels[0].text = eatery.locationDescription
//        LocationManager.shared.$userLocation
//            .sink { userLocation in
//                self.subtitleLabels[1].attributedText = EateryFormatter.default.formatEatery(
//                    eatery,
//                    style: .medium,
//                    font: .preferredFont(for: .footnote, weight: .medium),
//                    userLocation: userLocation,
//                    date: Date()
//                ).first
//            }
//            .store(in: &cancellables)
//        
//    }
//    
//
//    private func setUpConstraints() {
//        snp.makeConstraints { make in
//            make.width.equalTo(snp.height).multipliedBy(343.0 / 216.0).priority(.required.advanced(by: -1))
//        }
//
//        imageView.snp.makeConstraints { make in
//            make.top.leading.trailing.equalToSuperview()
//        }
//        
//        imageView.setContentCompressionResistancePriority(
//            titleLabel.contentCompressionResistancePriority(for: .vertical) - 1,
//            for: .vertical
//        )
//
//        imageTintView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//
//        alertsStackView.snp.makeConstraints { make in
//            make.top.trailing.equalToSuperview().inset(12)
//        }
//
//        labelStackView.snp.makeConstraints { make in
//            make.top.equalTo(imageView.snp.bottom).offset(12)
//            make.leading.bottom.equalToSuperview().inset(12)
//        }
//
//        favoriteButton.snp.makeConstraints { make in
//            make.trailing.equalToSuperview()
//            make.top.equalTo(imageView.snp.bottom)
//            make.leading.equalTo(labelStackView.snp.trailing).offset(4)
//            make.size.equalTo(44)
//        }
//
//        favoriteButtonImage.snp.makeConstraints { make in
//            make.size.equalTo(20)
//            make.center.equalToSuperview()
//        }
//    }
//
//    func addAlertView(_ view: UIView) {
//        alertsStackView.addArrangedSubview(view)
//    }
//
//}
