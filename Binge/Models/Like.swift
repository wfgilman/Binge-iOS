//
//  Like.swift
//  Binge
//
//  Created by Will Gilman on 7/11/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation
import Codextended

struct Like: Codable {
    var dishId: Int
    var restaurantId: Int
    
    init(from decoder: Decoder) throws {
        dishId = try decoder.decode("dish_id")
        restaurantId = try decoder.decode("restaurant_id")
    }
}
