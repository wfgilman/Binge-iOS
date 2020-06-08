//
//  VerifyViewController.swift
//  Binge
//
//  Created by Will Gilman on 6/6/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import AnimatedTextInput

class VerifyViewController: UIViewController {
    
    private let codeTextField: AnimatedTextInput = {
        let codeField = AnimatedTextInput()
        codeField.style = CustomTextInputStyle()
        codeField.type = .numeric
        codeField.placeHolderText = "Enter Verification Code"
        return codeField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        layoutTextFields()
        generateCode()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch: UITouch = touches.first else { return }
        print("called")
        if touch.view != codeTextField {
            codeTextField.resignFirstResponder()
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Sign up"
        navigationItem.hidesBackButton = true
        navigationItem.addTextButton(side: .Right, text: "Confirm", color: .black, target: self, action: #selector(confirmCode))
    }
    
    private func layoutTextFields() {
        view.addSubview(codeTextField)
        codeTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                            left: view.safeAreaLayoutGuide.leftAnchor,
                            right: view.safeAreaLayoutGuide.rightAnchor,
                            paddingTop: 60,
                            paddingLeft: 20,
                            paddingRight: 20,
                            height: 44)
    }
    
    private func generateCode() {
        BingeAPI.sharedClient.generateCode(success: {
            print("SMS sent with code")
        }) { (_, message) in
            guard let message: String = message else { return }
            print(message)
        }
    }
    
    @objc private func confirmCode() {
        codeTextField.resignFirstResponder()
        guard let code: String = codeTextField.text else { return }
        BingeAPI.sharedClient.verifyCode(code: code, success: { (token) in
            AppVariable.accessToken = token.accessToken
        }) { (_, message) in
            guard let message: String = message else { return }
            self.codeTextField.show(error: message)
        }
    }
}

extension VerifyViewController: AnimatedTextInputDelegate {
    
    func animatedTextInputDidBeginEditing(animatedTextInput: AnimatedTextInput) {
        codeTextField.clearError()
    }
}
