//
//  SettingsVC.swift
//  Firebase Chat
//
//  Created by Admin on 2/3/22.
//

import FirebaseAuth

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        logout()
    }
    
}

extension SettingsVC {
    
    // alwan comment: di sini harusnya remove chat listener
    private func logout() {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            
            UserDefaults.standard.removeObject(forKey: "userID")
            
            goToLogin()
            
            self.tabBarController?.selectedIndex = 0
        }
        catch let error as NSError {
            AlertManager.shared.presentErrorAlert(file: #file, function: #function, line: #line, title: "Log Out Error", error: "\(error)", viewController: self)
        }
    }
    
    private func goToLogin() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        
        let loginVC = storyboard.instantiateViewController(withIdentifier: "Login") as! LoginVC
        
        loginVC.modalPresentationStyle = .fullScreen
        
        self.present(loginVC, animated: true, completion: nil)
    }
    
}
