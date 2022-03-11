//
//  ChatRoomsVC.swift
//  Firebase Chat
//
//  Created by Admin on 17/2/22.
//

import UIKit
import FirebaseFirestore

// Firestore Chat Rooms
class ChatRoomsVC: UIViewController {
    
    private var userID: String? = nil
    public var chatRoomsListener: ListenerRegistration?
    public var chatMessaagesListener: ListenerRegistration?
    public var chatRooms: [ChatRoom]? = []
    public var chatMessagesVC: ChatMessagesVC? = nil
    
    @IBOutlet weak var chatRoomsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // alwan comment: isChatSetupDone-nya belum kelar
        guard Chat.isInitialSetupDone == false else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Chat.isListenerAdded is true")
            return
        }
        
        if isUserLoggedIn() {
            guard let userID = userID else {
                AlertManager.shared.presentErrorAlert(file: #file, function: #function, line: #line, title: "User Error", error: "userID not found", viewController: self)
                return
            }
            
            Chat.isInitialSetupDone = true
            addChatListener(userID: userID)
            updateFCMTokenToFirestore(userID: userID)
        }
        else {
            goToLoginVC()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    @IBAction func newMessageButtonTapped(_ sender: UIButton) {
        goToNewMessageVC()
    }
    
}

extension ChatRoomsVC {
    
    private func isUserLoggedIn() -> Bool {
        userID = UserDefaults.standard.value(forKey: "userID") as? String
        
        guard let userID = userID else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - userID not found")
            return false
        }
        
        print("File: \(#file) - Function: \(#function) - Line: \(#line) - useriD: \(userID)")
        
        return true
    }
    
    private func goToLoginVC() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        
        let loginVC = storyboard.instantiateViewController(withIdentifier: "Login") as! LoginVC
        
        loginVC.modalPresentationStyle = .fullScreen
        
        self.present(loginVC, animated: false, completion: nil)
    }
    
    // add chat listener to firestore, and save to core data
    private func addChatListener(userID: String) {
        
        // alwan comment: kalau chat message yang ada di core data ngga ada di firestore, hapus chat room id-nya di core data
        
        FirestoreManager.shared.addChatRoomsListener(userID: userID, chatRoomsVC: self, completion: {
            
            FirestoreManager.shared.addChatMessagesListener(userID: userID, chatRoomsVC: self, completion: {
                
                self.updateChatRoomsFromCoreData()
                
            })
            
        })
        
    }
    
    private func updateChatRoomsFromCoreData() {
        
        print("File: \(#file) - Function: \(#function) - Line: \(#line) - updateChatRoomsFromCoreData called")
        
        var chatRooms = CoreDataManager.shared.getAllChatRoomCoreData() ?? []
        
        var chatMessages = CoreDataManager.shared
            .getAllChatMessageCoreData() ?? []
        
        guard !chatRooms.isEmpty else {
            print("File: \(#file), function: \(#function), line: \(#line): chatRooms is empty")
            return
        }
        
        for index in chatRooms.indices {
            chatRooms[index].messages = []
        }
        
        for roomIndex in chatRooms.indices {
            for messageIndex in chatMessages.indices {
                if chatRooms[roomIndex].roomID == chatMessages[messageIndex].roomID {
                    if chatRooms[roomIndex].messages == nil {
                        // alwan xomment: nantinya date & time disimpan ke core data, jadi bisa di set saat fetch dari listener
                        // alwan comment: find date and time start
                        let timestamp = chatMessages[messageIndex].timestamp
                        
                        let dateString = TimestampManager.shared.convertTimestampToDateString(timestamp: timestamp) ?? ""
                        
                        var separatorIndex: Int?
                        
                        if !dateString.indices.isEmpty {
                            for dateStringIndex in dateString.indices {
                                if dateString[dateStringIndex] == "_" {
                                    separatorIndex = dateString.distance(from: dateString.startIndex, to: dateStringIndex)
                                }
                            }
                        }
                        
                        var date: String? = nil
                        var time: String? = nil
                        
                        if let separatorIndex = separatorIndex {
                            let prefixLength = separatorIndex
                            date = String(dateString.prefix(prefixLength))
                            
                            let suffixLength = dateString.count - (separatorIndex + 1)
                            time = String(dateString.suffix(suffixLength))
                        }
                        
                        chatMessages[messageIndex].date = date
                        chatMessages[messageIndex].time = time
                        // alwan comment: find date and time end
                        
                        chatRooms[roomIndex].messages = [chatMessages[messageIndex]]
                        
                        chatMessages[messageIndex] = ChatMessage(messageID: "", roomID: "", content: "", type: "", timestamp: "", date: nil, time: nil, sender: nil, readBy: nil, status: nil)
                    }
                    else {
                        // alwan comment: find date and time start
                        let timestamp = chatMessages[messageIndex].timestamp
                        
                        let dateString = TimestampManager.shared.convertTimestampToDateString(timestamp: timestamp) ?? ""
                        
                        var separatorIndex: Int?
                        
                        if !dateString.indices.isEmpty {
                            for dateStringIndex in dateString.indices {
                                if dateString[dateStringIndex] == "_" {
                                    separatorIndex = dateString.distance(from: dateString.startIndex, to: dateStringIndex)
                                }
                            }
                        }
                        
                        var date: String? = nil
                        var time: String? = nil
                        
                        if let separatorIndex = separatorIndex {
                            let prefixLength = separatorIndex
                            date = String(dateString.prefix(prefixLength))
                            
                            let suffixLength = dateString.count - (separatorIndex + 1)
                            time = String(dateString.suffix(suffixLength))
                        }
                        
                        chatMessages[messageIndex].date = date
                        chatMessages[messageIndex].time = time
                        // alwan comment: find date and time end
                        
                        chatRooms[roomIndex].messages?.append(chatMessages[messageIndex])
                        
                        chatMessages[messageIndex] = ChatMessage(messageID: "", roomID: "", content: "", type: "", timestamp: "", date: nil, time: nil, sender: nil, readBy: nil, status: nil)
                    }
                }
            }
        }
        
        for index in chatRooms.indices {
            if var messages = chatRooms[index].messages {
                messages.sort(by: {
                    var timestamp0 = "0"
                    var timestamp1 = "0"
                    
                    timestamp0 = $0.timestamp
                    timestamp1 = $1.timestamp
                    
                    if timestamp0 > timestamp1 {
                        return false
                    }
                    else {
                        return true
                    }
                })
                
                chatRooms[index].messages = messages
            }
        }
        
        print("ChatRoomsVC updateChatRoomsFromCoreData chatRooms: \(chatRooms)")
        
        chatRooms.sort(by: {
            var timestamp0 = "0"
            var timestamp1 = "0"

            if let messages0 = $0.messages {
                if messages0.count > 0 {
                    timestamp0 = messages0[messages0.count - 1].timestamp
                }
            }

            if let messages1 = $1.messages {
                if messages1.count > 0 {
                    timestamp1 = messages1[messages1.count - 1].timestamp
                }
            }

            if timestamp0 > timestamp1 {
                return true
            }
            else {
                return false
            }
        })
        
        self.chatRooms = chatRooms
        self.chatRoomsTableView.reloadData()
        
        if let chatMessagesVC = self.chatMessagesVC {
            for chatRoom in chatRooms {
                if chatRoom.roomID == chatMessagesVC.chatRoom?.roomID {
                    chatMessagesVC.chatRoom = chatRoom
                    chatMessagesVC.chatMessagesTableView.reloadData()
                    chatMessagesVC.tableViewScrollToBottom(animated: true)
                    chatMessagesVC.readMessages()
                    break
                }
            }
        }
        
    }
    
    // alwan comment: fcm token cuma ter-update saat awal buka app / login, belum ter-update jika fcm token berubah karena rotation
    private func updateFCMTokenToFirestore(userID: String) {
        guard let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") as? String else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: fcmToken not found")
            return
        }
        
        FirestoreManager.shared.updateFCMToken(userID: userID, fcmToken: fcmToken)
    }
    
    private func goToNewMessageVC() {
        let storyboard = UIStoryboard(name: "NewMessage", bundle: nil)
        
        let newMessageVC = storyboard.instantiateViewController(withIdentifier: "NewMessage") as! NewMessageVC
        
        newMessageVC.modalPresentationStyle = .pageSheet
        
        self.present(newMessageVC, animated: true, completion: nil)
    }
    
}

