/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 CallKit provider delegate class, which conforms to CXProviderDelegate protocol
 */

import Foundation
import UIKit
import CallKit
import AVFoundation
import OpenTok
import Parse

final class ProviderDelegate: NSObject, CXProviderDelegate {
    
    let callManager: SpeakerboxCallManager
    private let provider: CXProvider
    var userInfo: [AnyHashable:Any]?
    var professionalId:String = ""
    init(callManager: SpeakerboxCallManager) {
        self.callManager = callManager
        provider = CXProvider(configuration: type(of: self).providerConfiguration)
        
        super.init()
        
        provider.setDelegate(self, queue: nil)
    }
    
    /// The app's provider configuration, representing its CallKit capabilities
    static var providerConfiguration: CXProviderConfiguration {
        let localizedName = NSLocalizedString("CallKitDemo", comment: "Name of application")
        let providerConfiguration = CXProviderConfiguration(localizedName: localizedName)
        
        providerConfiguration.supportsVideo = false
        
        providerConfiguration.maximumCallsPerCallGroup = 1
        
        providerConfiguration.supportedHandleTypes = [.phoneNumber]
        
        providerConfiguration.ringtoneSound = "default-ringtone.caf"
        
        return providerConfiguration
    }
    
    // MARK: Incoming Calls
    
    /// Use CXProvider to report the incoming call to the system
    func reportIncomingCall(userInfo:[AnyHashable:Any]?,uuid: UUID, handle: String, hasVideo: Bool = true,presentCall:Bool, completion: ((NSError?) -> Void)? = nil) {
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        
        // pre-heat the AVAudioSession
        //OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance())
        
        // Report the incoming call to the system
        self.userInfo = userInfo
        print("vjnjvnjnvjrnjrjnj")
        self.handlePushNotification(userInfo: userInfo) { object in
            print("testststsssssss")
            print(presentCall)
            if presentCall{
                let update = CXCallUpdate()
                update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
                update.hasVideo = hasVideo
                self.provider.reportNewIncomingCall(with: uuid, update: update) { error in
                    /*
                     Only add incoming call to the app's list of calls if the call was allowed (i.e. there was no error)
                     since calls may be "denied" for various legitimate reasons. See CXErrorCodeIncomingCallError.
                     */
                    print(userInfo)
                    print("userInfoofffff")
                    if error == nil {
                        let call = SpeakerboxCall(userInfo:userInfo,uuid: uuid)
                        call.handle = handle
                        
                        self.callManager.addCall(call)
                    }
                    
                    completion?(error as NSError?)
                }
            }
        }
    }
    func handlePushNotification(userInfo:[AnyHashable:Any]?, completion: ((PFObject?) -> Void)?) {
        let videoCallRelatedPush = userInfo?["videoCallRelated"] as? Bool
        let configRelatedPush = userInfo?["configChange"] as? Bool
        print("nkjnvkrnnkvjrnknkn")
        print(userInfo?["callCancelled"] as? Bool)
        print(userInfo?["callCancelled"] as? Int)
        if configRelatedPush ?? false {
            let MMPC = userInfo?["MMPC"]
            let FMPC = userInfo?["FMPC"]
            let HASH = userInfo?["HASH"]
            
            //            TAHash.compare(withMMPC: MMPC, fmpc: FMPC, hash: HASH)
        }
        else if videoCallRelatedPush ?? false {
            let originalCallTime = userInfo?["originalCallTime"] as? String
            let videoCallSessionId = userInfo?["videoCallSessionId"] as? String
            let clientId = userInfo?["userId"] as? String
            let token = userInfo?["token"] as? String
            let tokSessionId = userInfo?["tokSessionId"] as? String
            
            let callRejected = (userInfo?["callRejected"] as? Bool) ?? false
            let callCancelled = (userInfo?["callCancelled"] as? Bool) ?? false
            let callTimedOut = (userInfo?["callTimedOut"] as? Bool) ?? false
            let callStarted = (userInfo?["callStarted"] as? Bool) ?? false
            let voiceOnly = (userInfo?["voiceOnly"] as? Bool) ?? false
            
            let center = UNUserNotificationCenter.current()
            center.getDeliveredNotifications(completionHandler: { notifications in
                if callRejected || callCancelled || callTimedOut || callStarted {
                    center.removeAllDeliveredNotifications()
                }
                if notifications.count > 1 {
                    center.removeDeliveredNotifications(withIdentifiers: [notifications.last?.request.identifier].compactMap { $0 })
                }
            })
            
            print(UserDefaults.standard.string(forKey: "videoCallSessionId"))
            print("tetststststsss")
            print(videoCallSessionId)
            if(callRejected)
            {
                for call in callManager.calls {
                    callManager.end(call: call)
                }
            }
            else if(callTimedOut)
            {
                for call in callManager.calls {
                    callManager.end(call: call)
                }
            }
            else if(callCancelled && UserDefaults.standard.string(forKey: "videoCallSessionId") == videoCallSessionId)
            {
                for call in callManager.calls {
                    callManager.end(call: call)
                }
            }
            else if (callStarted)
            {
            }
            else
            {
                if originalCallTime?.count ?? 0 > 0 {
                
                }
                if UserDefaults.standard.bool(forKey: "isProfessional") {
                    if TAProfCallObj.sharedInstance()?.videoSessionIdInProgress?.count ?? 0 > 0 {
                        
                    }else{
                        print("videoCallSessionId")
                        print(videoCallSessionId)
                        UserDefaults.standard.set(videoCallSessionId, forKey: "videoCallSessionId")
                    let query = PFQuery(className: "VideoCallSession")
                    query.whereKey("objectId", equalTo: videoCallSessionId)
                    query.getFirstObjectInBackground() { object, error in
                        if error == nil {
                            if object?["callStatus"] as? String == "PENDING" {
                                self.grantAVPermissions({ audioGranted, videoGranted in
                                    if(audioGranted && videoGranted)
                                    {
                                        guard let object = PFUser.current()?.object(forKey: "professional_obj") as? PFObject else { return }
                                        if object.isDataAvailable == false
                                        {
                                            do
                                            {
                                                try object.fetch()
                                            }
                                            catch {}
                                        }
                                        completion?(object)
                                    }else{
                                        // show message issues
                                    }
                                })
                            }
                        }else{
                            UserDefaults.standard.set(false, forKey: "isProfessional")
                        }
                    }
                }
                }else{
                    if !UserDefaults.standard.bool(forKey: "isProfessional") {
                        
                    }
                }
            }
        }
    }
    
