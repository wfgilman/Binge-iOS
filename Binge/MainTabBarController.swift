//
//  MainTabBarController.swift
//  Binge
//
//  Created by Will Gilman on 6/22/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let title: String = item.title else { return }
        if title == "Match" {
            self.clearBadge(position: 2)
        }
    }
}
