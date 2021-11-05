//
//  Like.swift
//  Binge
//
//  Created by Will Gilman on 7/11/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation

struct Like: Decodable {
    let dishId: Int
    let restaurantId: Int
    
    enum CodingKeys: String, CodingKey {
        case dishId = "dish_id"
        case restaurantId = "restaurant_id"
    }
}

struct Likes: Decodable {
    let count: Int
    let likes: [Like]
    
    enum CodingKeys: String, CodingKey {
        case count
        case likes = "data"
    }
}
