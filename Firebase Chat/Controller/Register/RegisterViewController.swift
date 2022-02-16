//
//  RegisterViewController.swift
//  Firebase Chat
//
//  Created by Admin on 15/12/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "default_profile_picture")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let firstNameField: UITextField = {
       let firstName = UITextField()
        // alwan current task start
        firstName.textColor = .black
        // alwan current task end
        firstName.autocapitalizationType = UITextAutocapitalizationType.words
        firstName.autocorrectionType = .no
        firstName.returnKeyType = .continue
        firstName.layer.cornerRadius = 12
        firstName.layer.borderWidth = 1
        firstName.layer.borderColor = UIColor.lightGray.cgColor
        firstName.placeholder = "First Name"
        firstName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        firstName.leftViewMode = .always
        firstName.backgroundColor = .white
        return firstName
    }()
    
    private let lastNameField: UITextField = {
       let lastName = UITextField()
        // alwan current task start
        lastName.textColor = .black
        // alwan current task end
        lastName.autocapitalizationType = UITextAutocapitalizationType.words
        lastName.autocorrectionType = .no
        lastName.returnKeyType = .continue
        lastName.layer.cornerRadius = 12
        lastName.layer.borderWidth = 1
        lastName.layer.borderColor = UIColor.lightGray.cgColor
        lastName.placeholder = "Last Name"
        lastName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        lastName.leftViewMode = .always
        lastName.backgroundColor = .white
        return lastName
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
    
    private let registerButton: UIButton = {
        let registerButton = UIButton(type: .system)
        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = .systemGreen
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 12
        registerButton.layer.masksToBounds = true
        registerButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return registerButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(viewEndEditing))
        view.addGestureRecognizer(viewTap)
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(changeProfilePicture))
        imageView.addGestureRecognizer(imageTap)
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 3
        
        imageView.frame = CGRect(x: (view.width - size) / 2, y: 20, width: size, height: size)
        
        imageView.layer.cornerRadius = imageView.width / 2
        
        firstNameField.frame = CGRect(x: 30, y: imageView.bottom + 10, width: scrollView.width - 60, height: 52)
        
        lastNameField.frame = CGRect(x: 30, y: firstNameField.bottom + 10, width: scrollView.width - 60, height: 52)
        
        emailField.frame = CGRect(x: 30, y: lastNameField.bottom + 10, width: scrollView.width - 60, height: 52)
        
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 10, width: scrollView.width - 60, height: 52)
        
        registerButton.frame = CGRect(x: 30, y: passwordField.bottom + 10, width: scrollView.width - 60, height: 52)
    }
    
    @objc private func registerButtonTapped() {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let email = emailField.text, let password = passwordField.text, !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self]  authResult, error in
            
            guard let strongSelf = self else { return }
            
            if let error = error {
                
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss()
                }
                
                let errorAlertVC = UIAlertController(title: "Error Creating User", message: (error.localizedDescription), preferredStyle: .alert)
                errorAlertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                strongSelf.present(errorAlertVC, animated: true, completion: nil)
            }
            else {
                guard authResult != nil
                else {
                    let errorAlertVC = UIAlertController(title: "Error Creating User", message: "authResult not found.", preferredStyle: .alert)
                    errorAlertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    strongSelf.present(errorAlertVC, animated: true, completion: nil)
                    return
                }
                
                guard let uid = authResult?.user.uid
                else {
                    let errorAlertVC = UIAlertController(title: "Error Creating User", message: "uid not found.", preferredStyle: .alert)
                    errorAlertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    strongSelf.present(errorAlertVC, animated: true, completion: nil)
                    return
                }
                
                guard let email = authResult?.user.email
                else {
                    let errorAlertVC = UIAlertController(title: "Error Creating User", message: "email not found.", preferredStyle: .alert)
                    errorAlertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    strongSelf.present(errorAlertVC, animated: true, completion: nil)
                    return
                }
                
                guard let profilePicture = strongSelf.imageView.image
                else {
                    let errorAlertVC = UIAlertController(title: "Error Creating User", message: "profilePicture not found.", preferredStyle: .alert)
                    errorAlertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    strongSelf.present(errorAlertVC, animated: true, completion: nil)
                    return
                }
                
                guard let profilePictureData = profilePicture.pngData()
                else {
                    let errorAlertVC = UIAlertController(title: "Error Creating User", message: "profilePictureData not found.", preferredStyle: .alert)
                    errorAlertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    strongSelf.present(errorAlertVC, animated: true, completion: nil)
                    return
                }
                
                print("profilePictureData = \(profilePictureData)")
                
                let profilePictureNSData = profilePictureData as NSData
                
                print("profilePictureNSData = \(profilePictureNSData)")
                
                let profilePictureString = profilePictureNSData.base64EncodedString(options: .lineLength64Characters)
                
                print("profilePictureString = \(profilePictureString)")
                
                let chatUser = ChatAppUser(uid: uid, firstName: firstName, lastName: lastName, email: email, profilePicture: profilePictureString)
                
                FirestoreManager.shared.addUser(uid: uid, email: email, name: firstName, completion: { success in
                    
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss()
                    }
                    
                    if success {
                        let successAlertVC = UIAlertController(title: "Register Success", message: "Success creating user!", preferredStyle: .alert)
                        successAlertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            strongSelf.navigationController?.popViewController(animated: true)
                        }))
                        strongSelf.present(successAlertVC, animated: true, completion: nil)
                    }
                    else {
                        let successAlertVC = UIAlertController(title: "Register Failed", message: "Failed creating user!", preferredStyle: .alert)
                        successAlertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            strongSelf.navigationController?.popViewController(animated: true)
                        }))
                        strongSelf.present(successAlertVC, animated: true, completion: nil)
                    }
                    
                })
                
                //
