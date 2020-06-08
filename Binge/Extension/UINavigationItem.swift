//
//  UINavigationItem.swift
//  Binge
//
//  Created by Will Gilman on 6/6/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit

enum Side {
    case Right
    case Left
}

extension UINavigationItem {
    
    func addTextButton(side: Side, text: String, color: UIColor, target: UIViewController, action: Selector) {
        let button = UIBarButtonItem(title: text, style: .plain, target: target, action: action)
        let attributes: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 17),
            .foregroundColor : color
        ]
        button.setTitleTextAttributes(attributes, for: .normal)
        button.setTitleTextAttributes(attributes, for: .selected)
        button.tintColor = color
        if side == .Right {
            self.rightBarButtonItem = button
        } else {
            self.leftBarButtonItem = button
        }
    }
}
