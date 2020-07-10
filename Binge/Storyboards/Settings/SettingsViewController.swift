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
                    Friend(id: friend.id, firstName: friend.firstName, status: friend.status, friendId: friend.friendId)
                })
                friendsRow.reload()
            }
        }
    }
    
    private let alert = CustomAlertController()
    
    private struct Friend: Equatable {
        let id: Int
        let firstName: String
        let status: String
        let friendId: Int?
        
        static func ==(lhs: Friend, rhs: Friend) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    private lazy var table: TableView = {
        let tableView = TableView(frame: .zero, style: .plain)
        tableView.placeholderDelegate = self
        tableView.placeholdersProvider = CustomPlaceholder.createAccount
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureListener()
        configureNavigationBar()
        layoutForm()
        layoutTable()
        initializeFormData()
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
        NotificationCenter.default.addObserver(forName: .updatedUser, object: nil, queue: .main) { (_) in
            self.getUser()
        }
        NotificationCenter.default.addObserver(forName: .addedFriend, object: nil, queue: .main) { (_) in
            self.getFriend()
            self.getFriends()
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Settings"
        if let navBar = navigationController?.navigationBar {
             navBar.setup(titleColor: .black, hasBottomBorder: true, isTranslucent: false)
        }
    }
    
    private func layoutForm() {
        form
        +++ Section("FRIENDS 😍")
        <<< PushRow<Friend>("friends") { row in
            row.title = "Dining with"
            row.options = []
            row.hidden = true
            row.displayValueFor = { row in
                return row?.firstName
            }
        }
        .onPresent({ (pushController, selectionController) in
            selectionController.enableDeselection = false
            selectionController.selectableRowCellUpdate = { cell, row in
                let friendsRow: PushRow<Friend> = pushController.form.rowBy(tag: "friends") as! PushRow<SettingsViewController.Friend>
                guard let friends = friendsRow.options else { return }
                guard let index = row.indexPath?.row else { return }
                let friend: Friend = friends[index]
                let label = self.friendLabel(friend: friend)
                cell.contentView.addSubview(label)
                label.anchor(right: cell.safeAreaLayoutGuide.rightAnchor, centerY: cell.contentView.centerYAnchor, paddingRight: 48)
            }
        })
        .onChange({ (row) in
            guard let friend = row.value else { return }
            // Calling NotificationCenter here seems to cancel the callback 🤷‍♂️
            let params: Dictionary<String, String> = ["friend_id": "\(friend.id)"]
            self.updateProfile(params)
        })
            
        <<< ButtonRow("friendInvite") { row in
            row.hidden = false
            row.title = "Dine with a Friend"
        }
        .onCellSelection({ (_, _) in
            let storyboard = UIStoryboard(name: "Invite", bundle: nil)
            guard let contactsVC = storyboard.instantiateInitialViewController() else { return }
            self.present(contactsVC, animated: true, completion: nil)
        })
            
        +++ Section("PROFILE")
        <<< TextRow("firstName") { row in
            row.title = "First Name"
            row.add(rule: RuleRequired())
            row.add(rule: RuleMinLength(minLength: 2))
            row.validationOptions = .validatesOnChange
        }
        .cellUpdate({ (cell, row) in
            if row.isValid == false {
                cell.titleLabel?.textColor = .systemRed
            }
        })
        .onCellHighlightChanged({ (_, row) in
            if row.isHighlighted == false && row.isValid == true {
                guard let value: String = row.value else { return }
                let params: Dictionary<String, String> = ["first_name": value]
                self.updateProfile(params)
            }
        })
            
        <<< TextRow("lastName") { row in
            row.title = "Last Name"
            row.add(rule: RuleMinLength(minLength: 1))
            row.validationOptions = .validatesOnChange
        }
        .cellUpdate({ (cell, row) in
            if row.isValid == false {
                cell.titleLabel?.textColor = .systemRed
            }
        })
        .onCellHighlightChanged({ (_, row) in
            if row.isHighlighted == false && row.isValid == true {
                guard let value: String = row.value else { return }
                let params: Dictionary<String, String> = ["last_name": value]
                self.updateProfile(params)
            }
        })
            
        <<< PhoneRow("phone") { row in
            row.title = "Phone"
            row.baseCell.isUserInteractionEnabled = false
        }
        .cellUpdate({ (cell, _) in
            cell.textField.textColor = .lightGray
        })
            
        <<< EmailRow("email") { row in
            row.title = "Email"
            row.add(rule: RuleEmail())
            row.validationOptions = .validatesOnChange
        }
        .onChange({ (row) in
            row.value = row.value?.trimmingCharacters(in: .whitespacesAndNewlines)
            row.updateCell()
        })
        .cellUpdate({ (cell, row) in
            if row.isValid == false {
                cell.titleLabel?.textColor = .systemRed
            }
        })
        .onCellHighlightChanged({ (_, row) in
            if row.isHighlighted == false && row.isValid == true {
                guard let value: String = row.value else { return }
                let params: Dictionary<String, String> = ["email": value]
                self.updateProfile(params)
            }
        })
            
        +++ Section("NOTIFICATIONS")
        <<< SwitchRow("pushNotification") { row in
            row.title = "New Matches"
        }
        .onChange({ (row) in
            guard let value: Bool = row.value else { return }
            self.setNotification(value) { (revert) in
                if revert == true {
                    DispatchQueue.main.async {
                        row.value = false
                        row.reload()
                    }
                }
            }
        })
            
        +++ ButtonRow("shareBinge") { row in
            row.title = "Share Binge"
            row.baseCell.tintColor = .black
        }
        .onCellSelection({ (_, _) in
            let activity = UIActivityViewController(activityItems: [AppVariable.shareText], applicationActivities: nil)
            self.present(activity, animated: true, completion: nil)
        })
            
        +++ ButtonRow("deleteAccount") { row in
            row.title = "Delete Account"
            row.baseCell.tintColor = .red
        }
        .onCellSelection({ (_, _) in
            self.deleteUser()
        })
    }
    
    private func friendLabel(friend: Friend) -> UILabel {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 15)
        if friend.status == "invited" {
            label.textColor = .lightGray
            label.text = "Invited"
            return label
        } else if friend.friendId == self.user?.id && friend.status == "verified" {
            label.textColor = .blue
            label.text = "Matching You"
            return label
        } else {
            return label
        }
    }
    
    private func layoutTable() {
        view.addSubview(table)
        table.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                     left: view.safeAreaLayoutGuide.leftAnchor,
                     bottom: view.safeAreaLayoutGuide.bottomAnchor,
                     right: view.safeAreaLayoutGuide.rightAnchor)
    }
    
    private func showCorrectView() {
        if AppVariable.validUser == true {
            view.sendSubviewToBack(table)
        } else {
            view.bringSubviewToFront(table)
        }
    }
    
    private func initializeFormData() {
        if AppVariable.validUser == true {
            if let user = DataLoader.shared.user {
                self.user = user
            } else {
                getUser()
            }
            if let friend = DataLoader.shared.friend {
                self.friend = friend
            } else {
                getFriend()
            }
            if DataLoader.shared.friends.count > 0 {
                self.friends = DataLoader.shared.friends
            } else {
                getFriends()
            }
        }
    }
    
    private func loadFormData() {
        if AppVariable.validUser == true {
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
    
    
    private func updateProfile(_ params: Dictionary<String,String>) {
        BingeAPI.sharedClient.updateUser(params: params, success: {
            if params["friend_id"] != nil {
                NotificationCenter.default.post(name: .changedFriend, object: nil)
            }
        }) { (_, message) in
            guard let message: String = message else { return }
            print(message)
        }
    }
    
    private func setNotification(_ value: Bool, completion: @escaping (_ revert: Bool) -> ()) {
        let params: Dictionary<String, String> = ["push_enabled": "\(value)"]
        if value == true {
            PushAPI.shared.checkAccess(completion: { (granted) in
                if granted == false {
                    DispatchQueue.main.async {
                        let alert = self.alert.openSettings(title: "Enable Push Notifications",
                                                            message: "Enable Binge push notifications in Settings to alert you with new matches.")
                        self.present(alert, animated: true, completion: nil)
                    }
                    completion(true)
                } else {
                    self.updateProfile(params)
                    completion(false)
                }
            })
        } else {
            self.updateProfile(params)
            completion(false)
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
            friendRow.value = Friend(id: friend.id, firstName: friend.firstName, status: friend.status, friendId: friend.friendId)
            friendRow.hidden = false
            friendRow.evaluateHidden()
            friendRow.reload()
            let friendInviteRow: ButtonRow = form.rowBy(tag: "friendInvite") as! ButtonRow
            friendInviteRow.title = "Add Someone New"
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
        if let pushNotificationRow: SwitchRow = form.rowBy(tag: "pushNotification") {
            pushNotificationRow.value = user.pushEnabled
            pushNotificationRow.reload()
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
