//
//  AppDelegate.swift
//  CallKitDemo
//
//  Created by Xi Huang on 6/5/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

import UIKit
import PushKit
import CallKit
import OpenTok
import Parse
import UserNotifications

// Replace with your OpenTok API key
var apiKey = "47047344"
// Replace with your generated session ID
var sessionId = ""
// Replace with your generated token
var deviceToken = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var present = false
    let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    let callManager = SpeakerboxCallManager()
    var providerDelegate: ProviderDelegate?
    
    // Trigger VoIP registration on launch
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = "LIVE5DSy1QKi4807360c163e4553b0ea2a5035d71dee"
            $0.clientKey = "LIVEAGSp3ytHEtLGwWnrfOctQS6rfedFHK2Vwz2mWo9c"
            $0.server = "https://apilive.hayateh.com:468/parse/"
        }
        Parse.initialize(with: parseConfig)
        providerDelegate = ProviderDelegate(callManager: callManager)
        
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
        
        //        UIUserNotificationSettings(types: [.badge, .sound,.alert], categories: nil)
        
        return true
    }
}
// MARK: UNUserNotificationCenterDelegate inheritance and functionality
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Notification has been tapped: \(userInfo)")
        print("Notification has been tapped: \(userInfo["collection"])")
        if let type = userInfo["userName"] as? String{
            OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance())
//            self.displayIncomingCall(uuid: UUID(), handle: type, hasVideo: true) { _ in
//                let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
//                UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
//                self.present = false
//            }
        }

        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Notification willPresent: \(userInfo)")

        if let type = userInfo["userName"] as? String{
            self.displayIncomingCall(userInfo:userInfo,uuid: UUID(), handle: type, hasVideo: true) { _ in
                let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
                print("nffjjfjfjfjjfjfjf")
            }
        }
        completionHandler([.sound, .badge])
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let currentInstallation = PFInstallation.current()
        currentInstallation?["deviceIdentifier"] = UIDevice.current.identifierForVendor?.uuidString
        currentInstallation?["platformVersion"] = UIDevice.current.systemVersion
        currentInstallation?.setDeviceTokenFrom(deviceToken)
        currentInstallation?.saveInBackground()
    }
    func displayIncomingCall(userInfo:[AnyHashable:Any],uuid: UUID, handle: String, hasVideo: Bool = true, completion: ((NSError?) -> Void)? = nil) {
        
        providerDelegate?.reportIncomingCall(userInfo:userInfo,uuid: uuid, handle: handle, hasVideo: hasVideo, presentCall: !present, completion: completion)
        self.present = true
    }
}

extension AppDelegate: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print("\(#function) voip token: \(credentials.token)")

        let deviceToken = credentials.token.reduce("", {$0 + String(format: "%02X", $1) })
        print("\(#function) token is: \(deviceToken)")

    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {

        print("\(#function) incoming voip notfication: \(payload.dictionaryPayload)")
        if let uuidString = payload.dictionaryPayload["UUID"] as? String,
           let handle = payload.dictionaryPayload["handle"] as? String,
           let uuid = UUID(uuidString: uuidString) {

            OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance())

            // display incoming call UI when receiving incoming voip notification
            let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
//            self.displayIncomingCall(userInfo: <#[AnyHashable : Any]#>, uuid: uuid, handle: handle, hasVideo: true) { _ in
//                print("displayIncomingCall")
//                UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
//            }
        }
    }
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
            NSLog("Got new callback incoming notification")
            self.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type)
        if let uuidString = payload.dictionaryPayload["UUID"] as? String,
        let handle = payload.dictionaryPayload["handle"] as? String,
            let uuid = UUID(uuidString: uuidString) {
                
                OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance())
                
                // display incoming call UI when receiving incoming voip notification
                let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                self.displayIncomingCall(userInfo: [:], uuid: uuid, handle: handle, hasVideo: true) { _ in
                                print("displayIncomingCall")
                                UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
                            }
            }
            DispatchQueue.main.async {
              completion()
            }
        }
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("\(#function) token invalidated")
    }
}
