/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Model class representing a single call
 */

import Foundation
import OpenTok
import Parse

final class SpeakerboxCall: NSObject {
    
    // MARK: Metadata Properties
    
    let uuid: UUID
    let userInfo: [AnyHashable:Any]?
    let isOutgoing: Bool
    var handle: String?
    var callSessionId: String?

    // MARK: Call State Properties
    
    var connectingDate: Date? {
        didSet {
            stateDidChange?()
            hasStartedConnectingDidChange?()
        }
    }
    var connectDate: Date? {
        didSet {
            stateDidChange?()
            hasConnectedDidChange?()
        }
    }
    var endDate: Date? {
        didSet {
            stateDidChange?()
            hasEndedDidChange?()
        }
    }
    var isOnHold = false {
        didSet {
            publisher?.publishAudio = !isOnHold
            stateDidChange?()
        }
    }
    
    var isMuted = false {
        didSet {
            publisher?.publishAudio = !isMuted
        }
    }
    
    // MARK: State change callback blocks
    
    var stateDidChange: (() -> Void)?
    var hasStartedConnectingDidChange: (() -> Void)?
    var hasConnectedDidChange: (() -> Void)?
    var hasEndedDidChange: (() -> Void)?
    var audioChange: (() -> Void)?
    var pullRequest:PFQuery<PFObject>? = PFQuery(className: "VideoCallSession")
    private var completionHandler:AVTokPullRequestHandler?
    typealias AVTokPullRequestHandler = (_ tokSessionId:String, _ token:String)->Void

    private var timer:Timer?
    
    // MARK: Derived Properties
    
    var hasStartedConnecting: Bool {
        get {
            return connectingDate != nil
        }
        set {
            connectingDate = newValue ? Date() : nil
        }
    }
    var hasConnected: Bool {
        get {
            return connectDate != nil
        }
        set {
            connectDate = newValue ? Date() : nil
        }
    }
    var hasEnded: Bool {
        get {
            return endDate != nil
        }
        set {
            endDate = newValue ? Date() : nil
        }
    }
    var duration: TimeInterval {
        guard let connectDate = connectDate else {
            return 0
        }
        
        return Date().timeIntervalSince(connectDate)
    }
    
    // MARK: Initialization
    
    init(userInfo:[AnyHashable:Any]? = [:],uuid: UUID, isOutgoing: Bool = false) {
        self.uuid = uuid
        self.userInfo = userInfo
        self.isOutgoing = isOutgoing
    }
    
    // MARK: Actions
    var session: OTSession?
    var publisher: OTPublisher?
    var subscriber: OTSubscriber?

