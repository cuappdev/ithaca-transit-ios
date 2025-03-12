//
//  WaitTimes.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import Foundation

public struct WaitTimes: Codable, Hashable {

    // In case we ever add more in the future...
    public enum SamplingMethod: String, Codable {

        case nearestNeighbor

    }

    public let samples: [WaitTimeSample]

    public let samplingMethod: SamplingMethod

    public init(samples: [WaitTimeSample], samplingMethod: SamplingMethod) {
        self.samples = samples
        self.samplingMethod = samplingMethod
    }

    public func sample(at date: Date) -> WaitTimeSample? {
        switch samplingMethod {
        case .nearestNeighbor:
            let timestamp = date.timeIntervalSince1970
            return samples.min { lhs, rhs in
                abs(lhs.timestamp - timestamp) < abs(rhs.timestamp - timestamp)
            }
        }
    }

}

public struct WaitTimeSample: Codable, Hashable {

    public let timestamp: TimeInterval

    public let low: TimeInterval

    public let expected: TimeInterval

    public let high: TimeInterval

    public init(timestamp: TimeInterval, low: TimeInterval, expected: TimeInterval, high: TimeInterval) {
        self.timestamp = timestamp
        self.low = low
        self.expected = expected
        self.high = high
    }

}
