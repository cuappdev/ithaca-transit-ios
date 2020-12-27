//
//  StoreReviewHelper.swift
//  TCAT
//
//  Created by Matthew Barker on 04/15/18
//  Copyright © 2018 cuappdev. All rights reserved.
//
//  https://gist.github.com/abhimuralidharan/fc717fb27d1d7388524e70a09860a786#file-storereviewhelper-swift
//

import UIKit
import StoreKit

class StoreReviewHelper {

    /// Shared instance of class
    static let shared = StoreReviewHelper()

    // MARK: - Variables

    private static let APP_OPENED_COUNT = Constants.UserDefaults.appLaunchCount

    /// The number of app launches to ask for a review

    private static let firstRequestLaunchCount: Int = 10
    private static let secondRequestLaunchCount: Int = 30
    private static let thirdRequestLaunchCount: Int = 60

    /// Ask for a review every x times after first three requests.
    private static let futureRequestInterval: Int = 100

    static func incrementAppOpenedCount() {
        guard var appOpenCount = userDefaults.value(forKey: APP_OPENED_COUNT) as? Int else {
            userDefaults.set(1, forKey: APP_OPENED_COUNT)
            return
        }
        appOpenCount += 1
        userDefaults.set(appOpenCount, forKey: APP_OPENED_COUNT)
    }

    /// Ask for review at appropriate times in app lifecycle (not guaranteed to fire, Apple-controlled logic)
    /// - override: Force a request of a review, overriding number of app launches
    static func checkAndAskForReview(override: Bool = false) {

        if override {
            StoreReviewHelper.shared.requestReview()
            return
        }

        guard let appOpenCount = userDefaults.value(forKey: APP_OPENED_COUNT) as? Int else {
            userDefaults.set(1, forKey: APP_OPENED_COUNT)
            return
        }

        // Open app certain times

        switch appOpenCount {
        case firstRequestLaunchCount, secondRequestLaunchCount, thirdRequestLaunchCount:
            StoreReviewHelper.shared.requestReview()
        case _ where appOpenCount % futureRequestInterval == 0 :
            StoreReviewHelper.shared.requestReview()
        default:
            break
        }

    }

    private func requestReview() {
        SKStoreReviewController.requestReview()
    }

}