    func grantAVPermissions(_ completionHandler: @escaping (_ audioGranted: Bool, _ videoGranted: Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { video in
            AVCaptureDevice.requestAccess(for: .audio) { audio in
                DispatchQueue.main.async(execute: {
                    completionHandler(audio, video)
                })
            }
        }
    }
    
    // MARK: CXProviderDelegate
    
    func providerDidReset(_ provider: CXProvider) {
        print("Provider did reset")
        /*
         End any ongoing calls if the provider resets, and remove them from the app's list of calls,
         since they are no longer valid.
         */
    }
    
    var outgoingCall: SpeakerboxCall?
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("CXStartCallActionCXStartCallAction")
        // Create & configure an instance of SpeakerboxCall, the app's model class representing the new outgoing call.
        let call = SpeakerboxCall(userInfo:userInfo,uuid: action.callUUID, isOutgoing: true)
        call.handle = action.handle.value
        
        /*
         Configure the audio session, but do not start call audio here, since it must be done once
         the audio session has been activated by the system after having its priority elevated.
         */
        // https://forums.developer.apple.com/thread/64544
        // we can't configure the audio session here for the case of launching it from locked screen
        // instead, we have to pre-heat the AVAudioSession by configuring as early as possible, didActivate do not get called otherwise
        // please look for  * pre-heat the AVAudioSession *
        configureAudioSession()
        
        /*
         Set callback blocks for significant events in the call's lifecycle, so that the CXProvider may be updated
         to reflect the updated state.
         */
        call.hasStartedConnectingDidChange = { [weak self] in
            self?.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: call.connectingDate)
        }
        call.hasConnectedDidChange = { [weak self] in
            self?.provider.reportOutgoingCall(with: call.uuid, connectedAt: call.connectDate)
        }
        
