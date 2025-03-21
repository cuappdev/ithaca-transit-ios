//
//  ContainerView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

// Applies the following transformations to the content view
//  1. content inset based on layoutMargins
//  2. corner radius crop (if cornerRadius is non-zero)
//  3. shadow
//
class ContainerView<Content: UIView>: UIView {

    let cornerRadiusView = UIView()

    override var backgroundColor: UIColor? {
        didSet {
            cornerRadiusView.backgroundColor = backgroundColor
            super.backgroundColor = nil
        }
    }

    var content: Content {
        willSet {
            content.removeFromSuperview()
        }
        didSet {
            cornerRadiusView.addSubview(content)
            content.snp.makeConstraints { make in
                make.edges.equalTo(layoutMarginsGuide)
            }
        }
    }

    var cornerRadius: CGFloat = 0 {
        didSet {
            cornerRadiusView.clipsToBounds = cornerRadius != 0
            cornerRadiusView.layer.cornerRadius = cornerRadius
        }
    }

    var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }

    var shadowOffset: CGSize = .zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    var shadowOpacity: Double = 0 {
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }

    var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    private var isPill: Bool = false
    var interceptsHitTests: Bool = false

    init(content: Content) {
        self.content = content

        super.init(frame: .null)

        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = .zero

        addSubview(cornerRadiusView)
        cornerRadiusView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        cornerRadiusView.addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalTo(layoutMarginsGuide)
        }
    }

    convenience init(pillContent: Content) {
        self.init(content: pillContent)
        self.isPill = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if isPill {
            cornerRadius = min(cornerRadiusView.bounds.width, cornerRadiusView.bounds.height) / 2
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if interceptsHitTests {
            return self
        }

        return super.hitTest(point, with: event)
    }

}
