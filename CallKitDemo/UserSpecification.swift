//
//  UserSpecification.swift
//  CallKitDemo
//
//  Created by Admin on 25/12/2022.
//  Copyright © 2022 Tokbox, Inc. All rights reserved.
//

import Foundation

struct UserSpecification {
    
    var isProfessional:Bool?
    var phoneNumber:String?
    var username:String?
    var fullname:String?
    var email:String?
    var professional_obj:String?
    init(isProfessional: Bool? = nil, phoneNumber: String? = nil, username: String? = nil, fullname: String? = nil, email: String? = nil, professional_obj: String? = nil) {
        self.isProfessional = isProfessional
        self.phoneNumber = phoneNumber
        self.username = username
        self.fullname = fullname
        self.email = email
        self.professional_obj = professional_obj
    }
}
