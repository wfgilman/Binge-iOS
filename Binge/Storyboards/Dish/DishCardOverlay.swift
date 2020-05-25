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
        let leftTextView = UILabel(frame: .zero)
        leftTextView.text = "👎"
        leftTextView.font = UIFont.systemFont(ofSize: 56)
        addSubview(leftTextView)
        leftTextView.anchor(top: topAnchor,
                            right: rightAnchor,
                            paddingTop: 32,
                            paddingRight: 32)
    }

    private func createUpOverlay() {
        let upTextView = UILabel(frame: .zero)
        upTextView.text = "💸"
        upTextView.font = UIFont.systemFont(ofSize: 56)
        addSubview(upTextView)
        upTextView.anchor(bottom: bottomAnchor, paddingBottom: 20)
        upTextView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    private func createRightOverlay() {
        let rightTextView = UILabel(frame: .zero)
        rightTextView.text = "🤤"
        rightTextView.font = UIFont.systemFont(ofSize: 56)
        addSubview(rightTextView)
        rightTextView.anchor(top: topAnchor,
                           left: leftAnchor,
                           paddingTop: 32,
                           paddingLeft: 32)
    }
}

private class DishCardOverlayLabelView: UIView {
  
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
