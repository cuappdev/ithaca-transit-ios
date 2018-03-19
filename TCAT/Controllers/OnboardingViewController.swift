//
//  OnboardingViewController.swift
//  TCAT
//
//  Created by Mihir Chauhan on 3/16/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit
import Presentation

class OnboardingViewController: PresentationController {
    
    //
    // MARK: Variables
    //
    
    /// Change the main view's background color
    let backgroundColor = UIColor(hex: "C0DDEB")
    
    //
    // Navigation
    //
    
    /// The text color of the navigation buttons
    let navigationAttributes: [NSAttributedStringKey : Any] = [
        NSAttributedStringKey.foregroundColor : UIColor(hex: "243C47")
    ]
    
    //
    // Labels
    //
    
    //
    //  Header Label
    //
    
    /// The position of the header label
    let titleLabelPosition = Position(left: 0.5, top: 0.2)
    
    let titleLabelFontName = Constants.Fonts.SanFrancisco.Bold
    
    let titleLabelFontSize: CGFloat = 48.0
    
    let titleLabelTextColor = UIColor(hex: "243C47")
    
    let titleLabelMessages = [
        
        "Welcome to Ithaca Transit.",
        "Live Tracking.",
        "Search Anywhere.",
        "Your Favorites.",
        "All the best features. All in one app."
        
    ]
    
    //
    // Detail Label
    //
    
    /// The position of the main label
    let detailLabelPosition = Position(left: 0.5, top: 0.35)
    
    /// Change the font type of text label
    let detailLabelFontName = Constants.Fonts.SanFrancisco.Medium
    
    /// Change the font size of text label
    let detailLabelFontSize: CGFloat = 32.0
    
    /// Change the text label color
    let detailLabelTextColor = UIColor(hex: "243C47")
    
    /// Change the amount of messages in the view. The number of pages shown will equal the number of messages
    let detailLabelMessages = [
        
        "Beautiful and simple end-to-end navigation app for TCAT. Made by AppDev.",
        "Know exactly where your bus is and when it will be there.",
        "From Ithaca Mall to Taughannock Falls, search any location and get there fast.",
        "All of your favorite destinations are just one tap away.",
        ""
        
    ]
    
    //
    // Assets
    //
    
    /// Set the asset type, position, and speed.
    let backgroundImages = [
        
        BackgroundImage(name: "treesnroad", left: -2.7, top: 0.71, speed: -1.3),
        BackgroundImage(name: "tcat", left: -0.60, top: 0.703, speed: 0.4),
        BackgroundImage(name: "hill", left: -1.5, top: 0.55, speed: -0.5),
        BackgroundImage(name: "mountain", left: -1.0, top: 0.41, speed: -0.2),
        BackgroundImage(name: "cloud", left: -2.0, top: 0.10, speed: -0.1),
        
    ]
    
    //
    // Ground View
    //
    
    /// The size of the ground view
    let groundViewSize = CGSize(width: 1024, height: 60)
    
    /// The position of the ground view
    let groundViewPosition = Position(left: 0.0, bottom: 0.063)
    
    /// The background color of the ground view
    let groundViewBackgroundColor = UIColor(hex: "243C47")
    
    
    
    //
    // MARK: Implementation
    //
    
    /// Used to determine what context this view is being shown in
    var isInitialViewing: Bool = true
    
    struct BackgroundImage {
        
        let name: String
        let left: CGFloat
        let top: CGFloat
        let speed: CGFloat
        
        init(name: String, left: CGFloat, top: CGFloat, speed: CGFloat) {
            self.name = name
            self.left = left
            self.top = top
            self.speed = speed
        }
        
        func positionAt(_ index: Int) -> Position? {
            var position: Position?
            
            if index == 0 || speed != 0.0 {
                let currentLeft = left + CGFloat(index) * speed
                position = Position(left: currentLeft, top: top)
            }
            
            return position
        }
        
    }
    
    private lazy var dismissButton: UIBarButtonItem = { [unowned self] in
        let dismissButton = UIBarButtonItem(
            title: "Dismiss",
            style: .plain,
            target: self,
            action: #selector(dismissView)
        )
        
        dismissButton.setTitleTextAttributes(navigationAttributes, for: .normal)
        
        return dismissButton
    }()
    