    func sessionInit(sessionId:String,token:String) {
        if session == nil {
            session = OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)
        }
        var error: OTError? = nil
        hasStartedConnecting = true
        session?.connect(withToken: token, error: &error)
        if let error = error {
            print("fhghghhg")
            print(error)
        }
    }
    func publisherInit() {
        if publisher == nil {
            let settings = OTPublisherSettings()
            settings.name = UIDevice.current.name
            settings.audioTrack = true
            settings.videoTrack = !((self.userInfo?["voiceOnly"] as? Bool) ?? false)
            publisher = OTPublisher(delegate: self, settings: settings)
            publisher?.viewScaleBehavior = OTVideoViewScaleBehavior.fit
        }
        var error: OTError? = nil
        session?.publish(publisher!, error: &error)
        if let error = error {
        } else {
        }
    }
    func subscriberInit(streamCreated stream: OTStream) {
        subscriber = OTSubscriber(stream: stream, delegate: self)
        subscriber?.viewScaleBehavior = OTVideoViewScaleBehavior.fit
        subscriber?.subscribeToVideo = !((self.userInfo?["voiceOnly"] as? Bool) ?? false)
        if let subscriber = subscriber {
            var error: OTError? = nil
            session?.subscribe(subscriber, error: &error)
            if error != nil {
            } else {
            }
        }
    }
    var canStartCall: ((Bool) -> Void)?
    func startCall(withAudioSession audioSession: AVAudioSession, completion: ((_ success: Bool) -> Void)?) {
        print(deviceToken)
        print("deviceTokendeviceToken")
        OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance(with: audioSession))
        self.initiateCall()
        canStartCall = completion
    }
    
    func initiateCall() {
        print("initiateCallinitiateCall")
        PFCloud.callFunction(
            inBackground: "getProfessionalStats",
            withParameters: [
                "abilities": "RequestType12",
                "appLanguage": "ar"
            ]) { result, error in
                print("resultresult")
                print(error)
                let resultss = result as? Array<[String:Any]>
                
                if let foo = resultss?.first(where: {$0["ProfessionalId"] as? String == "faxx5bca1F"}) {
                    print("foooofff")
                    let object = PFObject(className: "VideoCallSession")
                    object["professional_obj"] = foo["Professional"]
                    object["installationId"] = "r5Ger2kTX"
                    object["platform"] = "IOS"
                    object["connectionType"] = "WiFi"
                    object["carrierName"] = ""
                    object["voiceOnly"] = true
                    object.saveInBackground { succeeded, error in
                        print(succeeded)
                        print(error)
                        print(object)
                        print("succeededsucceeded")
                        self.callSessionId = object.objectId
                        self.start(for: object.objectId, complete: { [weak self] (tokSessionId, token) in
                            print(tokSessionId)
                            print(token)
                            print("hghvgc")
                            guard let weakSelf = self else { return }
                            weakSelf.sessionInit(sessionId: tokSessionId, token: token)
                        })
                    }
                } else {
                    // item could not be found
                }
                
            }
    }
    @objc private func fetchCall()
    {
        print("gjghghghghhg")
        pullRequest?.cancel()
        pullRequest?.getFirstObjectInBackground(block: { [weak self] (object, error) in
            if error == nil
            {
                guard let object = object else { return }
                if let session = object["tokSessionId"] as? String, let token = object["tokenUser"] as? String, session.count > 0
                {
                    DispatchQueue.main.async {
                        self?.stop()
                        self?.completionHandler?(session,token)
                    }
                }
            }
        })
    }
    
    func start(for sessionId:String?, complete:@escaping AVTokPullRequestHandler)
    {
        guard let sessionId = sessionId else {
            complete("","")
            return
        }
        pullRequest?.whereKey("callStatus", equalTo: "ACTIVE")
        pullRequest?.whereKey("objectId", equalTo: sessionId)
        pullRequest?.whereKey("proConnected", equalTo: true)
        pullRequest?.whereKey("voiceOnly", equalTo: true)
        
        self.completionHandler = complete
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(fetchCall), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    func stop()
    {
        DispatchQueue.main.async { [weak self] in
            self?.pullRequest?.cancel()
            self?.timer?.invalidate()
        }
    }
    
    func joinCall(withVideoSessionId sessionId: String?, videoEnabled: Bool, completionHandler: @escaping (_ success: Bool) -> Void) {
        let profObject = PFUser.current()?["professional_obj"] as? PFObject
        if profObject?.isDataAvailable == false {
            do{
                try profObject?.fetch()
            }catch{
                
            }
        }
        
        let params = [
            "professional_obj": profObject?.objectId,
            "videoCallSessionId": sessionId
        ]
        
        PFCloud.callFunction(inBackground: "joinProToVideoCall", withParameters: params) { object, error in
            print("yettdvjchv,")
            print(object)
            if error != nil {
                completionHandler(false)
            } else if let dicObject = object as? [String:Any] {
                if dicObject["hasError"] as? Bool == true {
                    let errorCode = dicObject["errorCode"] as? Int ?? 0

                    let err = NSError(domain: "Could not get room number!", code: errorCode, userInfo: nil)
                    switch errorCode {
                    case 100:
                        break
                    case 101:
                        break
                    case 500:
                        break
                    default:
                        break
                    }
                    completionHandler(false)
                } else {
                    let voiceOnly = (self.userInfo?["voiceOnly"] as? Bool) ?? false
                    print(dicObject["token"])
                    print(dicObject["sessionId"])
                    print("testssssssss")
                    self.joinCallSession(withToken: dicObject["token"] as? String, openTokSessionId: dicObject["sessionId"] as? String, videoEnabled: videoEnabled)
                    completionHandler(true)
                }
            }else{
                completionHandler(false)
            }
        }
    }
    
    func joinCallSession(withToken token: String?, openTokSessionId sessionId: String?, videoEnabled: Bool) {
        sessionInit(sessionId: sessionId ?? "", token: token ?? "")
    }
    
    var canAnswerCall: ((Bool) -> Void)?
    func answerCall(withAudioSession audioSession: AVAudioSession, completion: ((_ success: Bool) -> Void)?) {
        OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance(with: audioSession))
        print("answerCallanswerCall")
        print(userInfo)
        let videoCallSessionId = userInfo?["videoCallSessionId"] as? String
        let tokSessionId = userInfo?["tokSessionId"] as? String
        
        let voiceOnly = (userInfo?["voiceOnly"] as? Bool) ?? false
        print(tokSessionId)
        print(voiceOnly)
        print(videoCallSessionId)
        
        self.joinCall(withVideoSessionId: videoCallSessionId, videoEnabled: voiceOnly) { success in
            print("nfnfnnfnf")
            print(success)
            self.canAnswerCall = completion
        }
    }
    
    func startAudio() {
        publisherInit()
    }
    
    func endCall() {
        print("mfffjjfjff")
        self.stop()
        cloudDisconnect {
            
            if let publisher = self.publisher {
                var error: OTError?
                self.session?.unpublish(publisher, error: &error)
                if error != nil {
                    print(error!)
                }
            }
            self.publisher = nil
            
            if let session = self.session {
                var error: OTError?
                session.disconnect(&error)
                if error != nil {
                    print(error!)
                }
            }
            self.session = nil
        }
    }
    
    private func cloudDisconnect(finished:@escaping()->Void)
    {
        var method:String
        if hasConnected {
            method = UserDefaults.standard.bool(forKey: "isProfessional") ? "endProActiveVideoCall" : "endUserActiveVideoCall"
        }
        else
        {
            method = UserDefaults.standard.bool(forKey: "isProfessional") ? "rejectProVideoCall" : "cancelUserVideoCall"
        }
        print("fhhfhfhfhfhf")
        print("vhcgfgchjhkfgfggcg")
        print(callSessionId)
        let params = ["professional_obj":"faxx5bca1F", "videoCallSessionId":callSessionId]
        PFCloud.callFunction(inBackground: method, withParameters: params) { (result, error) in
            print(error)
            print("errorrrr")
            print(result)
            finished()
        }
    }
}

extension SpeakerboxCall: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print(#function)
        
        hasConnected = true
        canStartCall?(true)
        canAnswerCall?(true)
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print(#function)
    }
    
    func sessionDidBeginReconnecting(_ session: OTSession) {
        print(#function)
    }
    
    func sessionDidReconnect(_ session: OTSession) {
        print(#function)
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print(#function, error)
        print("didFailWithError")
        hasConnected = false
        canStartCall?(false)
        canAnswerCall?(false)
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print(#function)
        subscriberInit(streamCreated: stream)
    }
    
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print(#function)
    }
}

extension SpeakerboxCall: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print(#function)
    }
}

extension SpeakerboxCall: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        print(#function)
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print(#function)
    }
}
