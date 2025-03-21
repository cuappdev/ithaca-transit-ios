//
//  SettingsSupportView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/26/22.
//

import SwiftUI

//protocol SettingsSupportViewDelegate: AnyObject {
//
//    func openReportIssue(preselectedIssueType: ReportIssueViewController.IssueType?)
//
//}

struct SettingsSupportView: View {

    struct FAQItem {
        let title: String
        let body: Text
        var isExpanded: Bool = false

        var isReportIssueButtonShown: Bool = false
//        var preselectedIssueType: ReportIssueViewController.IssueType?
    }

//    var delegate: SettingsSupportViewDelegate?

//    @State var faqItems: [FAQItem] = [
//        FAQItem(
//            title: "Why do I see wrong or empty menus?",
//            body: Text("""
//            We work with Cornell Dining to get the most accurate menus to students. Sometimes, eateries change menus on the fly or run out of a certain item and have to serve something different.
//
//            If you see inaccurate menus, help us improve Eatery by letting us know what’s wrong.
//            """),
//            isReportIssueButtonShown: true,
//            preselectedIssueType: .inaccurateItem
//        ),
//        FAQItem(
//            title: "Why is an eatery closed when it says it should be open?",
//            body: Text("""
//            We work with Cornell Dining to get the most accurate hours to students. However, sometimes hours change suddenly because of special events or weather.
//
//            If you see incorrect hours, help us improve Eatery by letting us know the correct hours.
//            """),
//            isReportIssueButtonShown: true,
//            preselectedIssueType: .incorrectHours
//        ),
//        // TODO: Temporarily remove wait time FAQ
////        FAQItem(
////            title: "Why is the wait time longer?",
////            body: Text("""
////            We work with Cornell Dining to get the most accurate wait times to students. Sometimes, wait times can grow when classes or events end around meal times.
////
////            If you see inaccurate wait times, help us improve Eatery by letting us know how long you waited.
////            """),
////            isReportIssueButtonShown: true,
////            preselectedIssueType: .inaccurateWaitTime
////        ),
//        FAQItem(
//            title: "Why can’t I order food on Eatery?",
//            body: Text("""
//            We would love to develop an ordering app for Cornell. Unfortunately, Cornell works with GET™ App instead of us.
//
//            If you’d like them to change their mind, you can [send them an email](mailto:dining@cornell.edu) :-)
//            """),
//            isReportIssueButtonShown: false
//        )
//    ]

    var body: some View {
        List {
            Text("Report issues and contact Cornell AppDev")
                .foregroundColor(.gray)
                .listRowSeparator(.hidden)

            SwiftUI.Section {
                sectionHeader(title: "Make Transit Better")
                Text("Help us improve Transit by letting us know what’s wrong.")
                    .foregroundColor(.gray)

                Button {
                    // Do nothing for now
//                    delegate?.openReportIssue(preselectedIssueType: nil)

                } label: {
                    HStack(spacing: 6) {
                        Spacer()
                        Image("report")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Report an issue")
                            .padding(EdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0))
//                            .font(Font(UIFont.preferredFont(for: .body, weight: .semibold)))
                            .font(Font(UIFont.preferredFont(forTextStyle: .body)))
                        Spacer()
                    }
                }
                .foregroundColor(.white)
                .background(Color(Colors.tcatBlue))
                .clipShape(Capsule())

                Button {
                    guard let url = URL(string: "mailto:team@cornellappdev.com") else {
                        return
                    }

                    UIApplication.shared.open(url)

                } label: {
                    HStack(alignment: .center, spacing: 2) {
                        Spacer()
                        Text("Shoot us an email")
//                            .font(Font(UIFont.preferredFont(for: .subheadline, weight: .semibold)))
                            .font(Font(UIFont.preferredFont(forTextStyle: .subheadline)))
                        Image("externalLink")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 16, height: 16)
                        Spacer()
                    }
                    .foregroundColor(Color(Colors.tcatBlue))
                }
                .buttonStyle(.plain)
            }
            .listRowSeparator(.hidden)

            SwiftUI.Section {
                sectionHeader(title: "Frequently Asked Questions")
//
//                ForEach(0..<faqItems.count) { index in
//                    let item = faqItems[index]
//
//                    VStack(spacing: 12) {
//                        Spacer(minLength: 0)
//
//                        Button {
//                            faqItems[index].isExpanded.toggle()
//
//                        } label: {
//                            HStack {
//                                Text(item.title)
//                                    .foregroundColor(Color("Black"))
//                                    .font(Font(UIFont.preferredFont(for: .subheadline, weight: .semibold)))
//                                Spacer()
//                                Image("ChevronDown")
//                                    .resizable()
//                                    .renderingMode(.template)
//                                    .foregroundColor(Color("EateryBlue"))
//                                    .frame(width: 16, height: 16)
//                                    .rotationEffect(item.isExpanded ? Angle(degrees: 180) : Angle(degrees: 0))
//                            }
//                        }
//
//                        if item.isExpanded {
//                            item.body
//                                .multilineTextAlignment(.leading)
//                                .foregroundColor(Color("Gray05"))
//                                .font(Font(UIFont.preferredFont(for: .subheadline, weight: .medium)))
//                                .frame(maxWidth: .infinity, alignment: .leading)
//
//                            if item.isReportIssueButtonShown {
//                                HStack {
//                                    Button {
//                                        delegate?.openReportIssue(preselectedIssueType: item.preselectedIssueType)
//
//                                    } label: {
//                                        HStack(spacing: 2) {
//                                            Image("Report")
//                                                .resizable()
//                                                .renderingMode(.template)
//                                                .frame(width: 16, height: 16)
//                                            Text("Report an issue")
//                                                .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
//                                        }
//                                        .foregroundColor(Color("Black"))
//                                        .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
//                                    }
//                                    .background(Color("Gray00"))
//                                    .clipShape(Capsule())
//
//                                    Spacer()
//                                }
//                            }
//                        }
//
//                        Spacer(minLength: 0)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                }
//
//                Spacer().listRowSeparator(.hidden, edges: .bottom)
            }
        }
        .listStyle(.plain)
    }

    private func sectionHeader(title: String) -> some View {
        Text(title)
//            .font(Font(UIFont.preferredFont(for: .title2, weight: .semibold)))
            .font(Font(generateFont(for: .title2, weight: .semibold)))
            .foregroundColor(Color(Colors.black))
            .padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
    }

    private func generateFont(for style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: descriptor.pointSize, weight: weight)
        return metrics.scaledFont(for: font)
    }
}
