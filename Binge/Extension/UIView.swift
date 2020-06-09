//
//  UIView.swift
//  Binge
//
//  Created by Will Gilman on 5/24/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit

extension UIView {

  @discardableResult
  func anchor(top: NSLayoutYAxisAnchor? = nil,
              left: NSLayoutXAxisAnchor? = nil,
              bottom: NSLayoutYAxisAnchor? = nil,
              right: NSLayoutXAxisAnchor? = nil,
              centerX: NSLayoutXAxisAnchor? = nil,
              centerY: NSLayoutYAxisAnchor? = nil,
              paddingTop: CGFloat = 0,
              paddingLeft: CGFloat = 0,
              paddingBottom: CGFloat = 0,
              paddingRight: CGFloat = 0,
              centerXOffset: CGFloat = 0,
              centerYOffset: CGFloat = 0,
              width: CGFloat = 0,
              height: CGFloat = 0) -> [NSLayoutConstraint] {
    translatesAutoresizingMaskIntoConstraints = false

    var anchors = [NSLayoutConstraint]()

    if let top = top {
      anchors.append(topAnchor.constraint(equalTo: top, constant: paddingTop))
    }
    if let left = left {
      anchors.append(leftAnchor.constraint(equalTo: left, constant: paddingLeft))
    }
    if let bottom = bottom {
      anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom))
    }
    if let right = right {
      anchors.append(rightAnchor.constraint(equalTo: right, constant: -paddingRight))
    }
    if let centerX = centerX {
        anchors.append(centerXAnchor.constraint(lessThanOrEqualTo: centerX, constant: centerXOffset))
    }
    if let centerY = centerY {
        anchors.append(centerYAnchor.constraint(lessThanOrEqualTo: centerY, constant: centerYOffset))
    }
    if width > 0 {
      anchors.append(widthAnchor.constraint(equalToConstant: width))
    }
    if height > 0 {
      anchors.append(heightAnchor.constraint(equalToConstant: height))
    }

    anchors.forEach({$0.isActive = true})

    return anchors
  }

  @discardableResult
  func anchorToSuperview() -> [NSLayoutConstraint] {
    return anchor(top: superview?.topAnchor,
                  left: superview?.leftAnchor,
                  bottom: superview?.bottomAnchor,
                  right: superview?.rightAnchor)
  }

}

extension UIView {

  func applyShadow(radius: CGFloat,
                   opacity: Float,
                   offset: CGSize,
                   color: UIColor = .black) {
    layer.shadowRadius = radius
    layer.shadowOpacity = opacity
    layer.shadowOffset = offset
    layer.shadowColor = color.cgColor
  }
}
