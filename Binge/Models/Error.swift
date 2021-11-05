//
//  Error.swift
//  Binge
//
//  Created by Will Gilman on 5/24/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation

struct ApiError: Decodable {
    let code: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case code, message
    }
}
