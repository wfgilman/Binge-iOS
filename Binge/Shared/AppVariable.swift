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
    
    static let shareText = "Check out Binge...discover, decide and dine with friends!"
    
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
    
    static var deviceToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "deviceToken")
        }
        set (newValue) {
            UserDefaults.standard.set(newValue, forKey: "deviceToken")
        }
    }
    
    static var validUser: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "validUser") || false
        }
        set (newValue) {
            UserDefaults.standard.set(newValue, forKey: "validUser")
        }
    }
}
