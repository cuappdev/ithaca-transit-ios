//
//  SettingsAboutViewController.swift
//  TCAT
//
//  Created by Asen Ou on 3/16/25.
//  Copyright © 2025 Cornell AppDev. All rights reserved.
//

import UIKit

class SettingsAboutViewController: UIViewController {

    // MARK: - Properties (view)
    private let subtitleLabel = UILabel()
    private let headerView = SettingsAboutHeaderView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let websiteButton = ButtonView(content: PillButtonView())

    // MARK: - Properties (data)
    private var firstTimeLoading = true

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationItem()
        setUpView()
        setUpConstraints()
        setUpCarouselViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Track Analytics
        let payload = SettingsAboutPageOpenedPayload()
        TransitAnalytics.shared.log(payload)

        scrollView.flashScrollIndicators()
        if !firstTimeLoading {
            reshuffle()
        } else {
            firstTimeLoading = false
        }
    }

    private func setUpNavigationItem() {
        navigationItem.title = "About Transit"
    }

    private func setUpView() {
        view.backgroundColor = .white

        view.addSubview(subtitleLabel)
        setUpSubtitleLabel()

        view.addSubview(headerView)

        view.addSubview(scrollView)
        setUpScrollView()

        view.addSubview(websiteButton)
        setUpWebsiteButton()
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.text = "Learn more about Cornell AppDev"
        subtitleLabel.textColor = .gray
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
//        subtitleLabel.textColor = UIColor.Eatery.gray06
//        subtitleLabel.font = .preferredFont(for: .body, weight: .medium)
    }

    private func setUpScrollView() {
        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
    }

    private func setUpWebsiteButton() {
        let pillView = websiteButton.content
        pillView.titleLabel.text = "Visit our website"
        pillView.imageView.image = UIImage(named: "Globe")?.withRenderingMode(.alwaysTemplate)
        pillView.tintColor = .black
        pillView.backgroundColor = Colors.carouselGray
        pillView.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        websiteButton.buttonPress { _ in
            if let url = URL(string: "https://www.cornellappdev.com/") {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }

    private func setUpConstraints() {
        subtitleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(view.layoutMarginsGuide)
        }

        headerView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(websiteButton.snp.top).offset(-24)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        websiteButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
            make.bottom.equalTo(view.layoutMarginsGuide).inset(16)
        }
    }

    private struct HSection {
        let title: String
        let members: [String]
    }

    private let sections = [
        HSection(title: "Pod Leads", members: [
            "Anvi Savant",
            "Cindy Liang",
            "Maxwell Pang",
            "Amanda He",
            "Connor Reinhold",
            "Omar Rasheed",
            "Maya Frai",
            "Matt Barker"
        ]),
        HSection(title: "iOS Developers", members: [
            "Angelina Chen",
            "Asen Ou",
            "Jayson Hahn",
            "Daniel Chuang",
            "William Ma",
            "Sergio Diaz",
            "Kevin Chan",
            "Omar Rasheed",
            "Lucy Xu",
            "Haiying Weng",
            "Daniel Vebman",
            "Yana Sang",
            "Matt Barker",
            "Austin Astorga",
            "Monica Ong"
        ]),
        HSection(title: "Android Developers", members: [
            "Mihili Herath",
            "Jonathan Chen",
            "Veronica Starchenko",
            "Adam Kadhim",
            "Lesley Huang",
            "Kevin Sun",
            "Chris Desir",
            "Connor Reinhold",
            "Aastha Shah",
            "Justin Jiang",
            "Haichen Wang",
            "Jonvi Rollins",
            "Preston Rozwood",
            "Ziwei Gu",
            "Abdullah Islam"
        ]),
        HSection(title: "Product Designers", members: [
            "Gillian Fang",
            "Leah Kim",
            "Amy Ge",
            "Lauren Jun",
            "Zain Khoja",
            "Maggie Ying",
            "Femi Badero",
            "Maya Frai",
            "Mind Apivessa"
        ]),
        HSection(title: "Marketers", members: [
            "Anvi Savant",
            "Christine Tao",
            "Luke Stewart",
            "Melika Khoshneviszadeh",
            "Eddie Chi",
            "Neha Malepati",
            "Emily Shiang",
            "Lucy Zhang",
            "Catherine Wei"
        ]),
        HSection(title: "Backend Developers", members: [
            "Nicole Qiu",
            "Daisy Chang",
            "Lauren Ah-Hot",
            "Maxwell Pang",
            "Mateo Weiner",
            "Cindy Liang",
            "Raahi Menon",
            "Kate Liang",
            "Alanna Zhou",
            "Kevin Chan",
            "Nate Schickler"
        ])
    ]

    private func addCarouselView(_ configure: (SettingsAboutMembersCarouselView) -> Void) {
        let carouselView = SettingsAboutMembersCarouselView()
        configure(carouselView)
        stackView.addArrangedSubview(carouselView)
    }

    private func setUpCarouselViews() {
        let sections = [sections[0]] + sections[1...].shuffled()
        for section in sections {
            addCarouselView(section)
        }
    }

    private func addCarouselView(_ section: HSection) {
        addCarouselView { carouselView in
            carouselView.addTitleView(section.title)
            carouselView.addSeparator()

            for (i, member) in section.members.shuffled().enumerated() {
                carouselView.addMemberView(name: member)

                if i != section.members.count - 1 {
                    carouselView.addSeparator()
                }
            }
        }
    }

    private func reshuffle() {
        let group = DispatchGroup()
        for subview in stackView.subviews {
            group.enter()
            UIView.animate(
                withDuration: 0.2,
                animations: { subview.alpha = 0.0 },
                completion: { _ in
                    subview.removeFromSuperview()
                    group.leave()
                }
            )
        }

        group.notify(queue: .main) {
            self.setUpCarouselViews()
        }
    }
}
