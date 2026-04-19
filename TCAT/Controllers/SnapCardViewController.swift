//
//  SnapCardViewController.swift
//  TCAT
//
//  Created by Gabriel Castillo on 4/19/26.
//  Copyright © 2026 cuappdev. All rights reserved.
//

import SnapKit
import UIKit

/// Base class for snap-to-grid card overlays that sit above the map.
/// Subclasses declare `snapHeights`, add their content to `cardView`,
/// and override the hook methods to respond to snap/drag events.
class SnapCardViewController: UIViewController {

    // MARK: - Subclass interface

    /// Snap heights in ascending order (collapsed → expanded).
    var snapHeights: [CGFloat] { fatalError("Subclasses must override snapHeights") }

    /// Bottom inset from safe area for `cardView`. Override when a floating button overlaps the card bottom.
    var cardBottomInset: CGFloat { 16 }

    /// Color of the drag indicator pill. Override to match the card's top content.
    var dragIndicatorColor: UIColor { Colors.naviOrange }

    /// Extra views (e.g. floating action buttons) to fade in during entrance and fade out on dismiss.
    func extraEntranceViews() -> [UIView] { [] }

    /// Called synchronously inside `snap(to:animated:)`, before the layout animation fires.
    /// Override to show/hide content and start concurrent content animations.
    func didSnap(to index: Int, animated: Bool) {}

    /// Called each frame during a pan gesture. Override to update sub-element alphas.
    func dragDidChange(height: CGFloat) {}

    // MARK: - Shared views (accessible to subclasses)

    let cardView = UIView()
    let dragIndicator = UIView()
    let backButton = UIButton(type: .system)

    // MARK: - State

    private(set) var currentSnapIndex = 0
    var cardHeightConstraint: Constraint?
    private var panStartHeight: CGFloat = 0

    // MARK: - Callback

    var onDismiss: (() -> Void)?

    // MARK: - Lifecycle

    override func loadView() {
        view = PassthroughView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupCardBase()
        setupCardBaseConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance()
    }

    // MARK: - Setup

    private func setupCardBase() {
        cardView.backgroundColor = Colors.white
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = Colors.black.cgColor
        cardView.layer.shadowOpacity = 0.15
        cardView.layer.shadowOffset = .zero
        cardView.layer.shadowRadius = 8
        cardView.clipsToBounds = false
        cardView.alpha = 0
        view.addSubview(cardView)
        cardView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))

        dragIndicator.backgroundColor = dragIndicatorColor
        dragIndicator.layer.cornerRadius = 1.5
        cardView.addSubview(dragIndicator)

        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: chevronConfig), for: .normal)
        backButton.backgroundColor = Colors.white
        backButton.layer.cornerRadius = 20
        backButton.clipsToBounds = false
        backButton.tintColor = Colors.primaryText
        backButton.alpha = 0
        backButton.layer.shadowColor = Colors.black.cgColor
        backButton.layer.shadowOpacity = 0.15
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        backButton.layer.shadowRadius = 4
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backButton)
    }

    func setupCardBaseConstraints() {
        cardView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(cardBottomInset)
            cardHeightConstraint = make.height.equalTo(snapHeights[0]).constraint
        }

        dragIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(10)
            make.size.equalTo(CGSize(width: 36, height: 3))
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(8)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
    }

    // MARK: - Entrance animation

    func animateEntrance() {
        let extras = extraEntranceViews()
        cardView.transform = CGAffineTransform(translationX: 0, y: 60)
        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.4,
            options: [.allowUserInteraction]
        ) {
            self.cardView.alpha = 1
            self.cardView.transform = .identity
            self.backButton.alpha = 1
            extras.forEach { $0.alpha = 1 }
        }
    }

    // MARK: - Pan gesture

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        switch gesture.state {
        case .began:
            panStartHeight = snapHeights[currentSnapIndex]

        case .changed:
            let newHeight = (panStartHeight - translation.y)
                .clamped(to: snapHeights.first!...snapHeights.last!)
            cardHeightConstraint?.update(offset: newHeight)
            view.layoutIfNeeded()
            dragDidChange(height: newHeight)

        case .ended, .cancelled:
            let velocity = gesture.velocity(in: view).y
            let currentHeight = panStartHeight - translation.y
            snap(to: bestSnapIndex(for: currentHeight, velocity: velocity), animated: true)

        default:
            break
        }
    }

    private func bestSnapIndex(for height: CGFloat, velocity: CGFloat) -> Int {
        if velocity < -400, currentSnapIndex < snapHeights.count - 1 { return currentSnapIndex + 1 }
        if velocity > 400, currentSnapIndex > 0 { return currentSnapIndex - 1 }
        return snapHeights.indices.min(by: {
            abs(snapHeights[$0] - height) < abs(snapHeights[$1] - height)
        }) ?? 0
    }

    func snap(to index: Int, animated: Bool) {
        currentSnapIndex = index
        cardHeightConstraint?.update(offset: snapHeights[index])
        didSnap(to: index, animated: animated)
        if animated {
            UIView.animate(
                withDuration: 0.45,
                delay: 0,
                usingSpringWithDamping: 0.82,
                initialSpringVelocity: 0.4,
                options: [.allowUserInteraction]
            ) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.layoutIfNeeded()
        }
    }

    // MARK: - Dismiss

    @objc func backTapped() {
        let extras = extraEntranceViews()
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: []
        ) {
            self.cardView.alpha = 0
            self.cardView.transform = CGAffineTransform(translationX: 0, y: 60)
            self.backButton.alpha = 0
            extras.forEach { $0.alpha = 0 }
        } completion: { _ in
            self.onDismiss?()
            self.remove()
        }
    }

}
