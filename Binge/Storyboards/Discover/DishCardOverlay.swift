//
//  DishCardOverlay.swift
//  Binge
//
//  Created by Will Gilman on 5/24/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import Shuffle_iOS

class DishCardOverlay: UIView {
    
    required init?(coder: NSCoder) {
      return nil
    }
    
    init(direction: SwipeDirection) {
      super.init(frame: .zero)
      switch direction {
      case .left:
        createLeftOverlay()
      case .up:
        createUpOverlay()
      case .right:
        createRightOverlay()
      default:
        break
      }
    }

    private func createLeftOverlay() {
        let leftTextView = DishCardOverlayLabelView(withTitle: "MEH 😒", color: .red, rotation: .pi / 10)
        addSubview(leftTextView)
        leftTextView.anchor(top: topAnchor,
                            right: rightAnchor,
                            paddingTop: 44,
                            paddingRight: 16)
    }

    private func createUpOverlay() {
        let upTextView = DishCardOverlayLabelView(withTitle: "LET'S EAT", color: .blue, rotation: -.pi / 20)
        addSubview(upTextView)
        upTextView.anchor(bottom: bottomAnchor, paddingBottom: 20)
        upTextView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    private func createRightOverlay() {
        let rightTextView = DishCardOverlayLabelView(withTitle: "YUM 🤤", color: .green, rotation: -.pi / 10)
        addSubview(rightTextView)
        rightTextView.anchor(top: topAnchor,
                           left: leftAnchor,
                           paddingTop: 44,
                           paddingLeft: 14)
    }
}

class DishCardOverlayLabelView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    init(withTitle title: String, color: UIColor, rotation: CGFloat) {
        super.init(frame: CGRect.zero)
        layer.borderColor = color.cgColor
        layer.borderWidth = 4
        layer.cornerRadius = 4
        transform = CGAffineTransform(rotationAngle: rotation)

        addSubview(titleLabel)
        titleLabel.textColor = color
        titleLabel.attributedText = NSAttributedString(string: title,
                                                       attributes: NSAttributedString.Key.overlayAttributes)
        titleLabel.anchor(top: topAnchor,
                          left: leftAnchor,
                          bottom: bottomAnchor,
                          right: rightAnchor,
                          paddingLeft: 8,
                          paddingRight: 3)
    }
}
