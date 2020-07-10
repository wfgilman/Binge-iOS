//
//  DataLoader.swift
//  Binge
//
//  Created by Will Gilman on 6/24/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation

class DataLoader {
    
    static let shared = DataLoader()
    
    var dishes = [Dish]()
    var likedDishes = [Dish]()
    var matchedDishes = [Dish]()
    var user: User?
    var friend: User?
    var friends = [User]()
    
    private var validUser: Bool = false {
        didSet {
            AppVariable.validUser = validUser
            loadAll(validUser: validUser)
        }
    }
    
    private init() { }
    
    func initialize() {
        if AppVariable.accessToken != nil {
            BingeAPI.sharedClient.getUser(success: { (_) in
                self.validUser = true
            }) { (_, _) in
                self.validUser = false
            }
        } else {
            self.validUser = false
        }
    }
    
    private func loadAll(validUser: Bool) {
        let filter: DishFilter = (validUser == true) ? .none : .noauth
        BingeAPI.sharedClient.getDishes(filter: filter, success: { (dishes) in
            self.dishes = dishes
            print("loaded dishes: \(dishes.count)")
        }) { (_, message) in
            print(String(describing: message))
        }
        
        if validUser == true {
            BingeAPI.sharedClient.getDishes(filter: .like, success: { (dishes) in
                self.likedDishes = dishes
                print("loaded liked dishes: \(dishes.count)")
            }) { (_, message) in
                print(String(describing: message))
            }
            
            BingeAPI.sharedClient.getDishes(filter: .match, success: { (dishes) in
                self.matchedDishes = dishes
                print("loaded matching dishes: \(dishes.count)")
            }) { (_, message) in
                print(String(describing: message))
            }
            
            BingeAPI.sharedClient.getUser(success: { (user) in
                self.user = user
                print("loaded user")
            }) { (_, message) in
                print(String(describing: message))
            }
            
            BingeAPI.sharedClient.getFriend(success: { (user) in
                self.friend = user
                print("loaded friend")
            }) { (_, message) in
                print(String(describing: message))
            }
            
            BingeAPI.sharedClient.getFriends(success: { (users) in
                self.friends = users
                print("loaded friends")
            }) { (_, message) in
                print(String(describing: message))
            }
        }
    }
    
}
