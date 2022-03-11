//
//  NewMessageChooseUserVC.swift
//  Firebase Chat
//
//  Created by Admin on 2/3/22.
//

import UIKit

class NewMessageChooseUserVC: UIViewController {

    public var newMessageVC = NewMessageVC()
    private var users: [User] = []
    private var viewTap: UITapGestureRecognizer? = nil
    
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var searchUsersTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addViewTapGestureRecognizer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeViewTapGestureRecognizer()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension NewMessageChooseUserVC {
    
    private func addViewTapGestureRecognizer() {
        removeViewTapGestureRecognizer()
        
        viewTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        
        viewTap?.cancelsTouchesInView = false
        
        if let viewTap = viewTap {
            view.addGestureRecognizer(viewTap)
        }
    }
    
    private func removeViewTapGestureRecognizer() {
        if let viewTap = viewTap {
            view.removeGestureRecognizer(viewTap)
            self.viewTap = nil
        }
    }
    
    @objc private func viewTapped() {
        view.endEditing(true)
    }
    
}

extension NewMessageChooseUserVC: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        usersTableView.delegate = self
        usersTableView.dataSource = self
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = usersTableView.dequeueReusableCell(withIdentifier: "cell") as! NewMessageChooseUserTableViewCell
        
        let userName = users[indexPath.row].name
        let userID = users[indexPath.row].userID
        
        cell.setupCell(userName: userName, userID: userID)
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        usersTableView.deselectRow(at: indexPath, animated: true)
        newMessageVC.selectedUser = users[indexPath.row]
        newMessageVC.setupSelectedUser()
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension NewMessageChooseUserVC: UITextFieldDelegate {
    
    private func setupTextField() {
        searchUsersTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        guard var name = searchUsersTextField.text, name != "" else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - text is empty")
            return false
        }
        
        guard let userID = UserDefaults.standard.value(forKey: "userID") as? String else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: userID not found")
            return false
        }
        
        name = name.lowercased()
        
        FirestoreManager.shared.searchForUsers(userID: userID, name: name) { searchedUsers in
            print("searchedUsers: \(searchedUsers)")
            
            if let searchedUsers = searchedUsers {
                self.users = searchedUsers
                self.usersTableView.reloadData()
            }
            else {
                self.users = []
                self.usersTableView.reloadData()
            }
        }
        
        return false
    }
    
}
