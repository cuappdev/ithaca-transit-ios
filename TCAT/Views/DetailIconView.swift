//
//  DetailIconView.swift
//  TCAT
//
//  Created by Matthew Barker on 2/12/17.
//  Copyright © 2017 cuappdev. All rights reserved.
//

import UIKit
import SnapKit

class DetailIconView: UIView {

    private let labelLeadingInset: CGFloat = 16
    private let labelInsetFromCenterY: CGFloat = 1

    static let width: CGFloat = 114
    private var scheduledLabelCentered: Constraint?
    private var scheduledLabelOffsetFromCenter: Constraint?
    private var isSet: Bool = false

    private var delayedTimeLabel = UILabel()
    private var scheduledTimeLabel = UILabel()
    private var connectorBottom = UIView()
    private var connectorTop = UIView()
    private var statusCircle: Circle!

    init(for direction: Direction, isFirstStep: Bool, isLastStep: Bool) {
        super.init(frame: .zero)

        // Format and place time labels
        scheduledTimeLabel.font = .getFont(.regular, size: 14)
        delayedTimeLabel.font = .getFont(.regular, size: 14)
        delayedTimeLabel.textColor = Colors.lateRed

        if direction.type == .walk {
            if isLastStep {
                statusCircle = Circle(size: .large, style: .bordered, color: Colors.dividerTextField)
                connectorTop.backgroundColor = Colors.dividerTextField
                connectorBottom.backgroundColor = .clear
            } else {
                statusCircle = Circle(size: .small, style: .solid, color: Colors.dividerTextField)
                connectorTop.backgroundColor = Colors.dividerTextField
                connectorBottom.backgroundColor = Colors.dividerTextField
                if isFirstStep {
                    connectorTop.backgroundColor = .clear
                }
            }
        } else {
            if isLastStep {
                statusCircle = Circle(size: .large, style: .bordered, color: Colors.tcatBlue)
                connectorTop.backgroundColor = Colors.tcatBlue
                connectorBottom.backgroundColor = .clear
            } else {
                statusCircle = Circle(size: .small, style: .solid, color: Colors.tcatBlue)
                if direction.type == .depart {
                    connectorTop.backgroundColor = Colors.dividerTextField
                    connectorBottom.backgroundColor = Colors.tcatBlue
                } else if direction.type == .transfer {
                    connectorTop.backgroundColor = Colors.tcatBlue
                    connectorBottom.backgroundColor = Colors.tcatBlue
                } else { // type == .arrive
                    connectorTop.backgroundColor = Colors.tcatBlue
                    connectorBottom.backgroundColor = Colors.dividerTextField
                }
                if isFirstStep {
                    connectorTop.backgroundColor = .clear
                }
            }
        }

        if isFirstStep && isLastStep {
            connectorTop.backgroundColor = .clear
            connectorBottom.backgroundColor = .clear
        }

        addSubview(scheduledTimeLabel)
        addSubview(delayedTimeLabel)
        addSubview(connectorTop)
        addSubview(connectorBottom)
        addSubview(statusCircle)

        setupConstraints()

        updateTimes(with: direction, isLast: isLastStep)
    }

    private func setupConstraints() {
        let connectorTrailingInset = 14
        let connectorWidth = 4

        connectorTop.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(connectorTrailingInset)
            make.top.equalToSuperview()
            make.bottom.equalTo(snp.centerY)
            make.width.equalTo(connectorWidth)
        }

        connectorBottom.snp.makeConstraints { make in
            make.trailing.equalTo(connectorTop)
            make.bottom.equalToSuperview()
            make.top.equalTo(snp.centerY)
            make.width.equalTo(connectorWidth)
        }

        statusCircle.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(statusCircle.intrinsicContentSize)
            make.centerX.equalTo(connectorTop)
        }

        scheduledTimeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(labelLeadingInset)
            make.size.greaterThanOrEqualTo(scheduledTimeLabel.intrinsicContentSize)
            scheduledLabelOffsetFromCenter = make.bottom.equalTo(snp.centerY).offset(-labelInsetFromCenterY).constraint
        }
        scheduledLabelOffsetFromCenter?.deactivate()
        scheduledTimeLabel.snp.makeConstraints { make in
            scheduledLabelCentered = make.centerY.equalToSuperview().constraint
        }

        delayedTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(snp.centerY).offset(labelInsetFromCenterY)
            make.size.greaterThanOrEqualTo(delayedTimeLabel.intrinsicContentSize)
            make.leading.equalToSuperview().inset(labelLeadingInset)
        }
    }

    private func setTimeLabelTexts(for direction: Direction, isLastStep: Bool) {
        var scheduledTimeString: String {
            if direction.type == .walk {
                return isLastStep ? direction.endTimeWithDelayDescription : direction.startTimeWithDelayDescription
            } else {
                return isLastStep ? direction.endTimeDescription : direction.startTimeDescription
            }
        }
        let delayedTimeString = isLastStep
            ? direction.endTimeWithDelayDescription
            : direction.startTimeWithDelayDescription

        scheduledTimeLabel.text = scheduledTimeString
        delayedTimeLabel.text = delayedTimeString
    }

    // MARK: - Utility Functions

    public func updateTimes(with newDirection: Direction, isLast: Bool = false) {
        updateTimeLabels(with: newDirection, isLast: isLast)
    }

    /// Update scheduled label with direction's delay description. Use self.direction by default.
    func updateTimeLabels(with direction: Direction, isLast: Bool = false) {

        setTimeLabelTexts(for: direction, isLastStep: isLast)

        if direction.type == .walk {
            if let delay = direction.delay {
                if delay < 60 {
                    scheduledTimeLabel.textColor = Colors.liveGreen
                    centerScheduledLabel()
                    hideDelayedLabel()
                } else {
                    scheduledTimeLabel.textColor = Colors.primaryText
                    showDelayedLabel()
                    offsetScheduledLabel()
                }
            } else {
                scheduledTimeLabel.textColor = Colors.primaryText
                hideDelayedLabel()
                centerScheduledLabel()
            }
        } else {
            if let delay = direction.delay {
                if delay < 60 {
                    scheduledTimeLabel.textColor = Colors.liveGreen
                    centerScheduledLabel()
                    hideDelayedLabel()
                } else {
                    scheduledTimeLabel.textColor = Colors.primaryText
                    showDelayedLabel()
                    offsetScheduledLabel()
                }
            } else {
                scheduledTimeLabel.textColor = Colors.primaryText
                hideDelayedLabel()
                centerScheduledLabel()
            }
        }

    }

    private func offsetScheduledLabel() {
        scheduledLabelCentered?.deactivate()
        scheduledLabelOffsetFromCenter?.activate()
    }

    private func centerScheduledLabel() {
        scheduledLabelOffsetFromCenter?.deactivate()
        scheduledLabelCentered?.activate()
    }

    func hideDelayedLabel() {
        delayedTimeLabel.isHidden = true
    }

    func showDelayedLabel() {
        delayedTimeLabel.isHidden = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
