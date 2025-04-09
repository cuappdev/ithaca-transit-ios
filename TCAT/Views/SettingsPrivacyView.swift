//
//  SettingsPrivacyView.swift
//  TCAT
//
//  Created by Asen Ou on 3/16/25.
//  Copyright © 2025 Cornell AppDev. All rights reserved.
//

import SwiftUI

class SettingsPrivacyViewModel: ObservableObject {

    @Published var isLocationAllowed: Bool = false
    @Published var isAnalyticsEnabled: Bool = true
    @Published var isNotificationsAllowed: Bool = false

}

struct SettingsPrivacyView: View {

    @ObservedObject var viewModel = SettingsPrivacyViewModel()

    var body: some View {
        List {
            // Intro section
            Text("Manage permissions and analytics")
                .foregroundColor(.gray)
                .font(Font(UIFont.preferredFont(forTextStyle: .body)))
                .listRowSeparator(.hidden)

            // Custom header for Permissions
            Text("Permissions")
                .font(Font(UIFont.preferredFont(forTextStyle: .title2)))
                .foregroundColor(.black)
                .padding(.top, 12)
                .listRowSeparator(.hidden)

            // Permissions item
            // Location
            Button {
                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }

                UIApplication.shared.open(url, options: [:], completionHandler: nil)

            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer(minLength: 12)
                        Text("Location Access")
                            .font(Font(UIFont.preferredFont(forTextStyle: .body)))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Text("Used to find routes near you")
                            .font(Font(UIFont.preferredFont(forTextStyle: .caption1)))
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        Spacer(minLength: 12)
                    }
                    Spacer()
                    HStack(spacing: 2) {
                        Text(viewModel.isLocationAllowed ? "Allowed" : "Denied")
                            .font(Font(UIFont.preferredFont(forTextStyle: .footnote)))
                            .fontWeight(.semibold)
                        Image("externalLink")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 16, height: 16)
                    }
                    .foregroundColor(viewModel.isLocationAllowed ? Color(Colors.tcatBlue) : .gray)
                }
            }
            .listRowSeparator(.visible, edges: .bottom)

            // Notifications
            Button {
                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }

                UIApplication.shared.open(url, options: [:], completionHandler: nil)

            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer(minLength: 12)
                        Text("Notifications Access")
                            .font(Font(UIFont.preferredFont(forTextStyle: .body)))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Text("Used to send device notifications")
                            .font(Font(UIFont.preferredFont(forTextStyle: .caption1)))
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        Spacer(minLength: 12)
                    }
                    Spacer()
                    HStack(spacing: 2) {
                        Text(viewModel.isNotificationsAllowed ? "Allowed" : "Denied")
                            .font(Font(UIFont.preferredFont(forTextStyle: .footnote)))
                            .fontWeight(.semibold)
                        Image("externalLink")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 16, height: 16)
                    }
                    .foregroundColor(viewModel.isNotificationsAllowed ? Color(Colors.tcatBlue) : .gray)
                }
            }
            .listRowSeparator(.hidden)

            // Custom header for Analytics
            Text("Analytics")
                .font(Font(UIFont.preferredFont(forTextStyle: .title2)))
                .foregroundColor(.black)
                .padding(.top, 12)
                .listRowSeparator(.hidden)

            // Analytics toggle item
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Spacer(minLength: 0)
                    Text("Share with Cornell AppDev")
                        .font(Font(UIFont.preferredFont(forTextStyle: .body)))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text("Help us improve our products and services")
                        .font(Font(UIFont.preferredFont(forTextStyle: .caption1)))
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
                Toggle("Analytics Enabled", isOn: $viewModel.isAnalyticsEnabled)
                    .labelsHidden()
                    .tint(Color(Colors.tcatBlue))
            }

            // Privacy policy link
            Link(destination: URL(string: "https://www.cornellappdev.com/privacy")!) {
                HStack {
                    Text("Privacy Policy")
                        .font(Font(UIFont.preferredFont(forTextStyle: .body)))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Spacer()
                    Image("externalLink")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(Colors.tcatBlue))
                        .frame(width: 16, height: 16)
                }
            }
            .listRowSeparator(.hidden, edges: .bottom)
        }
        .listStyle(.plain)
    }
}
