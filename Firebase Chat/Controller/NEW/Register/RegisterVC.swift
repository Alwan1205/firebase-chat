//
//  RegisterVC.swift
//  Firebase Chat
//
//  Created by Admin on 17/2/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterVC: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFieldDelegate()
        setupTapGestureRecognizer()
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        register()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension RegisterVC {
    
    private func setupUI() {
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        nameTextField.leftViewMode = .always
        
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        emailTextField.leftViewMode = .always
        
        confirmEmailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        confirmEmailTextField.leftViewMode = .always
        
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        passwordTextField.leftViewMode = .always
        
        registerButton.layer.cornerRadius = 10
        registerButton.layer.masksToBounds = true
    }
    
    private func setupTapGestureRecognizer() {
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(viewTap)
    }
    
    @objc private func viewTapped() {
        view.endEditing(true)
    }
    
    private func register() {
        view.endEditing(true)
        
        guard let name = nameTextField.text, !name.isEmpty else {
            AlertManager.shared.presentInfoAlert(title: "Register Failed", message: "Name cannot be empty!", viewController: self)
            return
        }
        
        guard name.count >= 6 else {
            AlertManager.shared.presentInfoAlert(title: "Register Failed", message: "Name must be at least 6 characters!", viewController: self)
            return
        }
        
        guard name.count < 20 else {
            AlertManager.shared.presentInfoAlert(title: "Register Failed", message: "Name must be less than 20 characters!", viewController: self)
            return
        }
        
        var startsWithSpace = false
        for index in name.indices {
            if name[index] == " " {
                startsWithSpace = true
                break
            }
            else {
                break
            }
        }
        
        guard startsWithSpace == false else {
            AlertManager.shared.presentInfoAlert(title: "Register Failed", message: "Name cannot starts with space!", viewController: self)
            return
        }
        
        let noMultipleSpaces = noMultipleSpaces(string: name)
        
        guard noMultipleSpaces else {
            AlertManager.shared.presentInfoAlert(title: "Register Failed", message: "Name cannot contain multiple spaces!", viewController: self)
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            AlertManager.shared.presentInfoAlert(title: "Register Failed", message: "Email cannot be empty!", viewController: self)
            return
        }
        
        guard isValidEmail(email: email) else {
            AlertManager.shared.presentInfoAlert(title: "Register Failed", message: "Email must be a valid email address!", viewController: self)
            return
        }
        
        guard let confirmEmail = confirmEmailTextField.text, !confirmEmail.isEmpty else {
            AlertManager.shared.presentInfoAlert(title: "Register Failed", message: "Confirm email cannot be empty!", viewController: self)
            return
        }
        
        guard confirmEmail == email else {
            AlertManager.shared.presentInfoAlert(title: "Register Failed", message: "Confirm email must be the same with email!", viewController: self)
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            AlertManager.shared.presentInfoAlert(title: "Register Failed", message: "Password cannot be empty!", viewController: self)
            return
        }
        
        guard password.count >= 8 else {
            AlertManager.shared.presentInfoAlert(title: "Register Failed", message: "Password must be at least 8 characters!", viewController: self)
            return
        }
        
        guard password.count < 20 else {
            AlertManager.shared.presentInfoAlert(title: "Register Failed", message: "Password must be less than 20 characters!", viewController: self)
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            AlertManager.shared.presentInfoAlert(title: "Register Failed", message: "Confirm password cannot be empty!", viewController: self)
            return
        }
        
        guard confirmPassword == password else {
            AlertManager.shared.presentInfoAlert(title: "Register Failed", message: "Confirm password must be the same with password!", viewController: self)
            return
        }
        
        let nameAsArray = getNameAsArray(name: name)
        
        firebaseCreateUser(name: name, email: email, password: password, completion: { userID in
            
            guard let userID = userID else { return }
            
            FirestoreManager.shared.addUser(userID: userID, name: name, nameAsArray: nameAsArray, email: email, viewController: self, completion: {
                
                DispatchQueue.main.async {
                    self.spinner.dismiss()
                }
                
            })
            
        })
        
    }
    
    private func isValidEmail(email: String) -> Bool {
        let firstPart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        let serverPart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let emailRegex = firstPart + "@" + serverPart + "[A-Za-z]{2,8}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: email)
    }
    
    private func firebaseCreateUser(name: String, email: String, password: String, completion: @escaping (String?) -> Void) {
        spinner.show(in: view)
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.spinner.dismiss()
                }
                
                AlertManager.shared.presentErrorAlert(file: #file, function: #function, line: #line, title: "Register Error", error: "\(error)", viewController: self)
                
                completion(nil)
            }
            else {
                guard let authResult = authResult else {
                    AlertManager.shared.presentErrorAlert(file: #file, function: #function, line: #line, title: "Register Error", error: "authResult not found", viewController: self)
                    completion(nil)
                    return
                }
                
                let userID = authResult.user.uid
                
                completion(userID)
            }
            
        })
    }
    
    private func noMultipleSpaces(string: String) -> Bool {
        var previousIsSpace = false
        for index in string.indices {
            if string[index] == " " {
                if previousIsSpace {
                    return false
                }
                else {
                    previousIsSpace = true
                }
            }
        }
        
        return true
    }
    
    private func getNameAsArray(name: String) -> [String] {
        var nameAsArray: [String] = []
        var string = ""
        
        for index in name.indices {
            if name[index] == " " {
                nameAsArray.append(string)
                string = ""
            }
            else {
                string.append(name[index])
            }
        }
        
        for index in nameAsArray.indices {
            nameAsArray[index] = nameAsArray[index].lowercased()
        }
        
        return nameAsArray
    }
    
}

extension RegisterVC: UITextFieldDelegate {
    
    private func setupTextFieldDelegate() {
        nameTextField.delegate = self
        emailTextField.delegate = self
        confirmEmailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            emailTextField.becomeFirstResponder()
        }
        else if textField == emailTextField {
            confirmEmailTextField.becomeFirstResponder()
        }
        else if textField == confirmEmailTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        }
        else if textField == confirmPasswordTextField {
            register()
        }
        else {
            AlertManager.shared.presentErrorAlert(file: #file, function: #function, line: #line, title: "Text Field Error", error: "Unknown text field return", viewController: self)
        }
        
        return true
    }
    
}
