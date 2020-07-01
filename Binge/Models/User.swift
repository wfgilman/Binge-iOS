//
//  User.swift
//  Binge
//
//  Created by Will Gilman on 6/7/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation
import Codextended

class User: Codable {
    var id: Int
    var firstName: String
    var lastName: String?
    var phone: String
    var email: String?
    var status: String
    var friendId: Int?
    var pushEnabled: Bool

    required init(from decoder: Decoder) throws {
        id = try decoder.decode("id")
        firstName = try decoder.decode("first_name")
        lastName = try decoder.decode("last_name")
        phone = try decoder.decode("phone")
        email = try decoder.decode("email")
        status = try decoder.decode("status")
        friendId = try decoder.decode("friend_id")
        pushEnabled = try decoder.decode("push_enabled")
    }
    
    class func create(with token: Token) {
        AppVariable.accessToken = token.accessToken
        print("Access Token: \(token.accessToken)")
        NotificationCenter.default.post(name: .createdUser, object: nil)
    }
    
    class func delete() {
        AppVariable.accessToken = nil
        AppVariable.deviceToken = nil
        NotificationCenter.default.post(name: .deletedUser, object: nil)
    }
    
    class func exists() -> Bool {
        if AppVariable.accessToken == nil {
            return false
        }
        return true
    }
}
