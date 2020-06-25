//
//  UITabBarController.swift
//  Binge
//
//  Created by Will Gilman on 6/22/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit

extension UITabBarController {
    
    func incrementBadgeCount(position: Int) -> Void {
        var count: Int
        guard let currentValue = self.tabBar.items?[position].badgeValue else {
            self.tabBar.items?[position].badgeValue = "1"
            return
        }
        count = Int(currentValue)!
        count += 1
        self.tabBar.items?[position].badgeValue = "\(count)"
    }
    
    func clearBadge(position: Int) -> Void {
        self.tabBar.items?[position].badgeValue = nil
    }
}