        self.outgoingCall = call
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }
    
    var answerCall: SpeakerboxCall?
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        print("CXAnswerCallActionCXAnswerCallAction")
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        /*
         Configure the audio session, but do not start call audio here, since it must be done once
         the audio session has been activated by the system after having its priority elevated.
         */
        
        // https://forums.developer.apple.com/thread/64544
        // we can't configure the audio session here for the case of launching it from locked screen
        // instead, we have to pre-heat the AVAudioSession by configuring as early as possible, didActivate do not get called otherwise
        // please look for  * pre-heat the AVAudioSession *
        //        configureAudioSession()
        
        self.answerCall = call
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }
    
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        // Trigger the call to be ended via the underlying network service.
        call.endCall()
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
        
        // Remove the ended call from the app's list of calls.
        callManager.removeCall(call)
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        // Update the SpeakerboxCall's underlying hold state.
        call.isOnHold = action.isOnHold
        
        // Stop or start audio in response to holding or unholding the call.
        call.isMuted = call.isOnHold
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        print("CXSetMutedCallAction")
        print(action.isMuted)
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.isMuted = action.isMuted
        call.audioChange?()
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print("Timed out \(#function)")
        
        // React to the action timeout if necessary, such as showing an error UI.
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("Received \(#function)")
        print("startCallBox provider")
        // If we are returning from a hold state
        if answerCall?.hasConnected ?? false {
            //configureAudioSession()
            // See more details on how this works in the OTDefaultAudioDevice.m method handleInterruptionEvent
            sendFakeAudioInterruptionNotificationToStartAudioResources();
            return
        }
        if outgoingCall?.hasConnected ?? false {
            //configureAudioSession()
            // See more details on how this works in the OTDefaultAudioDevice.m method handleInterruptionEvent
            sendFakeAudioInterruptionNotificationToStartAudioResources()
            return
        }
        // Start call audio media, now that the audio session has been activated after having its priority boosted.
        outgoingCall?.startCall(withAudioSession: audioSession,professionalId:professionalId) { [weak self] success in
            guard let outgoingCall = self?.outgoingCall else { return }
            print(success)
            if success {
                self?.callManager.addCall(outgoingCall)
                self?.outgoingCall?.startAudio()
            } else {
                self?.callManager.end(call: outgoingCall)
            }
        }
        
        answerCall?.answerCall(withAudioSession: audioSession) { success in
            if success {
                self.answerCall?.startAudio()
            }
        }
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("Received \(#function)")
        
        /*
         Restart any non-call related audio now that the app's audio session has been
         de-activated after having its priority restored to normal.
         */
        if outgoingCall?.isOnHold ?? false || answerCall?.isOnHold ?? false {
            print("Call is on hold. Do not terminate any call")
            return
        }
        
        outgoingCall?.endCall()
        outgoingCall = nil
        answerCall?.endCall()
        answerCall = nil
        callManager.removeAllCalls()
    }
    
    func sendFakeAudioInterruptionNotificationToStartAudioResources() {
        var userInfo = Dictionary<AnyHashable, Any>()
        let interrupttioEndedRaw = AVAudioSession.InterruptionType.ended.rawValue
        userInfo[AVAudioSessionInterruptionTypeKey] = interrupttioEndedRaw
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: self, userInfo: userInfo)
    }
    
    func configureAudioSession() {
        // See https://forums.developer.apple.com/thread/64544
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default)
            try session.setActive(true)
            try session.setMode(AVAudioSession.Mode.voiceChat)
            try session.setPreferredSampleRate(44100.0)
            try session.setPreferredIOBufferDuration(0.005)
        } catch {
            print(error)
        }
    }
}
