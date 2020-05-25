//
//  Error.swift
//  Binge
//
//  Created by Will Gilman on 5/24/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation
import Codextended

struct ApiError: Codable {
    var code: String
    var message: String
}
