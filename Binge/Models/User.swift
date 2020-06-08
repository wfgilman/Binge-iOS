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
    var matchUser: User?
    
    required init(from decoder: Decoder) throws {
        id = try decoder.decode("id")
        firstName = try decoder.decode("first_name")
        lastName = try decoder.decode("last_name")
        phone = try decoder.decode("phone")
        email = try decoder.decode("email")
        matchUser = try decoder.decode("match_user")
    }
}
