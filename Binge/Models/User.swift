//
//  User.swift
//  Binge
//
//  Created by Will Gilman on 6/7/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation
import ZendeskCoreSDK
import SupportSDK

class User: Decodable {
    var id: Int
    var firstName: String
    var lastName: String?
    var phone: String
    var email: String?
    var status: String
    var friendId: Int?
    var pushEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case phone
        case email
        case status
        case friendId = "friend_id"
        case pushEnabled = "push_enabled"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        phone = try container.decode(String.self, forKey: .phone)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        status = try container.decode(String.self, forKey: .status)
        friendId = try container.decodeIfPresent(Int.self, forKey: .friendId)
        pushEnabled = try container.decode(Bool.self, forKey: .pushEnabled)
    }
    
    class func create(with token: Token) {
        AppVariable.accessToken = token.accessToken
        AppVariable.validUser = true
        print("Access Token: \(token.accessToken)")
        NotificationCenter.default.post(name: .createdUser, object: nil)
    }
    
    class func delete() {
        AppVariable.accessToken = nil
        AppVariable.validUser = false
        NotificationCenter.default.post(name: .deletedUser, object: nil)
    }
    
    class func identify(_ user: User) {
        let identity = Identity.createAnonymous(name: user.firstName, email: user.email)
        Zendesk.instance?.setIdentity(identity)
        Support.initialize(withZendesk: Zendesk.instance)
    }
}

struct Friends: Decodable {
    let count: Int
    let friends: [User]
    
    enum CodingKeys: String, CodingKey {
        case count
        case friends = "data"
    }
}
