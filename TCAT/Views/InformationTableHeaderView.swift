//
//  InformationHeaderView.swift
//  TCAT
//
//  Created by Omar Rasheed on 5/19/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import UIKit

protocol InfoHeaderViewDelegate: AnyObject {
    func showFunMessage()
}

class InformationTableHeaderView: UIView {

    private let descriptionLabel = UILabel()
    private let labelBehindBusImage = UILabel()
    private let tcatImage = UIImageView()
    private let titleLabel = UILabel()

    weak var delegate: InfoHeaderViewDelegate?
    private let descriptionLabelSize = CGSize(width: 167, height: 34)
    private let descriptionLabelTopOffset: CGFloat = 12
    private let headerWidth = UIScreen.main.bounds.width

    /// Represents the total height of the headerView given the width of the phone screen. Most of the variables
    /// used are static except for the tcat image height, which is dependent on the width of the user's screen.
    private var headerHeight: CGFloat {
        let bottomPadding: CGFloat = 37
        // swiftlint:disable:next line_length
        return tcatImageTopOffset + tcatImageSize.height + titleLabelTopOffset + titleLabelSize.height + descriptionLabelTopOffset + descriptionLabelSize.height + bottomPadding
    }

    private var tcatImageSize: CGSize {
        let width = headerWidth - 80
        let height = width * 0.4
        return CGSize(width: width, height: height)
    }

    private let tcatImageTopOffset: CGFloat = 44
    private let titleLabelSize = CGSize(width: 240, height: 20)
    private let titleLabelTopOffset: CGFloat = 44

    init() {
        super.init(frame: .zero)
        self.frame.size = CGSize(width: headerWidth, height: headerHeight)

        setupLabelBehindBusImage()
        setupTcatImage()
        setupTitleLabel()
        setupDescriptionLabel()

        setupHeaderViewConstraints()
    }

    func setupLabelBehindBusImage() {
        labelBehindBusImage.font = .getFont(.regular, size: 16)
        labelBehindBusImage.textColor = Colors.primaryText
        labelBehindBusImage.text = Constants.InformationView.magicSchoolBus
        labelBehindBusImage.textAlignment = .center
        labelBehindBusImage.backgroundColor = .clear
        addSubview(labelBehindBusImage)
    }

    func setupTcatImage() {
        tcatImage.image = UIImage(named: "tcat")
        tcatImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animateTcatBus)))
        tcatImage.isUserInteractionEnabled = true
        addSubview(tcatImage)
    }

    func setupTitleLabel() {
        titleLabel.font = .getFont(.medium, size: 16)
        titleLabel.textColor = Colors.primaryText
        titleLabel.text = Constants.InformationView.madeBy
        titleLabel.backgroundColor = .clear
        addSubview(titleLabel)
    }

    func setupDescriptionLabel() {
        descriptionLabel.font = .getFont(.regular, size: 14)
        descriptionLabel.textColor = Colors.primaryText
        descriptionLabel.text = Constants.InformationView.appDevDescription
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.textAlignment = .center
        addSubview(descriptionLabel)
    }

    func setupHeaderViewConstraints() {
        tcatImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(tcatImageTopOffset)
            make.size.equalTo(tcatImageSize)
            make.centerX.equalToSuperview()
        }

        labelBehindBusImage.snp.makeConstraints { make in
            make.center.equalTo(tcatImage)
            make.size.equalTo(labelBehindBusImage.intrinsicContentSize)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(tcatImage.snp.bottom).offset(titleLabelTopOffset)
            make.centerX.equalToSuperview()
            make.size.equalTo(titleLabelSize)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(descriptionLabelTopOffset)
            make.size.equalTo(descriptionLabelSize)
            make.centerX.equalToSuperview()
        }
    }

    @objc func animateTcatBus() {
        let constant: CGFloat = UIScreen.main.bounds.width
        let duration: TimeInterval = 1.5
        let delay: TimeInterval = 0
        let damping: CGFloat = 0.6
        let velocity: CGFloat = 0
        let options: UIView.AnimationOptions = .curveEaseInOut

        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: options,
            animations: {
                self.tcatImage.frame.origin.x += constant
            },
            completion: { _ in
                self.tcatImage.frame.origin.x -= 2 * constant

                UIView.animate(
                    withDuration: duration,
                    delay: delay,
                    usingSpringWithDamping: damping,
                    initialSpringVelocity: velocity,
                    options: options,
                    animations: {
                        self.tcatImage.frame.origin.x += constant
                    },
                    completion: { _ in
                        self.delegate?.showFunMessage()
                    }
                )
            }
        )

        let payload = BusTappedEventPayload()
        TransitAnalytics.shared.log(payload)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
