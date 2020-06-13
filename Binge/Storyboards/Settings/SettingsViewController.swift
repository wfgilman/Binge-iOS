//
//  SettingsViewController.swift
//  Binge
//
//  Created by Will Gilman on 6/11/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import Eureka
import HGPlaceholders

class SettingsViewController: FormViewController {
    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            fillFormUserFields(user: user)
        }
    }
    
    private var friend: User? {
        didSet {
            if let friendRow: ButtonRow = form.rowBy(tag: "friend") {
                friendRow.title = friend?.firstName ?? "Invite a Friend"
                friendRow.baseCell.tintColor = .purple
                friendRow.reload()
            }
        }
    }
    
    private var friends = [User]()
    
    private let table = TableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureListener()
        configureNavigationBar()
        layoutForm()
        table.placeholderDelegate = self
        table.placeholdersProvider = CustomPlaceholder.createAccount
        layoutTable()
        loadFormData()
        showCorrectView()
    }
    
    private func configureListener() {
        NotificationCenter.default.addObserver(forName: .deletedUser, object: nil, queue: .main) { (_) in
            self.showCorrectView()
        }
        NotificationCenter.default.addObserver(forName: .createdUser, object: nil, queue: .main) { (_) in
            self.loadFormData()
            self.showCorrectView()
        }
        NotificationCenter.default.addObserver(forName: .addedFriend, object: nil, queue: .main) { (_) in
            self.getFriend()
            self.getFriends()
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Binge"
        if let navBar = navigationController?.navigationBar {
             navBar.setup(titleColor: .black, hasBottomBorder: true, isTranslucent: false)
        }
    }
    
    private func layoutForm() {
        form +++ Section("Match 😍")
        <<< ButtonRow() { row in
            row.tag = "friend"
        }.onCellSelection({ (_, _) in
            let storyboard = UIStoryboard(name: "Invite", bundle: nil)
            guard let contactsVC = storyboard.instantiateInitialViewController() else { return }
            self.present(contactsVC, animated: true, completion: nil)
        })
        +++ Section("Profile")
        <<< TextRow() { row in
            row.tag = "firstName"
            row.title = "First Name"
        }
        <<< TextRow() { row in
            row.tag = "lastName"
            row.title = "Last Name"
        }
        <<< PhoneRow() { row in
            row.tag = "phone"
            row.title = "Phone"
        }
        <<< EmailRow() { row in
            row.tag = "email"
            row.title = "Email"
        }
        +++ Section("")
        <<< ButtonRow() { row in
            row.title = "Delete Account"
            row.baseCell.tintColor = .red
        }
        .onCellSelection({ (_, _) in
            self.deleteUser()
        })
    }
    
    private func layoutTable() {
        view.addSubview(table)
        table.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                     left: view.safeAreaLayoutGuide.leftAnchor,
                     bottom: view.safeAreaLayoutGuide.bottomAnchor,
                     right: view.safeAreaLayoutGuide.rightAnchor)
    }
    
    private func showCorrectView() {
        if User.exists() == true {
            view.sendSubviewToBack(table)
        } else {
            view.bringSubviewToFront(table)
        }
    }
    
    private func loadFormData() {
        if User.exists() == true {
            getUser()
            getFriend()
            getFriends()
        }
    }
    
    private func getUser() {
        BingeAPI.sharedClient.getUser(success: { (user) in
            self.user = user
        }) { (_, message) in
            guard let message: String = message else { return }
            print(message)
        }
    }
    
    private func getFriend() {
        BingeAPI.sharedClient.getFriend(success: { (friend) in
            self.friend = friend
        }) { (_, message) in
            guard let message: String = message else { return }
            print(message)
        }
    }
    
    private func getFriends() {
        BingeAPI.sharedClient.getFriends(success: { (friends) in
            self.friends = friends
        }) { (_, message) in
            guard let message: String = message else { return }
            print(message)
        }
    }
    
    private func deleteUser() {
        BingeAPI.sharedClient.deleteUser(success: {
            print("User deleted")
            User.delete()
        }) { (_, message) in
            guard let message: String = message else { return }
            print(message)
        }
    }
    
    private func fillFormUserFields(user: User) {
        if let firstNameRow: TextRow = form.rowBy(tag: "firstName") {
            firstNameRow.value = user.firstName
            firstNameRow.reload()
        }
        if let lastNameRow: TextRow = form.rowBy(tag: "lastName") {
            lastNameRow.value = user.lastName
            lastNameRow.reload()
        }
        if let phoneRow: PhoneRow = form.rowBy(tag: "phone") {
            phoneRow.value = user.phone.formatPhoneNumber()
            phoneRow.reload()
        }
        if let emailRow: EmailRow = form.rowBy(tag: "email") {
            emailRow.value = user.email
            emailRow.reload()
        }
    }
    
}

extension SettingsViewController: PlaceholderDelegate {
    
    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
        let storyboard = UIStoryboard(name: "Onboard", bundle: nil)
        guard let signupVC = storyboard.instantiateInitialViewController() else { return }
        self.present(signupVC, animated: true, completion: nil)
    }
}
