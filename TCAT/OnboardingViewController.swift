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
    let backgroundColor: UIColor = .tcatBlueColor
    
    //
    // Navigation
    //
    
    /// The text color of the navigation buttons
    let navigationAttributes: [NSAttributedStringKey : Any] = [
        NSAttributedStringKey.foregroundColor : UIColor.white
    ]
    
    //
    // Labels
    //
    
    /// The position of the main labels
    let labelPosition = Position(left: 0.7, top: 0.35)
    
    /// Change the text font type
    let textFontName = "HelveticaNeue"
    
    /// Change the text font size
    let textFontSize: CGFloat = 34.0
    
    /// Change the text color
    let textColor = UIColor(hex: "FFE8A9")
    
    /// Change the amount of messages in the view. The number of pages shown will equal the number of messages
    let messages = [
        
        "Parallax is a displacement or difference in the apparent position of an object viewed along two different lines of sight.",
        "It's measured by the angle or semi-angle of inclination between those two lines.",
        "The term is derived from the Greek word παράλλαξις (parallaxis), meaning 'alteration'.",
        "Nearby objects have a larger parallax than more distant objects when observed from different positions.",
        "http://en.wikipedia.org/wiki/Parallax"
        
    ]
    
    //
    // Assets
    //
    
    /// Set the asset type, position, and speed.
    let backgroundImages = [
        
        BackgroundImage(name: "Trees", left: 0.0, top: 0.743, speed: -0.3),
        BackgroundImage(name: "Bus", left: 0.02, top: 0.77, speed: 0.25),
        BackgroundImage(name: "Truck", left: 1.3, top: 0.73, speed: -1.5),
        BackgroundImage(name: "Roadlines", left: 0.0, top: 0.79, speed: -0.24),
        BackgroundImage(name: "Houses", left: 0.0, top: 0.627, speed: -0.16),
        BackgroundImage(name: "Hills", left: 0.0, top: 0.51, speed: -0.08),
        BackgroundImage(name: "Mountains", left: 0.0, top: 0.29, speed: 0.0),
        BackgroundImage(name: "Clouds", left: -0.415, top: 0.14, speed: 0.18),
        BackgroundImage(name: "Sun", left: 0.8, top: 0.07, speed: 0.0)
        
    ]
    
    //
    // Ground View
    //
    
    /// The size of the ground view
    let groundViewSize = CGSize(width: 1024, height: 60)
    
    /// The position of the ground view
    let groundViewPosition = Position(left: 0.0, bottom: 0.063)
    
    /// The background color of the ground view
    let groundViewBackgroundColor: UIColor = .clear
    
    
    
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
    
    private lazy var leftButton: UIBarButtonItem = { [unowned self] in
        let leftButton = UIBarButtonItem(
            title: "Previous",
            style: .plain,
            target: self,
            action: #selector(moveBack))
        
        leftButton.setTitleTextAttributes(navigationAttributes, for: .normal)
        
        return leftButton
    }()
    
    private lazy var rightButton: UIBarButtonItem = { [unowned self] in
        let rightButton = UIBarButtonItem(
            title: "Next",
            style: .plain,
            target: self,
            action: #selector(moveForward)
        )
        
        rightButton.setTitleTextAttributes(navigationAttributes, for: .normal)
        
        return rightButton
    }()
    
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
        navigationItem.leftBarButtonItem = dismissButton // isInitialViewing ? leftButton : dismissButton
        navigationItem.rightBarButtonItem = isInitialViewing ? rightButton : nil
        
        view.backgroundColor = backgroundColor
        
        configureSlides()
        configureBackground()
    }
    
    private func configureSlides() {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let ratio: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0.6
        let font = UIFont(name: textFontName, size: textFontSize * ratio)!
        
        let attributes = [
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.foregroundColor: textColor,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]
        
        let titles = messages.map { title -> Content in
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 550 * ratio, height: 200 * ratio))
            label.numberOfLines = 5
            label.attributedText = NSAttributedString(string: title, attributes: attributes)
            return Content(view: label, position: labelPosition)
        }
        
        var slides = [SlideController]()
        
        for index in 0..<messages.count {
            let controller = SlideController(contents: [titles[index]])
            controller.add(animations: [Content.centerTransition(forSlideContent: titles[index])])
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