extension ChatRoomsVC: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        chatRoomsTableView.delegate = self
        chatRoomsTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ChatRoomsTableViewCell
        
        let chatName = chatRooms?[indexPath.row].chatName ?? ""
        
        let chatPicture = chatRooms?[indexPath.row].chatPicture ?? nil
        
        var lastMessageContent = ""
        
        var dateTime = ""
        
        if let messages = chatRooms?[indexPath.row].messages, messages.count > 0 {
            let lastMessage = messages[messages.count - 1]
            
            lastMessageContent = lastMessage.content
            
            let lastMessageDate = lastMessage.date
            
            let lastMessageTime = lastMessage.time
            
            if lastMessageDate == nil || lastMessageDate == "" {
                print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: lastMessageDate is empty")
            }
            else {
                if lastMessageTime == nil || lastMessageTime == "" {
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: lastMessageTime is empty")
                }
                
                let currentTimestamp = TimestampManager.shared.getCurrentTimestamp()
                
                let currentDateString = TimestampManager.shared.convertTimestampToDateString(timestamp: currentTimestamp) ?? ""
                
                var separatorIndex: Int?
                
                if !currentDateString.indices.isEmpty {
                    for dateStringIndex in currentDateString.indices {
                        if currentDateString[dateStringIndex] == "_" {
                            separatorIndex = currentDateString.distance(from: currentDateString.startIndex, to: dateStringIndex)
                        }
                    }
                }
                
                var currentDate: String? = nil
                
                if let separatorIndex = separatorIndex {
                    let prefixLength = separatorIndex
                    currentDate = String(currentDateString.prefix(prefixLength))
                }
                
                if currentDate == lastMessageDate {
                    dateTime = "Today at \(lastMessageTime ?? "")"
                }
                else {
                    dateTime = "\(lastMessageDate ?? "") at \(lastMessageTime ?? "")"
                }
            }
        }
        
        var isRead = false
        if let messages = chatRooms?[indexPath.row].messages, messages.count >= 1 {
            let lastMessage = messages[messages.count - 1]
            if let readers = lastMessage.readBy {
                for reader in readers {
                    if reader == userID {
                        isRead = true
                        break
                    }
                }
            }
            else {
                isRead = true
            }
        }
        else {
            isRead = true
        }
        
        var isGroup = false
        if let isGroupTemp = chatRooms?[indexPath.row].isGroup {
            isGroup = isGroupTemp
        }
        else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: isGroupTemp not found")
        }
        
        cell.setupChatRoom(chatName: chatName, lastMessage: lastMessageContent, dateTime: dateTime, isRead: isRead, isGroup: isGroup)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatRoomsTableView.deselectRow(at: indexPath, animated: true)
        
        guard let userID = userID else {
            AlertManager.shared.presentErrorAlert(file: #file, function: #function, line: #line, title: "User Error", error: "userID not found", viewController: self)
            return
        }
        
        guard let chatRoom = chatRooms?[indexPath.row] else {
            AlertManager.shared.presentErrorAlert(file: #file, function: #function, line: #line, title: "Chat Room Error", error: "chatRoom not found", viewController: self)
            return
        }
        
        let storyboard = UIStoryboard(name: "ChatMessages", bundle: nil)
        
        let vc = storyboard.instantiateViewController(identifier: "ChatMessages") as! ChatMessagesVC
        
        chatMessagesVC = vc
        vc.chatRoomsVC = self
        vc.userID = userID
        vc.chatRoom = chatRoom
        navigationController?.navigationBar.isTranslucent = false
        vc.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
