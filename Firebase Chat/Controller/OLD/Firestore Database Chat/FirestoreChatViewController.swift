//
//  FirestoreChatViewController.swift
//  Firebase Chat
//
//  Created by Admin on 11/1/22.
//

import UIKit

class FirestoreChatViewController: UIViewController {

    @IBOutlet weak var chatRoomsTableView: UITableView!
    
    // alwan test start
//    let firestoreManager = FirestoreManager() // buat ref untuk firestoreManager sehingga bisa menyimpan ref untuk listener supaya dapat di remove saat tidak digunakan (perlu di test dulu apakah tanpa ref firestoreManager remove listener-nya sudah berfungsi atau tidak)
    // alwan test end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // alwan current task
        // alwan test start
//        CoreDataManager.shared.deleteAllCoreData(entity: "CoreDataChatRoom")
//
//        CoreDataManager.shared.deleteAllCoreData(entity: "CoreDataChatMessage")
        // alwan test end
        
        chatRoomsTableView.delegate = self
        chatRoomsTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard UserOld.userUID == "" else {
            print("FirestoreChatViewController - viewDidLoad: User.userUID already exists")
            return
        }
        
        UserOld.userUID = UserDefaults.standard.value(forKey: "uid") as? String
        
        guard UserOld.userUID != "" && UserOld.userUID != nil else {
            print("FirestoreChatViewController - viewDidLoad - User.useruID: \(UserOld.userUID)")
            
            let loginVC = LoginViewController()
            let navVC = UINavigationController(rootViewController: loginVC)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: false, completion: nil)
            
            return
        }
        
        print("User.userUID = \(UserOld.userUID)")
        
        guard let userUID = UserOld.userUID else {
            print("userUID not found")
            return
        }
        
        FirestoreManager.shared.addChatRoomsListenerOLD(userUID: userUID, firestoreChatViewController: self, completion: {
            
            FirestoreManager.shared.addChatMessagesListenerOLD(userUID: userUID)
            
        })
        
        guard let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") as? String else {
            print("fcmToken not found")
            return
        }
        
        FirestoreManager.shared.setDeviceToken(userUID: userUID, fcmToken: fcmToken)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    deinit {
        // Ga tau kapan dipanggilnya
        FirestoreManager.shared.removeChatRoomsListener()
        FirestoreManager.shared.removeChatMessagesListener()
    }

}

extension FirestoreChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return chatRooms.count
        return Chat.rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FirestoreChatRoomsTableViewCell
        
        // suka error out of index
        
        print("\n")
        print("Chat Rooms - cellForRowAt")
        print("Chat.rooms.count = \(Chat.rooms.count)")
        print("Chat.rooms = \(Chat.rooms)")
        print("\n")
        
        let chatName = Chat.rooms[indexPath.row].chatName
        
        let lastMessageOptional = Chat.rooms[indexPath.row].lastMessage
        
        var lastMessage = String()
        
        if let lastMessageUnwrapped = lastMessageOptional {
            lastMessage = lastMessageUnwrapped
        }
        else {
            lastMessage = ""
        }
        
        let timestamp = Chat.rooms[indexPath.row].timestamp
        
        let dateString = TimestampManager.shared.convertTimestampToDateString(timestamp: timestamp) ?? ""
        
        let readBy = Chat.rooms[indexPath.row].readBy
        var isRead = false
        
        if let readBy = readBy {
            for reader in readBy {
                if UserOld.userUID == reader {
                    isRead = true
                }
            }
        }
        
        cell.setupChatRoom(picture: nil, chatName: chatName, lastMessage: lastMessage, dateString: dateString, isRead: isRead)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatRoomsTableView.deselectRow(at: indexPath, animated: false)
        
        guard let userUID = UserOld.userUID
        else {
            print("userUID not found")
            return
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: "FirestoreChatMessages", bundle: nil)
        
        let firestoreChatMessagesVC = storyboard.instantiateViewController(identifier: "FirestoreChatMessages") as! FirestoreChatMessagesViewController
        
        print("chatRoomID = \(Chat.rooms[indexPath.row].roomID)")
        print("messages = \(Chat.rooms[indexPath.row].messages)")
        firestoreChatMessagesVC.userUID = userUID
        firestoreChatMessagesVC.chatRoom = Chat.rooms[indexPath.row]
        print("firestoreChatMessagesVC.chatRoom = \(firestoreChatMessagesVC.chatRoom)")
        
        Chat.firestoreChatMessagesVC = firestoreChatMessagesVC
        
        firestoreChatMessagesVC.modalPresentationStyle = .fullScreen
        self.present(firestoreChatMessagesVC, animated: false, completion: nil)
    }
    
}
