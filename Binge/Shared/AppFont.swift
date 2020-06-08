//
//  AppFont.swift
//  Binge
//
//  Created by Will Gilman on 6/5/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit

struct AppFont {
    static let regular = "SanFranciscoDisplay-Regular"
    static let bold = "SanFranciscoDisplay-Bold"
    static let italic = "SanFranciscoDisplay-Regular"
    static let light = "SanFranciscoDisplay-Light"
    static let heavy = "SanFranciscoDisplay-Heavy"
}

extension UIFont {
    
    class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFont.regular, size: size)!
    }
}
