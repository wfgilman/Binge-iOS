//
//  InviteViewController.swift
//  Binge
//
//  Created by Will Gilman on 6/8/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import Contacts
import NotificationBannerSwift

class InviteViewController: UIViewController {
    
    var contact: CNContact! {
        didSet {
            nameLabel.text = "\(contact.givenName) \(contact.familyName)"
            if let phone = contact.phoneNumbers.first {
                phoneLabel.text = phone.value.stringValue
            }
        }
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let inviteButton: UIButton = {
        let buttonHeight: CGFloat = 44
        let button = UIButton()
        button.setTitle("Send Invite", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.backgroundColor = .purple
        button.layer.cornerRadius = buttonHeight / 2
        button.addTarget(self, action: #selector(sendInvitation), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        layoutContent()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Invite a Friend"
     }
     
     private func layoutContent() {
         view.addSubview(nameLabel)
         nameLabel.anchor(left: view.safeAreaLayoutGuide.leftAnchor,
                             right: view.safeAreaLayoutGuide.rightAnchor,
                             centerY: view.safeAreaLayoutGuide.centerYAnchor,
                             paddingLeft: 20,
                             paddingRight: 20,
                             centerYOffset: -view.bounds.height / 6)
         view.addSubview(phoneLabel)
         phoneLabel.anchor(top: nameLabel.bottomAnchor,
                            left: view.safeAreaLayoutGuide.leftAnchor,
                            right: view.safeAreaLayoutGuide.rightAnchor,
                            paddingTop: 8,
                            paddingLeft: 20,
                            paddingRight: 20)
         view.addSubview(inviteButton)
         inviteButton.anchor(top: phoneLabel.bottomAnchor,
                             centerX: view.safeAreaLayoutGuide.centerXAnchor,
                             paddingTop: 16,
                             width: view.safeAreaLayoutGuide.layoutFrame.width / 3,
                             height: 44)
     }
     
     @objc private func sendInvitation() {
        BingeAPI.sharedClient.inviteUser(contact: contact, success: {
            NotificationCenter.default.post(name: .addedFriend, object: nil)
            NotificationCenter.default.post(name: .changedFriend, object: nil)
            PushAPI.shared.requestAuth()
            self.dismiss(animated: true, completion: nil)
        }) { (_, message) in
            guard let message: String = message else { return }
            let banner = NotificationBanner(title: message, style: .danger)
            banner.show()
        }
     }
}
