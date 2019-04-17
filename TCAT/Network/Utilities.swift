//
//  Network+Utilities.swift
//  TCAT
//
//  Created by Matt Barker on 2/3/19.
//  Copyright © 2019 cuappdev. All rights reserved.
//

import Foundation

func isTestFlight() -> Bool {
    let sandboxString = "sandboxReceipt"
    guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
        return false
    }
    return appStoreReceiptURL.lastPathComponent == sandboxString
}