    @objc func dismissView() {
        
        if isInitialViewing {
            
            let rootVC = HomeViewController()
            let desiredViewController = CustomNavigationController(rootViewController: rootVC)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let snapshot: UIView = appDelegate.window!.snapshotView(afterScreenUpdates: true)!
            desiredViewController.view.addSubview(snapshot)
            
            appDelegate.window?.rootViewController = desiredViewController
            userDefaults.setValue(true, forKey: Constants.UserDefaults.onboardingShown)
            
            UIView.animate(withDuration: 0.5, animations: {
                snapshot.layer.opacity = 0
                snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
            }, completion: { _ in
                snapshot.removeFromSuperview()
            })
            
        } else {
            dismiss(animated: true)
        }
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    convenience init(initialViewing: Bool) {
        self.init(pages: [])
        self.isInitialViewing = initialViewing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitle = false
        navigationItem.leftBarButtonItem = isInitialViewing ? nil : dismissButton
        
        view.backgroundColor = backgroundColor
        UIApplication.shared.statusBarStyle = .default
        
        configureSlides()
        configureBackground()
    }
    
    private func configureSlides() {
        
        let width = UIScreen.main.bounds.width < 550 ? UIScreen.main.bounds.width : 550
        let height: CGFloat = 200
        
        // Detail Labels
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let detailWidth: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0.8
        let detailHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0.6
        
        let detailFont = UIFont(name: detailLabelFontName, size: detailLabelFontSize * detailHeight)!
        
        let attributes = [
            NSAttributedStringKey.font: detailFont,
            NSAttributedStringKey.foregroundColor: detailLabelTextColor,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]
        
        let detailTitles = detailLabelMessages.map { title -> Content in
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: width * detailWidth, height: height * detailHeight))
            label.numberOfLines = 5
            label.attributedText = NSAttributedString(string: title, attributes: attributes)
            return Content(view: label, position: detailLabelPosition)
        }
        
        // Title Labels
        
        let headerParagraphStyle = NSMutableParagraphStyle()
        headerParagraphStyle.alignment = .center
        
        let headerWidth: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0.9
        let headerHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0.6
        let headerFont = UIFont(name: titleLabelFontName, size: titleLabelFontSize * headerHeight)!
        
        let headerAttributes = [
            NSAttributedStringKey.font: headerFont,
            NSAttributedStringKey.foregroundColor: titleLabelTextColor,
            NSAttributedStringKey.paragraphStyle: headerParagraphStyle
        ]
        
        let headerTitles = titleLabelMessages.map { title -> Content in
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: width * headerWidth, height: height * headerHeight))
            label.numberOfLines = 5
            label.attributedText = NSAttributedString(string: title, attributes: headerAttributes)
            return Content(view: label, position: titleLabelPosition)
        }
        
        // Button
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 160, height: 60)
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowColor = UIColor.mediumGrayColor.cgColor
        button.layer.shadowOpacity = 0.5
        button.setTitle("BEGIN", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: Constants.Fonts.SanFrancisco.Medium, size: 22)!
        button.backgroundColor = .tcatBlueColor // UIColor(hex: "D65851")
        button.layer.cornerRadius = 4
        let buttonPosition = Position(left: 0.5, top: 0.5)
        let startButton = Content(view: button, position: buttonPosition, centered: true)
        
        // Slides
        
        var slides = [SlideController]()
        
        for index in 0..<detailLabelMessages.count {
            
            var contents: [Content] = [detailTitles[index], headerTitles[index]]
            
            // Go Button
            if index == detailLabelMessages.count - 1 {
                contents.append(startButton)
            }
            
            let controller = SlideController(contents: contents)
            
            // Title Labels
            controller.add(animation: Content.centerTransition(forSlideContent: headerTitles[index]))
            controller.add(animation: TransitionAnimation(content: headerTitles[index], destination: titleLabelPosition))
            
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
    
    private func configureBackground() {
        
        var contents = [Content]()
        
        for backgroundImage in backgroundImages {
            let imageView = UIImageView(image: UIImage(named: backgroundImage.name))
            if let position = backgroundImage.positionAt(0) {
                contents.append(Content(view: imageView, position: position, centered: false))
            }
        }
        
        addToBackground(contents)
        
        for row in 1...4 {
            for (column, backgroundImage) in backgroundImages.enumerated() {
                if let position = backgroundImage.positionAt(row), let content = contents.at(column) {
                    addAnimation(TransitionAnimation(content: content, destination: position,
                                                     duration: 2.0, damping: 1.0), forPage: row)
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

private extension Array {
    func at(_ index: Int?) -> Element? {
        var object: Element?
        if let index = index , index >= 0 && index < endIndex {
            object = self[index]
        }
        
        return object
    }
}
