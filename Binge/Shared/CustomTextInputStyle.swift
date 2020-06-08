//
//  CustomTextInputStyle.swift
//  Binge
//
//  Created by Will Gilman on 6/6/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import AnimatedTextInput

struct CustomTextInputStyle: AnimatedTextInputStyle {
    
    var activeColor: UIColor = .purple
    
    var placeholderInactiveColor: UIColor = .black
    
    var inactiveColor: UIColor = .black
    
    var lineInactiveColor: UIColor = .black
    
    var lineActiveColor: UIColor = .purple
    
    var lineHeight: CGFloat = 1
    
    var errorColor: UIColor = .red
    
    var textInputFont: UIFont = UIFont.systemFont(ofSize: 17)
    
    var textInputFontColor: UIColor = .black
    
    var placeholderMinFontSize: CGFloat = 15
    
    var counterLabelFont: UIFont?
    
    var leftMargin: CGFloat = 8
    
    var topMargin: CGFloat = 28
    
    var rightMargin: CGFloat = 8
    
    var bottomMargin: CGFloat = 4
    
    var yHintPositionOffset: CGFloat = 4
    
    var yPlaceholderPositionOffset: CGFloat = 0
    
    var textAttributes: [String : Any]?
}
