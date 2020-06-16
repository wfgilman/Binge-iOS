//
//  Notification.swift
//  Binge
//
//  Created by Will Gilman on 5/30/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let likedDish = Notification.Name("likedDish")
    static let createdUser = Notification.Name("createdUser")
    static let deletedUser = Notification.Name("deletedUser")
    static let addedFriend = Notification.Name("addedFriend")
    static let changedFriend = Notification.Name("changedFriend")
}
