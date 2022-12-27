////
////  AVTokSound.swift
////  CallKitDemo
////
////  Created by Admin on 14/12/2022.
////  Copyright © 2022 Tokbox, Inc. All rights reserved.
////
//
//import Foundation
//
//class AVTokSound
//{
//    private var timers = [UInt:Timer]()
//    private var cleanUpAudio = false
//    private var session: TAVideoCallSession
//    init(session:TAVideoCallSession)
//    {
//        self.session = session
//    }
//    func play(ringtone:RingTone, after time:Int = 0, executed:(()->Void)? = nil)
//    {
//        guard let device = session.audioDevice else { return }
//        invalidateTimer()
//        DispatchQueue.main.async {
//            if time == 0
//            {
//                device.playAudio(ringtone)
//            }
//            else
//            {
//                let timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(time), repeats: false, block: { (timer) in
//                    DispatchQueue.main.async {
//                        device.playAudio(ringtone)
//                        executed?()
//                    }
//                })
//                self.timers[ringtone.rawValue] = timer
//            }
//        }
//    }
//    func play(ringtone:RingTone, for time:Double, executed:(()->Void)? = nil)
//    {
//        guard let device = session.audioDevice else { return }
//        invalidateTimer()
//        
//        DispatchQueue.main.async {
//            device.playAudio(ringtone)
//            let timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(time), repeats: false, block: { (timer) in
//                DispatchQueue.main.async {
//                    self.stop()
//                    executed?()
//                }
//            })
//            self.timers[ringtone.rawValue] = timer
//        }
//    }
//
//    private func invalidateTimer()
//    {
//        timers.forEach({$0.value.invalidate()})
//        timers.removeAll()
//    }
//    func stop()
//    {
//        invalidateTimer()
//        DispatchQueue.main.async {
//            guard let device = self.session.audioDevice else { return }
//            device.stopAudio()
//            if self.cleanUpAudio { self.session.reset() }
//        }
//    }
//    func stopRingtone()
//    {
//        timers.forEach({ if $0.key == kRingtone.rawValue { $0.value.invalidate() } })
//        
//        DispatchQueue.main.async {
//            self.stop()
//        }
//    }
//    
//    func cleanup()
//    {
//        cleanUpAudio = true
//        stop()
//    }
//}
