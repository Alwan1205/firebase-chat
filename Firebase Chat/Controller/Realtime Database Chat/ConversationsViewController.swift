//
//  ViewController.swift
//  Firebase Chat
//
//  Created by Admin on 15/12/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

struct Conversation {
    let id: String
    let name: String
    let otherUserUID: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: Date
    let text: String
    let isRead: Bool
}

class ConversationsViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversation]()
    
    private let tableView: UITableView = {
       let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return tableView
    }()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // alwan test start
//        FirestoreManager.shared.addUser(firstName: "Ada", middleName: nil, lastName: "Lovelace", born: 1815, completion: {
//
//            FirestoreManager.shared.addUser(firstName: "Alan", middleName: "Mathison", lastName: "Turing", born: 1912, completion: {
//
//            })
//        })
        
//        FirestoreManager.shared.testReadChatRooms(completion: {
//            FirestoreManager.shared.testReadChatRoom(completion: {
//                FirestoreManager.shared.testReadChatRoomMessages(completion: {
//                    FirestoreManager.shared.testReadChatRoomMessage()
//                })
//            })
//        })
        // alwan test end
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        setupTableView()
        fetchConversations()
        startListeningForConversations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let loginVC = LoginViewController()
            let navVC = UINavigationController(rootViewController: loginVC)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: false, completion: nil)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchConversations() {
        tableView.isHidden = false
    }
    
    private func startListeningForConversations() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String
        else {
            return
        }
        
        print("starting conversation fetch...")
        
        DatabaseManager.shared.getAllConversations(for: uid, completion: { [weak self] result in
            guard let strongSelf = self
            else {
                return
            }
            
            switch result {
            case .success(let conversations):
                print("successfully got conversation models")
                
                guard !conversations.isEmpty
                else {
                    return
                }
                
                strongSelf.conversations = conversations
                
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
            case .failure(let error):
                print("failure to get conversations: \(error)")
            }
        })
    }
    
    @objc private func didTapComposeButton() {
        let newConversationVC = NewConversationViewController()
        
        newConversationVC.completion = { [weak self] result in
            guard let strongSelf = self
            else {
                return
            }
            
            print("result = \(result)")
            strongSelf.createNewConversation(result: result)
        }
        
        let navVC = UINavigationController(rootViewController: newConversationVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true, completion: nil)
    }
    
    private func createNewConversation(result: [String: String]) {
        guard let name = result["name"], let uid = result["uid"]
        else {
            return
        }
        
        let chatVC = ChatViewController(with: uid)
        chatVC.title = name
        chatVC.isNewConversation = true
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(model: model)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]

        let chatVC = ChatViewController(with: model.otherUserUID)
        chatVC.title = model.name
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

}
