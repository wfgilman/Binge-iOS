//
//  MatchTile.swift
//  Binge
//
//  Created by Will Gilman on 11/20/21.
//  Copyright © 2021 BGHFM. All rights reserved.
//

import UIKit

class MatchTile: UICollectionViewCell {
    
    static var identifier: String = "MatchTile"
    
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
