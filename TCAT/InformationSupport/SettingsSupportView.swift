//
//  SettingsSupportView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/26/22.
//

import SwiftUI

struct SettingsSupportView: View {

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
                    guard let url = URL(string: "mailto:team@cornellappdev.com") else {
                        return
                    }
                    UIApplication.shared.open(url)
                } label: {
                    HStack(spacing: 6) {
                        Spacer()
                        Image("report")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Shoot us an email")
                            .padding(EdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0))
//                            .font(Font(UIFont.preferredFont(for: .body, weight: .semibold)))
                            .font(Font(UIFont.preferredFont(forTextStyle: .body)))
                        Spacer()
                    }
                }
                .foregroundColor(.white)
                .background(Color(Colors.tcatBlue))
                .clipShape(Capsule())
            }
            .listRowSeparator(.hidden)

            SwiftUI.Section {
                sectionHeader(title: "Frequently Asked Questions")
            }
        }
        .listStyle(.plain)
    }

    private func sectionHeader(title: String) -> some View {
        Text(title)
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
