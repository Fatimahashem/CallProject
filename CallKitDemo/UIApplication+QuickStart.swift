//
//  UIApplication+QuickStart.swift
//  CallKitDemo
//
//  Created by Admin on 29/11/2022.
//  Copyright © 2022 Tokbox, Inc. All rights reserved.
//

import UIKit

extension UIApplication {
    func dismissCallController() {
        DispatchQueue.main.async { [weak self] in
            if let topViewController = UIViewController.topViewController {
                topViewController.dismiss(animated: true)
            }
        }
    }
    func showCallController() {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            // If there is termination: Failed to load VoiceCallViewController from Main.storyboard. Please check its storyboard ID")
//            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//            let viewController = storyboard.instantiateViewController(withIdentifier: "VoiceCallViewController")
//            
//            if var dataSource = viewController as? DirectCallDataSource {
//                dataSource.isDialing = false
//            }
//            
//            if let topViewController = UIViewController.topViewController {
//                topViewController.present(viewController, animated: true, completion: nil)
//            } else {
//                self.keyWindow?.rootViewController = viewController
//                self.keyWindow?.makeKeyAndVisible()
//            }
//        }
    }
    func showError(with errorDescription: String?) {
        let message = errorDescription ?? "Something went wrong. Please retry."
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let topViewController = UIViewController.topViewController {
                topViewController.presentErrorAlert(message: message)
            } else {
                self.keyWindow?.rootViewController?.presentErrorAlert(message: message)
                self.keyWindow?.makeKeyAndVisible()
            }
        }
    }
}
