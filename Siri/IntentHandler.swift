//
//  IntentHandler.swift
//  Siri
//
//  Created by Yana Sang on 10/17/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import Intents

class IntentHandler: INExtension {

    override func handler(for intent: INIntent) -> Any {
        if #available(iOS 12.0, *) {
            switch intent {
            case is GetRoutesIntent:
                return GetRoutesIntentHandler()
            default:
                return self
            }
        } else {
            return self
        }
    }
}

@available(iOS 12.0, *)
class GetRoutesIntentHandler: INExtension, GetRoutesIntentHandling {
    func handle(intent: GetRoutesIntent, completion: @escaping (GetRoutesIntentResponse) -> Void) {
        if (intent.latitude != nil && intent.longitude != nil && intent.searchTo != nil) {
            let response = GetRoutesIntentResponse(code: .success, userActivity: nil)
            completion(response)
        }
        else {
            completion(GetRoutesIntentResponse(code: .failure, userActivity: nil))
        }
        
    }
}
