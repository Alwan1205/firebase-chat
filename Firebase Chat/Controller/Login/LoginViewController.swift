//
//  LoginViewController.swift
//  Firebase Chat
//
//  Created by Admin on 15/12/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
       let emailField = UITextField()
        // alwan current task start
        emailField.textColor = .black
        // alwan current task end
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.returnKeyType = .continue
        emailField.layer.cornerRadius = 12
        emailField.layer.borderWidth = 1
        emailField.layer.borderColor = UIColor.lightGray.cgColor
        emailField.placeholder = "Email Address"
        emailField.keyboardType = .emailAddress
        emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        emailField.leftViewMode = .always
        emailField.backgroundColor = .white
        return emailField
    }()
    
    private let passwordField: UITextField = {
       let passwordField = UITextField()
        // alwan current task start
        passwordField.textColor = .black
        // alwan current task end
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.returnKeyType = .done
        passwordField.layer.cornerRadius = 12
        passwordField.layer.borderWidth = 1
        passwordField.layer.borderColor = UIColor.lightGray.cgColor
        passwordField.placeholder = "Password"
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        passwordField.leftViewMode = .always
        passwordField.backgroundColor = .white
        passwordField.isSecureTextEntry = true
        return passwordField
    }()
    
    private let loginButton: UIButton = {
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Log In", for: .normal)
        loginButton.backgroundColor = .link
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 12
        loginButton.layer.masksToBounds = true
        loginButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return loginButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(registerTapped))
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(viewEndEditing))
        view.addGestureRecognizer(viewTap)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: (view.width - size) / 2, y: 20, width: size, height: size)
        
        emailField.frame = CGRect(x: 30, y: imageView.bottom + 10, width: scrollView.width - 60, height: 52)
        
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 10, width: scrollView.width - 60, height: 52)
        
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom + 10, width: scrollView.width - 60, height: 52)
    }
    
    @objc private func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // firebase log in
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult
            else {
                print("Error Signing In: authResult not found.")
                let errorVC = UIAlertController(title: "Error Signing In", message: "authResult not found", preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                strongSelf.present(errorVC, animated: true, completion: nil)
                
                return
            }
            
            if let error = error {
                print("Error Signing In: \(error.localizedDescription)")
                
                let errorVC = UIAlertController(title: "Error Signing In", message: (error.localizedDescription), preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                strongSelf.present(errorVC, animated: true, completion: nil)
            }
            else {
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
            
            // alwan comment: penyimpanan uid di userdefaults
            // alwan current task
            // fix login-nya
            guard let uid = Auth.auth().currentUser?.uid else { return }
            UserDefaults.standard.set(uid, forKey: "uid")
            User.userUID = ""
        })
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Login Failed", message: "Please enter all information to log in.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc private func registerTapped() {
        let registerVC = RegisterViewController()
        registerVC.title = "Create Account"
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc private func viewEndEditing() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        view.endEditing(true)
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // emailField
        if textField == emailField {
        passwordField.becomeFirstResponder()
        }
        // passwordField
        else {
            loginButtonTapped()
        }
        
        return true
        
    }
    
}
