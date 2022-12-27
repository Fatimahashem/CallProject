//
//  ViewController.swift
//  CallKitDemo
//
//  Created by Xi Huang on 6/5/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    fileprivate final let displayCaller = "70789466"
    fileprivate final let makeACallText = "Make a call"
    fileprivate final let unholdCallText = "Unhold Call"
    fileprivate final let simulateIncomingCallText = "Simulate Call"
    fileprivate final let simulateIncomingCallThreeSecondsText = "Simulate Call after 3s(Background)"
    fileprivate final let endCallText = "End call"
    var pullRequest:PFQuery<PFObject>? = PFQuery(className: "VideoCallSession")
    private var completionHandler:AVTokPullRequestHandler?
    private var timer:Timer?
    
    typealias AVTokPullRequestHandler = (_ tokSessionId:String, _ token:String)->Void
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerLocal()
        fetchBalanceUser { result in
            print(result)
            print("resultresultresult")
        }
    }
    @objc func registerLocal() {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
        print("teststsss")
        let center = UNUserNotificationCenter.current()
        center.delegate = appdelegate
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCallsChangedNotification(notification:)), name: SpeakerboxCallManager.CallsChangedNotification, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var simulateCallButton: UIButton!
    @IBOutlet weak var simulateCallButton2: UIButton!
    
    @IBAction func receiveCallLucas(_ sender: UIButton) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
        
//        if simulateCallButton.titleLabel?.text == simulateIncomingCallText {
//            appdelegate.displayIncomingCall(uuid: UUID(), handle: displayCaller)
//            sender.setTitle(endCallText, for: .normal)
//            sender.setTitleColor(.red, for: .normal)
//            callButton.isEnabled = false
//            simulateCallButton2.isEnabled = false
//        }
//        else {
//            endCall()
//            sender.setTitle(simulateIncomingCallText, for: .normal)
//            sender.setTitleColor(.white, for: .normal)
//            callButton.isEnabled = true
//            simulateCallButton2.isEnabled = true
//        }
    }
    func fetchBalanceUser(result:@escaping(Result<Double,Error>)->Void)
    {
        PFUser.logInWithUsername(inBackground:"ali_zahr@hotmail.com", password:"123") {
            (user: PFUser?, error: Error?) -> Void in
            if user != nil {
                let query = PFQuery(className: "Balance")
                query.whereKey("user_obj", equalTo: PFUser.current())
                query.getFirstObjectInBackground { object, error in
                    print(object)
                    print("oobjecttttt")
                    guard let userObject = object else {
                        let error = NSError(domain: "No user found while fetching balance", code: 404)
                        result(.failure(error as Error))
                        return
                    }
                    if let error = error
                    {
                        result(.failure(error))
                    }
                    else
                    {
                        let balance = userObject["amount"] as? Double ?? 0
                        result(.success(balance))
                    }
                    PFUser.current()?.fetchInBackground(block: { object, error in
                        print(object)
                        print("objectobject")
                    })
                }
                // Do stuff after successful login.
            } else {
                print("faill")
                // The login failed. Check error to see why.
            }
        }
    }
    
    func fetchBalanceProf(result:@escaping(Result<Double,Error>)->Void)
    {
        PFUser.logInWithUsername(inBackground:"christel.ghannoum@gmail.com", password:"123") {
            (user: PFUser?, error: Error?) -> Void in
            if user != nil {
                let query = PFQuery(className: "Balance")
                query.whereKey("user_obj", equalTo: PFUser.current())
                query.getFirstObjectInBackground { object, error in
                    print(object)
                    print("oobjecttttt")
                    guard let userObject = object else {
                        let error = NSError(domain: "No user found while fetching balance", code: 404)
                        result(.failure(error as Error))
                        return
                    }
                    if let error = error
                    {
                        result(.failure(error))
                    }
                    else
                    {
                        let balance = userObject["amount"] as? Double ?? 0
                        result(.success(balance))
                    }
                    PFUser.current()?.fetchInBackground(block: { object, error in
                        if object?["professional_obj"] != nil{
                            UserDefaults.standard.set(true, forKey: "isProfessional")
                        }
                        let currentInstallation = PFInstallation.current()
                        currentInstallation?["professional_obj"] = object?["professional_obj"]
                        currentInstallation?.channels = ["professional"]
                        currentInstallation?["appLanguage"] = "ar"
                        currentInstallation?["lang"] = "ar"
                        currentInstallation?.saveInBackground()
                    })
                }
                // Do stuff after successful login.
            } else {
                print("faill")
                // The login failed. Check error to see why.
            }
        }
    }
    
    @IBAction func receiveCallLucasAfterThreeSeconds(_ sender: UIButton) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
