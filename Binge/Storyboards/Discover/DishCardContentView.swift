//
//  CardView.swift
//  Binge
//
//  Created by Will Gilman on 5/24/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class DishCardContentView: UIView {
    
    private var bevelAmount: CGFloat!
    private var hasShadow: Bool!
    private var footerHeight: CGFloat!
    
    private let backgroundView: UIView = {
      let background = UIView()
      background.clipsToBounds = true
      return background
    }()
    
    private let imageView: UIImageView = {
      let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
      return imageView
    }()
    
    private let gradientLayer: CAGradientLayer = {
      let gradient = CAGradientLayer()
      gradient.colors = [UIColor.black.withAlphaComponent(0.01).cgColor,
                         UIColor.black.withAlphaComponent(0.8).cgColor]
      gradient.startPoint = CGPoint(x: 0.5, y: 0)
      gradient.endPoint = CGPoint(x: 0.5, y: 1)
      return gradient
    }()
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(withDish dish: Dish, bevelAmount: CGFloat = 10, hasShadow: Bool = true) {
        super.init(frame: .zero)
        let url = URL(string: dish.imageUrl)
        imageView.kf.setImage(with: url)
        self.bevelAmount = bevelAmount
        self.hasShadow = hasShadow
        initialize()
    }
    
    private func initialize() {
        backgroundView.layer.cornerRadius = bevelAmount
        backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addSubview(backgroundView)
        backgroundView.anchorToSuperview()
        backgroundView.addSubview(imageView)
        imageView.anchorToSuperview()
        applyShadow(radius: 8, opacity: 0.2, offset: CGSize(width: 0, height: 2))
        if hasShadow {
            backgroundView.layer.insertSublayer(gradientLayer, above: imageView.layer)
        }
    }
    
    override func draw(_ rect: CGRect) {
      super.draw(rect)
      let heightFactor: CGFloat = 0.35
      gradientLayer.frame = CGRect(x: 0, y: (1 - heightFactor) * bounds.height,
                                   width: bounds.width,
                                   height: heightFactor * bounds.height)
    }
    
}
