//
//  MatchCell.swift
//  Binge
//
//  Created by Will Gilman on 6/4/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import SwipeCellKit

class MatchCell: SwipeTableViewCell {
    
    static var identifier: String = "MatchCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
