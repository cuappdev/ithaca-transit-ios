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
        print("entered handler")
        if #available(iOS 12.1, *) {
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

@available(iOS 12.1, *)
class GetRoutesIntentHandler: INExtension, GetRoutesIntentHandling {
    func handle(intent: GetRoutesIntent, completion: @escaping (GetRoutesIntentResponse) -> Void) {
        print("entered intent handler")
        if let latitude = intent.latitude, let longitude = intent.longitude, let searchTo = intent.searchTo {
            print(intent.searchTo!)
            if let stopName = searchTo.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                let urlString = "ithaca-transit://getRoutes?lat=" + latitude + "&long=" + longitude + "&stopName=" + stopName
                let userActivity = NSUserActivity(activityType: "getRoutes")
                
                userActivity.userInfo = ["url" : urlString, "intent" : intent]
                print(userActivity.activityType)
                
                let response = GetRoutesIntentResponse(code: .success, userActivity: userActivity)
                completion(response)
            }
        }
        else {
            completion(GetRoutesIntentResponse(code: .failure, userActivity: nil))
        }
    }

}
