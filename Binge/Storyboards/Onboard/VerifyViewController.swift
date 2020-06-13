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
    
    var user: User? {
        didSet {
            sendVerificationCode()
        }
    }
    
    private let codeTextField: AnimatedTextInput = {
        let codeField = AnimatedTextInput()
        codeField.style = CustomTextInputStyle()
        codeField.type = .numeric
        codeField.placeHolderText = "Enter Verification Code"
        return codeField
    }()
    
    private let resendCodeButton: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 0.0
        button.setTitle("Resend code", for: .normal)
        button.setTitleColor(.purple, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(sendVerificationCode), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        layoutTextFields()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch: UITouch = touches.first else { return }
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
        view.addSubview(resendCodeButton)
        resendCodeButton.anchor(top: codeTextField.bottomAnchor,
                                left: view.safeAreaLayoutGuide.leftAnchor,
                                right: view.safeAreaLayoutGuide.rightAnchor,
                                paddingTop: 8,
                                paddingLeft: 20,
                                paddingRight: 20)
    }
    
    @objc private func sendVerificationCode() {
        guard let user: User = self.user else {
            print("no user")
            return
        }
        BingeAPI.sharedClient.generateCode(user: user, success: {
            print("SMS sent with code")
        }) { (_, message) in
            guard let message: String = message else { return }
            print(message)
        }
    }
    
    @objc private func confirmCode() {
        codeTextField.resignFirstResponder()
        guard let code: String = codeTextField.text else { return }
        guard let user: User = self.user else { return }
        BingeAPI.sharedClient.verifyCode(user: user, code: code, success: { (token) in
            User.create(with: token)
            self.performSegue(withIdentifier: "showSuccessViewController", sender: nil)
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
