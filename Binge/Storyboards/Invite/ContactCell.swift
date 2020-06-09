//
//  ContactCell.swift
//  Binge
//
//  Created by Will Gilman on 6/8/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import Contacts

class ContactCell: UITableViewCell {

    static var identifier: String = "ContactCell"
    
    var contact: CNContact! {
        didSet {
            nameLabel.text = "\(contact.givenName) \(contact.familyName)"
        }
    }
    
    private let nameLabel: UILabel = {
       let name = UILabel()
        name.font = UIFont.systemFont(ofSize: 17)
        name.textColor = .black
        return name
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutContent()
     }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func layoutContent() {
        contentView.addSubview(nameLabel)
        nameLabel.anchor(left: contentView.safeAreaLayoutGuide.leftAnchor,
                         right: contentView.safeAreaLayoutGuide.rightAnchor,
                         centerY: contentView.safeAreaLayoutGuide.centerYAnchor,
                         paddingLeft: 16,
                         paddingRight: 16)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
    }

}
