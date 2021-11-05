//
//  Token.swift
//  Binge
//
//  Created by Will Gilman on 6/7/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation

struct Token: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
