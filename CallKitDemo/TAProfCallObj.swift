//
//  TAProfCallObj.swift
//  CallKitDemo
//
//  Created by Admin on 25/12/2022.
//  Copyright © 2022 Tokbox, Inc. All rights reserved.
//

import Foundation

class TAProfCallObj: NSObject {
    var available = false
    var inVideoCall = false
    var videoSessionIdInProgress: String?
    var callRate: NSNumber = 0
    var remainingMinutes = 0.0
//    var type: CallType?


    static func sharedInstance() -> TAProfCallObj? {
        var sharedInstanceUtility: TAProfCallObj? = nil
        if sharedInstanceUtility == nil {
            sharedInstanceUtility = TAProfCallObj()
            sharedInstanceUtility?.videoSessionIdInProgress = nil
        }
        return sharedInstanceUtility
    }
    
    func calculateRemainingMinutes(withUserBalance amount: Double) {
        remainingMinutes = amount / callRate.doubleValue
    }

    func setCallHandled(_ videoSessionId: String?) {
        UserDefaults.standard.set(videoSessionId, forKey: "VideoSessionId")
    }

    func isCallHandled(_ videoSessionId: String?) -> Bool {
        if videoSessionId == nil {
            return false
        }

        let handledSessionId = UserDefaults.standard.object(forKey: "VideoSessionId") as? String

        if videoSessionId == handledSessionId {
            return true
        } else {
            return false
        }
    }

    class func joinCall(withVideoSessionId sessionId: String?, videoEnabled: Bool, completionHandler: @escaping (_ success: Bool) -> Void) {
    }

    class func joinCallSession(withToken token: String?, openTokSessionId sessionId: String?, videoEnabled: Bool) {
    }
}
