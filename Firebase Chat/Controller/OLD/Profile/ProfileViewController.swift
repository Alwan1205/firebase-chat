//
//  ProfileViewController.swift
//  Firebase Chat
//
//  Created by Admin on 15/12/21.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var headerView = UIView()
    var imageView = UIImageView()
    
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
        
        setProfilePicture()
    }

    func createTableHeader() -> UIView? {
        
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        headerView.backgroundColor = .link
        
        imageView = UIImageView(frame: CGRect(x: (headerView.width - 150) / 2, y: 75, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width / 2
        headerView.addSubview(imageView)
        
        return headerView
    }
    
    func setProfilePicture() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String
        else {
            print("uid not found")
            return
        }
        
        DatabaseManager.shared.getProfilePicture(uid: uid, completion: { profilePictureString in
            
            if profilePictureString != "" && profilePictureString != "" {
                guard let profilePictureData: Data = Data(base64Encoded: profilePictureString, options: .ignoreUnknownCharacters)
                else {
                    print("profilePictureData not found")
                    return
                }

                let profilePicture = UIImage(data: profilePictureData)

                self.imageView.image = profilePicture
            }
            else {
                print("profilePictureString not found")
            }
            
        })
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let logoutActionSheet = UIAlertController(title: "", message: "Are you sure?", preferredStyle: .actionSheet)
        logoutActionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            
            guard let strongSelf = self else { return }
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                UserOld.userUID = ""
                UserDefaults.standard.removeObject(forKey: "uid")
                
                let loginVC = LoginViewController()
                let navVC = UINavigationController(rootViewController: loginVC)
                navVC.modalPresentationStyle = .fullScreen
                strongSelf.present(navVC, animated: false, completion: nil)
            }
            catch {
                let errorVC = UIAlertController(title: "Log Out Error", message: "Failed to log out.", preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                strongSelf.present(errorVC, animated: true, completion: nil)
            }
            
        }))
        
        logoutActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(logoutActionSheet, animated: true, completion: nil)
        
    }
    
}
