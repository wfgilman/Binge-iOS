//
//  AppVariable.swift
//  Binge
//
//  Created by Will Gilman on 5/22/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation

struct AppVariable {
    
//    static let baseURL = "http://localhost:4000/api/v1"
    static let baseURL = "https://binge.gigalixirapp.com/api/v1"
    
    static var userId: Int? {
        get {
            return UserDefaults.standard.integer(forKey: "userId")
        }
        set (newValue) {
            UserDefaults.standard.set(newValue, forKey: "userId")
        }
    }
    
    static var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "accessToken")
        }
        set (newValue) {
            UserDefaults.standard.set(newValue, forKey: "accessToken")
        }
    }
}