//                DatabaseManager.shared.insertUser(user: chatUser, completion: { success in
//
//                    DispatchQueue.main.async {
//                        strongSelf.spinner.dismiss()
//                    }
//
//                    if success {
//                        let successAlertVC = UIAlertController(title: "Register Success", message: "Success creating user!", preferredStyle: .alert)
//                        successAlertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
//                            strongSelf.navigationController?.popViewController(animated: true)
//                        }))
//                        strongSelf.present(successAlertVC, animated: true, completion: nil)
//                    }
//                    else {
//                        let successAlertVC = UIAlertController(title: "Register Failed", message: "Failed creating user!", preferredStyle: .alert)
//                        successAlertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
//                            strongSelf.navigationController?.popViewController(animated: true)
//                        }))
//                        strongSelf.present(successAlertVC, animated: true, completion: nil)
//                    }
//                })
                //
                
            }
            
        })
        
    }
    
    func alertUserLoginError(message: String = "Please enter all information to register.") {
        let alert = UIAlertController(title: "Register Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    @objc private func viewEndEditing(){
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        view.endEditing(true)
    }
    
    @objc private func changeProfilePicture() {
        presentPhotoActionSheet()
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // firstNameField
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        }
        // lastNameField
        else if textField == lastNameField {
            emailField.becomeFirstResponder()
        }
        // emailField
        else if textField == emailField {
        passwordField.becomeFirstResponder()
        }
        // passwordField
        else {
            viewEndEditing()
            registerButtonTapped()
        }
        
        return true
        
    }
    
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a profile picture?", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take a Picture", style: .default) { [weak self] _ in
            self?.presentCamera()
        }
        actionSheet.addAction(cameraAction)
        
        let addPictureAction = UIAlertAction(title: "Choose a Picture", style: .default) { [weak self] _ in
            self?.presentPhotoPicker()
        }
        actionSheet.addAction(addPictureAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func presentCamera() {
        let pickerVC = UIImagePickerController()
        pickerVC.sourceType = .camera
        pickerVC.delegate = self
        present(pickerVC, animated: true, completion: nil)
    }
    
    func presentPhotoPicker() {
        let pickerVC = UIImagePickerController()
        pickerVC.sourceType = .photoLibrary
        pickerVC.delegate = self
        pickerVC.allowsEditing = true
        present(pickerVC, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage]
        else {
            print("Selected image not found.")
            return
        }
        
        imageView.image = selectedImage as? UIImage
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
