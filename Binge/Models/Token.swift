//
//  Token.swift
//  Binge
//
//  Created by Will Gilman on 6/7/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation
import Codextended

struct Token: Codable {
    var accessToken: String
    
    init(from decoder: Decoder) throws {
        accessToken = try decoder.decode("access_token")
    }
}
