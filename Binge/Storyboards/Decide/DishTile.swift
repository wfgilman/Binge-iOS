//
//  DishTile.swift
//  Binge
//
//  Created by Will Gilman on 11/17/21.
//  Copyright © 2021 BGHFM. All rights reserved.
//

import UIKit

class DishTile: UICollectionViewCell {
    
    static var identifier: String = "DishTile"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
