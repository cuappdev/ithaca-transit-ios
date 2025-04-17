//
//  OnboardingViewController.swift
//  TCAT
//
//  Created by Mihir Chauhan on 3/16/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import Presentation
import UIKit

class OnboardingViewController: PresentationController {

    struct BackgroundImage {

        let name: String
        let left: CGFloat
        let top: CGFloat
        let speed: CGFloat

        func positionAt(_ index: Int) -> Position? {
            var position: Position?

            if index == 0 || speed != 0.0 {
                let currentLeft = left + CGFloat(index) * speed
                position = Position(left: currentLeft, top: top)
            }

            return position
        }

    }

    /// Change the main view's background color
    private let backgroundColor = UIColor(hex: "C0DDEB")

    /// The text color of the navigation buttons
    private let navigationAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(hex: "243C47")
    ]

    /// The position of the header label
    private let titleLabelFontName = Fonts.bold
    private let titleLabelFontSize: CGFloat = 48.0
    private let titleLabelPosition = Position(left: 0.5, top: 0.2)
    private let titleLabelTextColor = UIColor(hex: "243C47")
    private let titleLabelMessages = [
        Constants.Onboarding.welcome,
        Constants.Onboarding.liveTracking,
        Constants.Onboarding.searchAnywhere,
        Constants.Onboarding.favorites,
        Constants.Onboarding.bestFeatures
    ]

    /// The position of the main label
    private let detailLabelPosition = Position(left: 0.5, top: 0.35)

    /// Change the font type of text label
    private let detailLabelFontName = Fonts.medium

    /// Change the font size of text label
    private let detailLabelFontSize: CGFloat = 32.0

    /// Change the text label color
    private let detailLabelTextColor = UIColor(hex: "243C47")

    /// Change the amount of messages in the view. The number of pages shown will equal the number of messages
    private let detailLabelMessages = [
        Constants.Onboarding.welcomeMessage,
        Constants.Onboarding.liveTrackingMessage,
        Constants.Onboarding.searchAnywhereMessage,
        Constants.Onboarding.favoritesMessage,
        ""
    ]

    /// Set the asset type, position, and speed.
    private let backgroundImages = [
        BackgroundImage(name: "treesnroad", left: -2.7, top: 0.71, speed: -1.3),
        BackgroundImage(name: "navi_tcat", left: -0.60, top: 0.703, speed: 0.4),
        BackgroundImage(name: "hill", left: -1.5, top: 0.55, speed: -0.5),
        BackgroundImage(name: "mountain", left: -1.0, top: 0.41, speed: -0.2),
        BackgroundImage(name: "cloud", left: -2.0, top: 0.10, speed: -0.1)
    ]

    /// The size of the ground view
    private let groundViewSize = CGSize(width: 1024, height: 60)

    /// The position of the ground view
    private let groundViewPosition = Position(left: 0.0, bottom: 0.063)

    /// The background color of the ground view
    private let groundViewBackgroundColor = UIColor(hex: "243C47")

    /// Used to determine what context this view is being shown in
    private var isInitialViewing: Bool = true

    private lazy var dismissButton: UIBarButtonItem = { [unowned self] in
        let dismissButton = UIBarButtonItem(
            title: Constants.Onboarding.dismiss,
            style: .plain,
            target: self,
            action: #selector(dismissView)
        )
        dismissButton.setTitleTextAttributes(navigationAttributes, for: .normal)

        return dismissButton
    }()

    let width = UIScreen.main.bounds.width < 550 ? UIScreen.main.bounds.width : 550
    let height: CGFloat = 200

    @objc private func dismissView() {
        if isInitialViewing {

            let rootVC = ParentHomeMapViewController(
                contentViewController: HomeMapViewController(),
                drawerViewController: FavoritesViewController(isEditing: false)
            )
            let desiredViewController = CustomNavigationController(rootViewController: rootVC)

            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let window = appDelegate.window,
                let snapshot = window.snapshotView(afterScreenUpdates: true) {

                desiredViewController.view.addSubview(snapshot)
                window.rootViewController = desiredViewController
                UIView.animate(
                    withDuration: 0.5,
                    animations: {
                        snapshot.layer.opacity = 0
                        snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
                    }
                    , completion: { _ in
                        snapshot.removeFromSuperview()
                    }
                )
            }
            userDefaults.setValue(true, forKey: Constants.UserDefaults.onboardingShown)
        } else {
            dismiss(animated: true)
        }
    }

    init(initialViewing: Bool) {
        self.isInitialViewing = initialViewing
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationTitle = false
        navigationItem.leftBarButtonItem = isInitialViewing ? nil : dismissButton
        view.backgroundColor = backgroundColor

        configureSlides()
        configureBackground()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    private func configureSlides() {

        let detailTitles = getDetailLabelTitles()
        let headerTitles = getHeaderLabelTitles()
        let startButton = Content(view: getBeginButton(), position: Position(left: 0.5, top: 0.5), centered: true)

        // Slides
        var slides = [SlideController]()

        (0..<detailLabelMessages.count).forEach { index in
            var contents: [Content] = [detailTitles[index], headerTitles[index]]

            // Go Button
            if index == detailLabelMessages.count - 1 {
                contents.append(startButton)
            }

            let controller = SlideController(contents: contents)

            // Title Labels
            controller.add(animation: Content.centerTransition(forSlideContent: headerTitles[index]))
            controller.add(
                animation: TransitionAnimation(
                    content: headerTitles[index],
                    destination: titleLabelPosition
                )
            )

            // Detail Labels
            let animation = Content.centerTransition(forSlideContent: detailTitles[index])
            controller.add(animation: animation)

            // Button
            controller.add(content: startButton)
            controller.add(animation: Content.centerTransition(forSlideContent: startButton))

            slides.append(controller)
        }
        add(slides)
    }

    private func getHeaderLabelTitles() -> [Content] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let headerWidth: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0.9
        let headerHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0.6

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.getFont(titleLabelFontName, size: titleLabelFontSize * headerHeight),
            .foregroundColor: titleLabelTextColor,
            .paragraphStyle: paragraphStyle
        ]

        return titleLabelMessages.map { title -> Content in
            let label = UILabel()
            label.frame.size = CGSize(width: width * headerWidth, height: height * headerHeight)
            label.numberOfLines = 5
            label.attributedText = NSAttributedString(string: title, attributes: attributes)
            return Content(view: label, position: titleLabelPosition)
        }
    }

    private func getDetailLabelTitles() -> [Content] {
        let detailWidth: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0.8
        let detailHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0.6

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.getFont(detailLabelFontName, size: detailLabelFontSize * detailHeight),
            .foregroundColor: detailLabelTextColor,
            .paragraphStyle: paragraphStyle
        ]

        return detailLabelMessages.map { title -> Content in
            let label = UILabel()
            label.frame.size = CGSize(width: width * detailWidth, height: height * detailHeight)
            label.numberOfLines = 5
            label.attributedText = NSAttributedString(string: title, attributes: attributes)
            return Content(view: label, position: detailLabelPosition)
        }
    }

    private func getBeginButton() -> UIButton {
        let button = UIButton()
        button.frame.size = CGSize(width: 160, height: 60)
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowColor = Colors.metadataIcon.cgColor
        button.layer.shadowOpacity = 0.5
        button.setTitle(Constants.Onboarding.begin, for: .normal)
        button.setTitleColor(Colors.white, for: .normal)
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        button.titleLabel?.font = .getFont(.medium, size: 22)
        button.backgroundColor = Colors.naviTcatBlue
        button.layer.cornerRadius = 4

        return button
    }

    private func configureBackground() {
        var contents = [Content]()

        for backgroundImage in backgroundImages {
            let imageView = UIImageView(image: UIImage(named: backgroundImage.name))
            if let position = backgroundImage.positionAt(0) {
                contents.append(Content(view: imageView, position: position, centered: false))
            }
        }

        addToBackground(contents)

        (1...4).forEach { row in
            for (column, backgroundImage) in backgroundImages.enumerated() {
                if let position = backgroundImage.positionAt(row), let content = contents[optional: column] {
                    addAnimation(TransitionAnimation(
                        content: content,
                        destination: position,
                        duration: 2.0,
                        damping: 1.0
                    ), forPage: row)
                }
            }
        }

        let groundView = UIView(frame: CGRect(origin: .zero, size: groundViewSize))
        groundView.backgroundColor = groundViewBackgroundColor

        let groundContent = Content(
            view: groundView,
            position: groundViewPosition,
            centered: false
        )

        contents.append(groundContent)
        addToBackground([groundContent])
    }

}
