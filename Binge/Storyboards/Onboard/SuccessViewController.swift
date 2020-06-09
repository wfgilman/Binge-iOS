//
//  SuccessViewController.swift
//  Binge
//
//  Created by Will Gilman on 6/7/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {
    
    private let successLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = "Success 🎉"
        return label
    }()
    
    private let inviteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Dining is more fun together. \nEspecially when you want the same thing."
        return label
    }()
    
    private let inviteButton: UIButton = {
        let buttonHeight: CGFloat = 44
        let button = UIButton()
        button.setTitle("Invite a Friend", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.backgroundColor = .purple
        button.layer.cornerRadius = buttonHeight / 2
        button.addTarget(self, action: #selector(segueToInvite), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        layoutContent()
    }
    
   private func configureNavigationBar() {
        navigationItem.title = "Sign up"
        navigationItem.hidesBackButton = true
    }
    
    private func layoutContent() {
        view.addSubview(successLabel)
        successLabel.anchor(left: view.safeAreaLayoutGuide.leftAnchor,
                            right: view.safeAreaLayoutGuide.rightAnchor,
                            centerY: view.safeAreaLayoutGuide.centerYAnchor,
                            paddingLeft: 20,
                            paddingRight: 20,
                            centerYOffset: -view.bounds.height / 6)
        view.addSubview(inviteLabel)
        inviteLabel.anchor(top: successLabel.bottomAnchor,
                           left: view.safeAreaLayoutGuide.leftAnchor,
                           right: view.safeAreaLayoutGuide.rightAnchor,
                           paddingTop: 20,
                           paddingLeft: 20,
                           paddingRight: 20)
        view.addSubview(inviteButton)
        inviteButton.anchor(top: inviteLabel.bottomAnchor,
                            centerX: view.safeAreaLayoutGuide.centerXAnchor,
                            paddingTop: 16,
                            width: view.safeAreaLayoutGuide.layoutFrame.width / 3,
                            height: 44)
    }
    
    @objc private func segueToInvite() {
        weak var pvc = self.presentingViewController
        self.dismiss(animated: false) {
            let storyboard = UIStoryboard(name: "Invite", bundle: nil)
            guard let contactsVC = storyboard.instantiateInitialViewController() else { return }
            pvc?.present(contactsVC, animated: true, completion: nil)
        }
    }
}
