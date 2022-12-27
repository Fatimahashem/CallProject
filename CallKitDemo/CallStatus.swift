//
//  CallStatus.swift
//  CallKitDemo
//
//  Created by Admin on 29/11/2022.
//  Copyright © 2022 Tokbox, Inc. All rights reserved.
//

enum CallStatus {
    case connecting
    case muted(user: String)
    case ended(result: String)
    
    var message: String {
        switch self {
            case .connecting:
                return "call connecting..."
            case .muted(let user):
                return "\(user) is muted"
            case .ended(let result):
                return result
                    .replacingOccurrences(of: "_", with: " ")
        }
    }
}
