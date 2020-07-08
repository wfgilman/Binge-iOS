//
//  PushAPI.swift
//  Binge
//
//  Created by Will Gilman on 6/29/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import UserNotifications

class PushAPI {
    
    static let shared = PushAPI()
    
    private init() { }
    
    func requestAuth() {
        checkAccess { (granted) in
            if granted == false {
                if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                    if UIApplication.shared.canOpenURL(appSettings) {
                        DispatchQueue.main.async { UIApplication.shared.open(appSettings) }
                    }
                }
            }
        }
    }
    
    func send(dish: Dish) {
        checkAccess { (granted) in
            if granted == true {
                BingeAPI.sharedClient.dishAction(dish: dish, action: .match, success: {
                    // Nothing to see here
                }) { (_, message) in
                    guard let message = message else { return }
                    print("\(message)")
                }
            }
        }
    }
    
    func checkAccess(completion: @escaping (_ granted: Bool) -> ()) {
        let client = UNUserNotificationCenter.current()
        client.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .notDetermined:
                client.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
                    if granted == true {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            case .authorized, .provisional:
                // Case of user authorizing Push notifications then deleting his account and re-signing up.
                if AppVariable.deviceToken == nil {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                completion(true)
            case .denied:
                completion(false)
            default:
                completion(false)
            }
        }
    }
}
