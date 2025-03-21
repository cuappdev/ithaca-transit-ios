//
//  ButtonView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/21/22.
//

import UIKit

class ButtonView<Content: UIView>: ContainerView<Content>, UIGestureRecognizerDelegate {

    private let button = UIButton(type: .custom)

    private var callback: ((UIButton) -> Void)?

    override init(content: Content) {
        super.init(content: content)

        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        button.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonTouchUpOutside), for: .touchUpOutside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func buttonPress(_ callback: ((UIButton) -> Void)?) {
        self.callback = callback
    }

    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func buttonTouchUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0.15, options: .beginFromCurrentState) { [weak self] in
            self?.transform = .identity
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self?.callback?(sender)
            }
        }
    }

    @objc private func buttonTouchUpOutside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0.15, options: .beginFromCurrentState) { [weak self] in
            self?.transform = .identity
        }
    }

}
