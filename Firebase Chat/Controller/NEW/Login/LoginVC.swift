//
//  LoginVC.swift
//  Firebase Chat
//
//  Created by Admin on 17/2/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginVC: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTextFieldDelegate()
        setupTapGestureRecognizer()
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        login()
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        goToRegisterVC()
    }
    
}

extension LoginVC {
    
    private func setupUI() {
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        emailTextField.leftViewMode = .always
        
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        passwordTextField.leftViewMode = .always
        
        loginButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
    }
    
    private func setupTapGestureRecognizer() {
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(viewTap)
    }
    
    @objc private func viewTapped() {
        view.endEditing(true)
    }
    
    private func login() {
        view.endEditing(true)
        
        guard let email = emailTextField.text, !email.isEmpty else {
            AlertManager.shared.presentInfoAlert(title: "Login Failed", message: "Email cannot be empty!", viewController: self)
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            AlertManager.shared.presentInfoAlert(title: "Login Failed", message: "Password cannot be empty!", viewController: self)
            return
        }
        
        firebaseSignIn(email: email, password: password)
    }
    
    private func firebaseSignIn(email: String, password: String) {
        spinner.show(in: view)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { authResult, error in
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
            
            if let error = error {
                AlertManager.shared.presentErrorAlert(file: #file, function: #function, line: #line, title: "Login Error", error: "\(error)", viewController: self)
            }
            else {
                guard let authResult = authResult else {
                    AlertManager.shared.presentErrorAlert(file: #file, function: #function, line: #line, title: "Login Error", error: "authResult not found", viewController: self)
                    return
                }
                
                guard let userID = Auth.auth().currentUser?.uid else {
                    AlertManager.shared.presentErrorAlert(file: #file, function: #function, line: #line, title: "Login Error", error: "userID not found", viewController: self)
                    return
                }
                
                UserDefaults.standard.set(userID, forKey: "userID")
                
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    private func goToRegisterVC() {
        let storyboard = UIStoryboard(name: "Register", bundle: nil)
        
        let registerVC = storyboard.instantiateViewController(identifier: "Register") as! RegisterVC
        
        registerVC.modalPresentationStyle = .fullScreen
        present(registerVC, animated: true, completion: nil)
    }
    
}

extension LoginVC: UITextFieldDelegate {
    
    private func setupTextFieldDelegate() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            login()
        }
        else {
            AlertManager.shared.presentErrorAlert(file: #file, function: #function, line: #line, title: "Text Field Error", error: "Unknown text field return", viewController: self)
        }
        
        return true
    }
    
}
