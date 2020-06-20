//
//  Dish.swift
//  Binge
//
//  Created by Will Gilman on 5/22/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation
import Codextended

class Dish: Codable {
    var id: Int
    var name: String
    var imageUrl: String
    var match: Bool
    var restaurantId: Int
    var restaurantName: String
    var doordashUrl: String
    
    required init(from decoder: Decoder) throws {
        id = try decoder.decode("id")
        name = try decoder.decode("name")
        imageUrl = try decoder.decode("image_url")
        match = try decoder.decode("match")
        restaurantId = try decoder.decode("restaurant_id")
        restaurantName = try decoder.decode("restaurant_name")
        doordashUrl = try decoder.decode("doordash_url")
    }
}


