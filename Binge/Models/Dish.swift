//
//  Dish.swift
//  Binge
//
//  Created by Will Gilman on 5/22/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation
import Codextended

struct Dish: Codable {
    var id: Int
    var name: String
    var imageUrl: String
    var restaurantId: Int
    var restaurantName: String
    var doordashUrl: String
    
    init(from decoder: Decoder) throws {
        id = try decoder.decode("id")
        name = try decoder.decode("name")
        imageUrl = try decoder.decode("image_url")
        restaurantId = try decoder.decode("restaurant_id")
        restaurantName = try decoder.decode("restaurant_name")
        doordashUrl = try decoder.decode("doordash_url")
    }
}


