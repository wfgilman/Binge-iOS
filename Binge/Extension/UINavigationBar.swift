//
//  UINavigationBar.swift
//  Binge
//
//  Created by Will Gilman on 5/24/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    func setup(titleColor: UIColor?, hasBottomBorder: Bool, isTranslucent: Bool) {
        self.tintColor = UIColor.white
        self.barTintColor = UIColor.white
        if !hasBottomBorder {
            self.setBackgroundImage(UIImage(), for: .default)
            self.shadowImage = UIImage()
        } else {
            self.shadowImage = nil
        }
        self.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : titleColor ?? UIColor.black,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        self.isTranslucent = isTranslucent
    }
}
