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
            guard let friend = friend else { return }
            fillFormFriendFields(friend: friend)
        }
    }
    
    private var friends = [User]() {
        didSet {
            if let friendsRow: PushRow<Friend> = form.rowBy(tag: "friends") {
                friendsRow.options = friends.map({ (friend) -> Friend in
                    Friend(id: friend.id, firstName: friend.firstName)
                })
                friendsRow.reload()
            }
        }
    }
    
    private struct Friend: Equatable {
        let id: Int
        let firstName: String
        
        static func ==(lhs: Friend, rhs: Friend) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    private var params = Dictionary<String, String>()
    
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
            self.configureNavigationBar()
        }
        NotificationCenter.default.addObserver(forName: .createdUser, object: nil, queue: .main) { (_) in
            self.loadFormData()
            self.showCorrectView()
            self.configureNavigationBar()
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
        if User.exists() == true {
            navigationItem.addTextButton(side: .Right, text: "Save", color: .black, target: self, action: #selector(updateProfile))
        }
    }
    
    private func layoutForm() {
        form +++ Section("Friend 😍")
        <<< PushRow<Friend>("friends") { row in
            row.title = "Matching with"
            row.options = []
            row.hidden = true
            row.displayValueFor = { row in
                return row?.firstName
            }
        }
        .onPresent({ (_, selectionController) in
            selectionController.enableDeselection = false
        })
        .onChange({ (row) in
            guard let friend = row.value else { return }
            // Calling NotificationCenter here seems to cancel the callback 🤷‍♂️
            self.params["friend_id"] = "\(friend.id)"
            self.updateProfile()
        })
        <<< ButtonRow("friendInvite") { row in
            row.hidden = false
            row.title = "Invite a Friend"
        }.onCellSelection({ (_, _) in
            let storyboard = UIStoryboard(name: "Invite", bundle: nil)
            guard let contactsVC = storyboard.instantiateInitialViewController() else { return }
            self.present(contactsVC, animated: true, completion: nil)
        })
        +++ Section("Profile")
        <<< TextRow("firstName") { row in
            row.title = "First Name"
            row.add(rule: RuleRequired())
            row.add(rule: RuleMinLength(minLength: 2))
            row.validationOptions = .validatesOnChange
        }
        .cellUpdate({ (cell, row) in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
            } else {
                self.params["first_name"] = row.value
            }
        })
        <<< TextRow("lastName") { row in
            row.title = "Last Name"
        }
        .cellUpdate({ (_, row) in
            if (row.value != nil) && (row.value != "") {
                self.params["last_name"] = row.value
            }
        })
        <<< PhoneRow("phone") { row in
            row.title = "Phone"
            row.baseCell.isUserInteractionEnabled = false
        }
        <<< EmailRow("email") { row in
            row.title = "Email"
            row.add(rule: RuleEmail())
            row.validationOptions = .validatesOnChange
        }
        .cellUpdate({ (cell, row) in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
            } else {
                self.params["email"] = row.value
            }
        })
        +++ ButtonRow("deleteAccount") { row in
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
    
    
    @objc private func updateProfile() {
        BingeAPI.sharedClient.updateUser(params: params, success: {
            if self.params["friend_id"] != nil {
                NotificationCenter.default.post(name: .changedFriend, object: nil)
            }
        }) { (_, message) in
            guard let message: String = message else { return }
            print(message)
        }
    }
    
    private func deleteUser() {
        BingeAPI.sharedClient.deleteUser(success: {
            User.delete()
        }) { (_, message) in
            guard let message: String = message else { return }
            print(message)
        }
    }
    
    private func fillFormFriendFields(friend: User) {
        if let friendRow: PushRow<Friend> = form.rowBy(tag: "friends") {
            friendRow.value = Friend(id: friend.id, firstName: friend.firstName)
            friendRow.hidden = false
            friendRow.evaluateHidden()
            friendRow.reload()
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
