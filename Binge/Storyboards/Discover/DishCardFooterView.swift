//
//  DishCardFooterView.swift
//  Binge
//
//  Created by Will Gilman on 5/24/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit

class DishCardFooterView: UIView {
    
    private var label = UILabel()

    private var gradientLayer: CAGradientLayer?

    required init?(coder aDecoder: NSCoder) {
         return nil
     }
    
    init(withTitle title: String?, subtitle: String?) {
        super.init(frame: CGRect.zero)
        backgroundColor = .white
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 10
        clipsToBounds = true
        isOpaque = false
        initialize(title: title, subtitle: subtitle)
    }
    
    private func initialize(title: String?, subtitle: String?) {
       let attributedText = NSMutableAttributedString(string: (title ?? "") + "\n", attributes: NSAttributedString.Key.titleAttributes)
       if let subtitle = subtitle, !subtitle.isEmpty {
         attributedText.append(NSMutableAttributedString(string: subtitle, attributes: NSAttributedString.Key.subtitleAttributes))
         let paragraphStyle = NSMutableParagraphStyle()
         paragraphStyle.lineSpacing = 4
         paragraphStyle.lineBreakMode = .byTruncatingTail
         attributedText.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
         label.numberOfLines = 2
       }

       label.attributedText = attributedText
       addSubview(label)
     }

     override func layoutSubviews() {
       let padding: CGFloat = 20
       label.frame = CGRect(x: padding,
                            y: bounds.height - label.intrinsicContentSize.height - padding,
                            width: bounds.width - 2 * padding,
                            height: label.intrinsicContentSize.height)
     }
}
