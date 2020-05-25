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
    
    private let backgroundView: UIView = {
      let background = UIView()
      background.clipsToBounds = true
      background.layer.cornerRadius = 10
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
    
    init(withDish dish: Dish) {
        super.init(frame: .zero)
        let url = URL(string: dish.imageUrl)
        imageView.kf.setImage(with: url)
        initialize()
    }
    
    private func initialize() {
        addSubview(backgroundView)
        backgroundView.anchorToSuperview()
        backgroundView.addSubview(imageView)
        imageView.anchorToSuperview()
        applyShadow(radius: 8, opacity: 0.2, offset: CGSize(width: 0, height: 2))
        backgroundView.layer.insertSublayer(gradientLayer, above: imageView.layer)
    }
    
    override func draw(_ rect: CGRect) {
      super.draw(rect)
      let heightFactor: CGFloat = 0.35
      gradientLayer.frame = CGRect(x: 0, y: (1 - heightFactor) * bounds.height,
                                   width: bounds.width,
                                   height: heightFactor * bounds.height)
    }
    
}
