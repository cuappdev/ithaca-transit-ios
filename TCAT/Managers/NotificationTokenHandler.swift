//
//  NotificationTokenHandler.swift
//  TCAT
//
//  Created by Jayson Hahn on 11/3/24.
//  Copyright © 2024 Cornell AppDev. All rights reserved.
//

import FirebaseMessaging
import UserNotifications
import UIKit

class NotificationTokenHandler: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {

    static let shared = NotificationTokenHandler()

    override init() {
        super.init()
        setupNotifications()
    }

    /**
     Sets up notifications by configuring the necessary delegates and requesting authorization for notifications.
     */
    private func setupNotifications() {
        // Set the current UNUserNotificationCenter delegate to self
        UNUserNotificationCenter.current().delegate = self
        
        // Set the Messaging delegate to self
        Messaging.messaging().delegate = self
        
        // Request authorization for notifications with alert, badge, and sound options
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        // Register the application for remote notifications
        UIApplication.shared.registerForRemoteNotifications()
    }

    /// Retrieves the device's FCM (Firebase Cloud Messaging) registration token.
    ///
    /// - Parameter completion: A closure that is called with the FCM registration token as a `String?`.
    ///                          If there is an error fetching the token, the closure is called with `nil`.
    ///
    /// This function uses Firebase Messaging to asynchronously fetch the device's FCM registration token.
    /// If the token is successfully retrieved, it is passed to the completion handler. If an error occurs,
    /// the error is printed to the console and the completion handler is called with `nil`.
    func getDeviceToken(completion: @escaping (String?) -> Void) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
                completion(nil)
            } else if let token = token {
                print("FCM registration token: \(token)")
                completion(token)
            }
        }
    }

    // MARK: - MessagingDelegate

    /// Called when a new Firebase Cloud Messaging (FCM) registration token is received.
    /// - Parameters:
    ///   - messaging: The messaging instance that received the token.
    ///   - fcmToken: The new FCM registration token, or `nil` if the token could not be retrieved.
    /// 
    /// This method prints the new FCM registration token and posts a notification with the token
    /// using `NotificationCenter`. The notification name is "FCMToken" and the token is included
    /// in the `userInfo` dictionary with the key "token".
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Handles the presentation of a notification when the app is in the foreground.
    /// - Parameters:
    ///   - center: The notification center that received the notification.
    ///   - notification: The notification that is about to be presented.
    ///   - completionHandler: The block to execute with the presentation options for the notification.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification when app is in foreground
        completionHandler([[.banner, .sound]])
    }

    /**
     Handles the event when a user taps on a notification.

     - Parameters:
       - center: The notification center that received the notification.
       - response: The user's response to the notification.
       - completionHandler: The block to execute when you have finished processing the user's response.
     */
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap
        let userInfo = response.notification.request.content.userInfo
        print("Notification tapped with info: \(userInfo)")
        completionHandler()
    }

    // MARK: - UIApplicationDelegate

    /// Handles the registration of the device for remote notifications and retrieves the FCM registration token.
    /// 
    /// - Parameters:
    ///   - application: The singleton app object.
    ///   - deviceToken: A token that identifies the device to APNs.
    /// 
    /// This method is called when the app successfully registers with Apple Push Notification service (APNs). 
    /// It sets the APNs token for Firebase Cloud Messaging (FCM) and attempts to retrieve the FCM registration token.
    /// If an error occurs while fetching the FCM registration token, it prints the error. 
    /// Otherwise, it prints the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
    }

    /// Called when the app fails to register for remote notifications.
    /// - Parameters:
    ///   - application: The singleton app object.
    ///   - error: An error object that encapsulates information why registration did not succeed.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("application didFailToRegisterForRemoteNotificationsWithError: \(error)")
    }

    /**
     Handles the receipt of a remote notification.

     - Parameters:
        - application: The singleton app object.
        - userInfo: A dictionary that contains information related to the remote notification.
        - completionHandler: The block to execute when the download operation is complete. You must call this handler and pass in the appropriate `UIBackgroundFetchResult` value.

     This method is called when a remote notification is received. It logs the notification's userInfo and calls the completion handler with `.newData`.
     */
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (
            UIBackgroundFetchResult
        ) -> Void
    ) {
        print("APNs received with: \(userInfo)")
        completionHandler(.newData)
    }

}
