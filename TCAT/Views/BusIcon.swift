//
//  BusIcon.swift
//  TCAT
//
//  Created by Matthew Barker on 2/26/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//
import UIKit

enum BusIconType: String {
    case directionSmall, directionLarge, liveTracking

    /// Return BusIcon's frame width
    var width: CGFloat {
        switch self {
        case .directionSmall:
            return 48
        case .liveTracking:
            return 72
        case .directionLarge:
            return 72
        }
    }

    /// Return BusIcon's frame height
    var height: CGFloat {
        switch self {
        case .directionSmall:
            return 24
        case .liveTracking:
            return 30
        case .directionLarge:
            return 36
        }
    }

    /// Return BusIcon's corner radius
    var cornerRadius: CGFloat {
        switch self {
        case .directionLarge:
            return 8
        default:
            return 4
        }
    }
}

class BusIcon: UIView {

    // MARK: Data vars

    let number: Int
    let type: BusIconType

    // MARK: View vars

    var baseView = UIView()
    let image = UIImageView(image: UIImage(named: "bus"))
    var label = UILabel()
    var liveIndicator: LiveIndicator?

    // MARK: Constraint vars

    override var intrinsicContentSize: CGSize {
        return CGSize(width: type.width, height: type.height)
    }

    // MARK: Init

    init(type: BusIconType, number: Int) {
        self.type = type
        self.number = number

        super.init(frame: CGRect(x: 0, y: 0, width: type.width, height: type.height))

        var fontSize: CGFloat {
            switch type {
            case .directionSmall: return 14
            case .directionLarge: return 20
            case .liveTracking: return 16
            }
        }

        backgroundColor = .clear
        isOpaque = false

        baseView.backgroundColor = Colors.tcatBlue
        baseView.layer.cornerRadius = type.cornerRadius
        addSubview(baseView)

        image.tintColor = Colors.white
        addSubview(image)

        label.text = "\(number)"
        label.font = .getFont(.semibold, size: fontSize)
        label.textColor = Colors.white
        label.textAlignment = .center
        addSubview(label)

        if type == .liveTracking {
            liveIndicator = LiveIndicator(size: .large, color: Colors.white)
            addSubview(liveIndicator!)
        }

        setupConstraints()
    }

    func setupConstraints() {
        let imageLeadingOffset: CGFloat = type == .directionLarge ? 12 : 8
        var imageSize: CGSize {
            var constant: CGFloat {
                switch type {
                case .liveTracking: return 0.87
                case .directionSmall: return 0.75
                case .directionLarge: return 1
                }
            }
            return CGSize(width: image.frame.width * constant, height: image.frame.height * constant)
        }
        let labelLeadingOffset: CGFloat = type == .liveTracking ? 3 : 6
        let liveIndicatorLeadingOffset = 5

        baseView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        image.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(imageLeadingOffset)
            make.centerY.equalToSuperview()
            make.size.equalTo(imageSize)
        }

        label.snp.makeConstraints { make in
            make.leading.equalTo(image.snp.trailing).offset(labelLeadingOffset)
            make.centerY.equalToSuperview()
            make.size.equalTo(label.intrinsicContentSize)
        }

        if let liveIndicator = liveIndicator {
            liveIndicator.snp.makeConstraints { make in
                make.leading.equalTo(label.snp.trailing).offset(liveIndicatorLeadingOffset)
                make.centerY.equalToSuperview()
                make.size.equalTo(liveIndicator.intrinsicContentSize)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        type = .directionSmall
        number = 99
        super.init(coder: aDecoder)
    }

    // MARK: Reuse

    func prepareForReuse() {
        baseView.removeFromSuperview()
        label.removeFromSuperview()
        image.removeFromSuperview()
        liveIndicator?.removeFromSuperview()
    }

}