//
//        if sender.titleLabel?.text == simulateIncomingCallThreeSecondsText {
//
//            let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                appdelegate.displayIncomingCall(uuid: UUID(), handle: "Lucas Huang", hasVideo: true) { _ in
//                    UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
//                }
//            }
//            sender.setTitle(endCallText, for: .normal)
//            sender.setTitleColor(.red, for: .normal)
//            callButton.isEnabled = false
//            simulateCallButton.isEnabled = false
//        }
//        else {
//            endCall()
//            sender.setTitle(simulateIncomingCallThreeSecondsText, for: .normal)
//            sender.setTitleColor(.white, for: .normal)
//            callButton.isEnabled = true
//            simulateCallButton.isEnabled = true
//        }
    }
    
    @IBAction func callButtonPressed(_ sender: UIButton) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
        
        if sender.titleLabel?.text == makeACallText {
            sender.setTitle(endCallText, for: .normal)
            sender.setTitleColor(.red, for: .normal)
            simulateCallButton.isEnabled = false
            simulateCallButton2.isEnabled = false
//            UIApplication.shared.showCallController()
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
                
                print("appdelegate is missing")
                return
            }
            if #available(iOS 13.0, *) {
                self.isModalInPresentation = true
            }
//            self.setSpeakerStates(enabled: false)
//            self.updateRemoteAudio(isEnabled: true)
            appdelegate.callManager.startCall(handle: "70789466")
        } else if sender.titleLabel?.text == unholdCallText { // This state set when user receives another call
            appdelegate.callManager.setHeld(call: appdelegate.callManager.calls[0], onHold: false)
        }
        else {
            endCall()
            sender.setTitle(makeACallText, for: .normal)
            sender.setTitleColor(.white, for: .normal)
            simulateCallButton.isEnabled = true
            simulateCallButton2.isEnabled = true
        }
    }
    
    @objc func handleCallsChangedNotification(notification: NSNotification) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
        
        if (appdelegate.callManager.calls.count > 0)
        {
            let call = appdelegate.callManager.calls[0]
            if call.isOnHold {
                callButton.setTitle(unholdCallText, for: .normal)
            } else if call.session != nil {
                print("jfjfjfjfjfjjfjfjjff")
                callButton.setTitle(endCallText, for: .normal)
                callButton.setTitleColor(.red, for: .normal)
            }
    
            if let action = notification.userInfo?["action"] as? String {
                if action == SpeakerboxCallManager.Call.end.rawValue{
                    appdelegate.present = false
                    callButton.setTitle(makeACallText, for: .normal)
                    callButton.setTitleColor(.white, for: .normal)
                    callButton.isEnabled = true
                    simulateCallButton.setTitle(simulateIncomingCallText, for: .normal)
                    simulateCallButton.setTitleColor(.white, for: .normal)
                    simulateCallButton.isEnabled = true
                    simulateCallButton2.setTitle(simulateIncomingCallThreeSecondsText, for: .normal)
                    simulateCallButton2.setTitleColor(.white, for: .normal)
                    simulateCallButton2.isEnabled = true
                }else if action == SpeakerboxCallManager.Call.start.rawValue{
                    print("startttssss")
                }
                
                print("fhfhfhhfhfhffff")
            }
        }
    }
    
    fileprivate func endCall() {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
        
        /*
         End any ongoing calls if the provider resets, and remove them from the app's list of calls,
         since they are no longer valid.
         */
        for call in appdelegate.callManager.calls {
            appdelegate.callManager.end(call: call)
        }
    }
}
