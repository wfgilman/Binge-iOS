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
//    var category: String
//    var tags: String
    var match: Bool
    var restaurantId: Int
    var restaurantName: String
    var restaurantMatch: Bool
    var doordashUrl: String
    var uberEatsUrl: String?
    var websiteUrl: String?
    var phone: String?
    
    required init(from decoder: Decoder) throws {
        id = try decoder.decode("id")
        name = try decoder.decode("name")
        imageUrl = try decoder.decode("image_url")
//        category = try decoder.decode("category")
//        tags = try decoder.decode("tags")
        match = try decoder.decode("match")
        restaurantId = try decoder.decode("restaurant_id")
        restaurantName = try decoder.decode("restaurant_name")
        restaurantMatch = try decoder.decode("restaurant_match")
        doordashUrl = try decoder.decode("doordash_url")
        uberEatsUrl = try decoder.decode("ubereats_url")
        websiteUrl = try decoder.decode("website_url")
        phone = try decoder.decode("phone")
    }
}


