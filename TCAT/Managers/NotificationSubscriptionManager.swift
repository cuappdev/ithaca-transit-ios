//
//  NotificationManager.swift
//  TCAT
//
//  Created by Jayson Hahn on 11/3/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import Combine

// Helper class to manage notifications
class NotificationSubscriptionManager {
    
    static let shared = NotificationSubscriptionManager()

    private var cancellables = Set<AnyCancellable>()

    func subscribeToDelayNotifications(stopID: String?, tripID: String) {
        NotificationTokenHandler.shared.getDeviceToken { [weak self] token in
            guard let token = token,
                  let uid = userDefaults.string(forKey: Constants.UserDefaults.uid) else { return }

            TransitService.shared.subscribeToDelayNotifications(
                deviceToken: token,
                stopID: stopID,
                tripID: tripID,
                uid: uid
            )
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to subscribe to departure notification: \(error)")
                    }
                },
                receiveValue: { success in
                    print("Departure notification subscription success: \(success)")
                }
            )
            .store(in: &self!.cancellables)
        }
    }

    func subscribeToDepartureNotifications(startTime: String) {
        NotificationTokenHandler.shared.getDeviceToken { [weak self] token in
            guard let token = token,
                  let uid = userDefaults.string(forKey: Constants.UserDefaults.uid) else { return }

            TransitService.shared.subscribeToDepartureNotifications(
                deviceToken: token,
                startTime: startTime,
                uid: uid
            )
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to subscribe to delay notification: \(error)")
                    }
                },
                receiveValue: { success in
                    print("Delay notification subscription success: \(success)")
                }
            )
            .store(in: &self!.cancellables)
        }
    }

    func unsubscribeFromDelayNotifications(stopID: String?, tripID: String) {
        NotificationTokenHandler.shared.getDeviceToken { [weak self] token in
            guard let token = token,
                  let uid = userDefaults.string(forKey: Constants.UserDefaults.uid) else { return }

            TransitService.shared.unsubscribeFromDelayNotifications(
                deviceToken: token,
                stopID: stopID,
                tripID: tripID,
                uid: uid
            )
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to unsubscribe from Delay notification: \(error)")
                    }
                },
                receiveValue: { success in
                    print("Delay notification has been unsubscribed: \(success)")
                }
            )
            .store(in: &self!.cancellables)
        }
    }

    func unsubscribeFromDepartureNotifications(startTime: String) {
        NotificationTokenHandler.shared.getDeviceToken { [weak self] token in
            guard let token = token,
                  let uid = userDefaults.string(forKey: Constants.UserDefaults.uid) else { return }

            TransitService.shared.unsubscribeFromDepartureNotifications(
                deviceToken: token,
                startTime: startTime,
                uid: uid
            )
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to unsubscribe to departure notification: \(error)")
                    }
                },
                receiveValue: { success in
                    print("Departure notification has been unsubscribed: \(success)")
                }
            )
            .store(in: &self!.cancellables)
        }
    }
}
