//
//  Dish.swift
//  Binge
//
//  Created by Will Gilman on 5/22/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation

class Dish: Decodable {
    var id: Int
    var name: String
    var imageUrl: String
    var match: Bool
    var restaurantId: Int
    var restaurantName: String
    var restaurantMatch: Bool
    var doordashUrl: String?
    var uberEatsUrl: String?
    var websiteUrl: String?
    var phone: String?
    var instagram: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageUrl = "image_url"
        case match
        case restaurantId = "restaurant_id"
        case restaurantName = "restaurant_name"
        case restaurantMatch = "restaurant_match"
        case doordashUrl = "doordash_url"
        case uberEatsUrl = "ubereats_url"
        case websiteUrl = "website_url"
        case phone
        case instagram
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        match = try container.decode(Bool.self, forKey: .match)
        restaurantId = try container.decode(Int.self, forKey: .restaurantId)
        restaurantName = try container.decode(String.self, forKey: .restaurantName)
        restaurantMatch = try container.decode(Bool.self, forKey: .restaurantMatch)
        doordashUrl = try container.decodeIfPresent(String.self, forKey: .doordashUrl)
        uberEatsUrl = try container.decodeIfPresent(String.self, forKey: .uberEatsUrl)
        websiteUrl = try container.decodeIfPresent(String.self, forKey: .websiteUrl)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        instagram = try container.decodeIfPresent(String.self, forKey: .instagram)
    }
}

struct Dishes: Decodable {
    let count: Int
    let dishes: [Dish]
    
    enum CodingKeys: String, CodingKey {
        case count
        case dishes = "data"
    }
}
