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
import AnimatedTextInput

class InviteViewController: UIViewController {
    
    var contact: CNContact? {
        didSet {
            guard let contact = contact else { return }
            nameTextField.text = "\(contact.givenName) \(contact.familyName)"
            nameTextField.isUserInteractionEnabled = false
            if let phone = contact.phoneNumbers.first {
                phoneTextField.text = phone.value.stringValue
                phoneTextField.isUserInteractionEnabled = false
            }
        }
    }
    
    private let nameTextField: AnimatedTextInput = {
        let nameField = AnimatedTextInput()
        nameField.style = CustomTextInputStyle()
        nameField.type = .standard
        nameField.placeHolderText = "Name"
        return nameField
    }()
    
    private let phoneTextField: AnimatedTextInput = {
        let phoneField = AnimatedTextInput()
        phoneField.style = CustomTextInputStyle()
        phoneField.type = .phone
        phoneField.placeHolderText = "Phone Number"
        return phoneField
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
        phoneTextField.delegate = self
        configureNavigationBar()
        layoutContent()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch: UITouch = touches.first else { return }
        if touch.view != nameTextField {
            nameTextField.clearError()
            nameTextField.resignFirstResponder()
        }
        if touch.view != phoneTextField {
            phoneTextField.clearError()
            phoneTextField.resignFirstResponder()
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Invite a Friend"
     }
     
    private func layoutContent() {
        view.addSubview(nameTextField)
        nameTextField.anchor(left: view.safeAreaLayoutGuide.leftAnchor,
                         right: view.safeAreaLayoutGuide.rightAnchor,
                         centerY: view.safeAreaLayoutGuide.centerYAnchor,
                         paddingLeft: 20,
                         paddingRight: 20,
                         centerYOffset: -view.bounds.height / 3)
        view.addSubview(phoneTextField)
        phoneTextField.anchor(top: nameTextField.bottomAnchor,
                        left: view.safeAreaLayoutGuide.leftAnchor,
                        right: view.safeAreaLayoutGuide.rightAnchor,
                        paddingTop: 44,
                        paddingLeft: 20,
                        paddingRight: 20)
        view.addSubview(inviteButton)
        inviteButton.anchor(top: phoneTextField.bottomAnchor,
                         centerX: view.safeAreaLayoutGuide.centerXAnchor,
                         paddingTop: 44,
                         width: view.safeAreaLayoutGuide.layoutFrame.width / 3,
                         height: 44)
    }
    
    private func validateFields() -> Bool {
         guard let name = nameTextField.text else { return false }
         if name.count < 2 {
             nameTextField.show(error: "Name must be at least 2 characters.")
             return false
         }
         
         guard let phone = phoneTextField.text else { return false }
         if phone.cleanPhoneNumber().count < 10 {
             phoneTextField.show(error: "Phone Number must be 10 digits.")
             return false
         }
         
         return true
     }
     
     @objc private func sendInvitation() {
        var contact: CNMutableContact
        
        if self.contact == nil {
            guard let name: String = nameTextField.text else { return }
            guard let phone: String = phoneTextField.text else { return }
            guard validateFields() == true else { return }
            contact = createContact(name: name, phone: phone)
        } else {
            contact = self.contact!.mutableCopy() as! CNMutableContact
        }
        
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
    
    private func createContact(name: String, phone: String) -> CNMutableContact {
        let contact = CNMutableContact()
        contact.givenName = name
        let phoneNumber = CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: phone.cleanPhoneNumber()))
        contact.phoneNumbers = [phoneNumber]
        return contact
    }
}

extension InviteViewController: AnimatedTextInputDelegate {
    
    func animatedTextInput(animatedTextInput: AnimatedTextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let phone = phoneTextField.text else { return false }
        let newPhone = (phone as NSString).replacingCharacters(in: range, with: string)
        phoneTextField.text = newPhone.formatPhoneNumber()
        return false
    }
}
