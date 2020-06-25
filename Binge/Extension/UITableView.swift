//
//  UITableView.swift
//  Binge
//
//  Created by Will Gilman on 6/23/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit

extension UITableView {
    
    func reload() {
        let contentOffset = self.contentOffset
        self.reloadData()
        self.setContentOffset(contentOffset, animated: false)
    }
}
