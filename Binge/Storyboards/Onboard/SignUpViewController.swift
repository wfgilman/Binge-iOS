//
//  SignUpViewController.swift
//  Binge
//
//  Created by Will Gilman on 6/4/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import AnimatedTextInput

class SignUpViewController: UIViewController {
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19)
        label.text = "Create your account"
        return label
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneTextField.delegate = self
        configureNavigationBar()
        layoutTextFields()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is VerifyViewController {
            let verifyVC = segue.destination as! VerifyViewController
            verifyVC.user = sender as? User
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Sign up"
        navigationItem.addTextButton(side: .Right, text: "Next", color: .black, target: self, action: #selector(createUser))
    }
    
    private func layoutTextFields() {
        view.addSubview(instructionLabel)
        instructionLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                centerX: view.safeAreaLayoutGuide.centerXAnchor,
                                paddingTop: 40)
        view.addSubview(nameTextField)
        nameTextField.anchor(top: instructionLabel.topAnchor,
                             left: view.safeAreaLayoutGuide.leftAnchor,
                             right: view.safeAreaLayoutGuide.rightAnchor,
                             paddingTop: 44,
                             paddingLeft: 20,
                             paddingRight: 20,
                             height: 44)
        view.addSubview(phoneTextField)
        phoneTextField.anchor(top: nameTextField.bottomAnchor,
                             left: view.safeAreaLayoutGuide.leftAnchor,
                             right: view.safeAreaLayoutGuide.rightAnchor,
                             paddingTop: 44,
                             paddingLeft: 20,
                             paddingRight: 20,
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
    
    @objc private func createUser() {
        guard let name: String = nameTextField.text else { return }
        guard let phone: String = phoneTextField.text else { return }
        if validateFields() == true {
            BingeAPI.sharedClient.createUser(name: name, phone: phone, success: { (user) in
                self.performSegue(withIdentifier: "showVerifyViewController", sender: user)
            }) { (_, message) in
                guard let message: String = message else { return }
                print(message)
            }
        }
    }
}

extension SignUpViewController: AnimatedTextInputDelegate {
    
    func animatedTextInput(animatedTextInput: AnimatedTextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let phone = phoneTextField.text else { return false }
        let newPhone = (phone as NSString).replacingCharacters(in: range, with: string)
        phoneTextField.text = newPhone.formatPhoneNumber()
        return false
    }
}
