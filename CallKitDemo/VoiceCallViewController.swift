//
//  VoiceCallViewController.swift
//  CallKitDemo
//
//  Created by Admin on 29/11/2022.
//  Copyright © 2022 Tokbox, Inc. All rights reserved.
//

import UIKit
import AVKit
import CallKit
import MediaPlayer
import AVFAudio
import AVFoundation
import Parse
class VoiceCallViewController: UIViewController {
    
    var pullRequest:PFQuery<PFObject>? = PFQuery(className: "VideoCallSession")
    private var completionHandler:AVTokPullRequestHandler?
    private var timer:Timer?
    
    typealias AVTokPullRequestHandler = (_ tokSessionId:String, _ token:String)->Void
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            //            self.profileImageView.updateImage(urlString: profileURL)
            self.profileImageView.image = UIImage(named: "iconAvatar")
        }
    }
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            self.nameLabel.text = "Fatima"
        }
    }
    
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var muteAudioButton: UIButton! {
        didSet {
            self.muteAudioButton.isSelected = isMuted
        }
    }
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var callTimerLabel: UILabel!
    
    // Notify muted state
    @IBOutlet weak var mutedStateImageView: UIImageView!
    @IBOutlet weak var mutedStateLabel: UILabel! {
        didSet {
            //            guard let remoteUser = self.call.remoteUser else { return }
            //            let name = remoteUser.nickname?.isEmptyOrWhitespace == true ? remoteUser.userId : remoteUser.nickname!
            
            self.mutedStateLabel.text = "CallStatus.muted(user: name).message"
        }
    }
    let audioSession = AVAudioSession.sharedInstance()
    var call:SpeakerboxCall!
    var isMuted = false
    
    var isDialing: Bool?
    
    var callTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        self.setSpeakerStates(enabled: false)
        self.updateRemoteAudio(isEnabled: true)
        appdelegate.callManager.startCall(handle: "70789466")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        initiateCall()
    }
    
    // MARK: - IBActions
    @IBAction func didTapAudioOption(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.updateLocalAudio(isEnabled: sender.isSelected)
    }
    
    @IBAction func didTapSpeakerButton(_ sender: UIButton) {
        setSpeakerStates(enabled: !sender.isSelected)
    }
    
    @IBAction func didTapEnd() {
        self.endButton.isEnabled = false
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
        
        /*
         End any ongoing calls if the provider resets, and remove them from the app's list of calls,
         since they are no longer valid.
         */
        UIApplication.shared.dismissCallController()
        for call in appdelegate.callManager.calls {
            appdelegate.callManager.end(call: call)
        }
    }
    
    // MARK: - Basic UI
    func setupEndedCallUI() {
        self.callTimer?.invalidate()    // Main thread
        self.callTimer = nil
        self.callTimerLabel.text = "test"
        //        self.callTimerLabel.text = CallStatus.ended(result: call.endResult.rawValue).message
        
        self.endButton.isHidden = true
        self.speakerButton.isHidden = true
        self.muteAudioButton.isHidden = true
        
        self.mutedStateImageView.isHidden = true
        self.mutedStateLabel.isHidden = true
    }
}

// MARK: - Audio Features
extension VoiceCallViewController {
    func updateLocalAudio(isEnabled: Bool) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("appdelegate is missing")
            return
        }
        if let callDelegate = appdelegate.callManager.calls[0] as SpeakerboxCall?{
            appdelegate.callManager.setMute(call: callDelegate, muted: self.muteAudioButton.isSelected)
            callDelegate.audioChange = { [weak self] in
                self?.muteAudioButton.isSelected = callDelegate.isMuted
                
                self?.muteAudioButton.setBackgroundImage(.audio(isOn: callDelegate.isMuted), for: .normal)
            }
        }
    }
    
    func updateRemoteAudio(isEnabled: Bool) {
        self.mutedStateImageView.isHidden = isEnabled
        self.mutedStateLabel.isHidden = isEnabled
    }
}

// MARK: - Audio Output
extension VoiceCallViewController {
    func setSpeakerStates(enabled: Bool)
        {
            let session = AVAudioSession.sharedInstance()
            print(enabled)
            print("enabledenabled")
            self.speakerButton.isSelected = enabled
            var _: Error?
            try? session.setCategory(AVAudioSession.Category.playAndRecord)
            try? session.setMode(AVAudioSession.Mode.voiceChat)
            if enabled {
                try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                self.speakerButton.setBackgroundImage(.audio(output: .builtInSpeaker), for: .normal)
            } else {
                try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                self.speakerButton.setBackgroundImage(.audio(output: .airPlay), for: .normal)
            }
            try? session.setActive(true)
        }
}

// MARK: - DirectCall duration
extension VoiceCallViewController {
    func activeTimer() {
        self.callTimerLabel.text = "00:00"
        
        // Main thread
        self.callTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            // update UI
            self.callTimerLabel.text = "ffmfmf"
            //            self.callTimerLabel.text = self.call.duration.durationText()
            
            // Timer Invalidate
            //            if self.call.endedAt != 0, timer.isValid {
            //                timer.invalidate()
            //                self.callTimer = nil
            //            }
        }
    }
}
