//
//  FirestoreChatMessagesViewController.swift
//  Firebase Chat
//
//  Created by Admin on 17/1/22.
//

import UIKit

// initializers & life cycle & IBAction
class FirestoreChatMessagesViewController: UIViewController {

    @IBOutlet weak var chatMessagesTableView: UITableView!
    @IBOutlet weak var chatNameLabel: UILabel!
    @IBOutlet weak var chatTextField: UITextField!
    
    @IBOutlet weak var chatViewBottomConstraint: NSLayoutConstraint!
    
    var userUID = String()
    var chatRoom: ChatRoom?
    
    var viewTap: UITapGestureRecognizer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // alwan current task
        // alwan test start
        print("\nFirestoreChatMessagesViewController - viewDidLoad - chatRoom.messages:")
        if let messages = chatRoom?.messages {
            for message in messages {
                print(message)
            }
        }
        print("\n")
        // alwan test end
        
        chatNameLabel.text = chatRoom?.chatName ?? ""
        chatMessagesTableView.delegate = self
        chatMessagesTableView.dataSource = self
        
        chatTextField.delegate = self
        
        readMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addKeyboardObservers()
        addViewTapGestureRecognizer()
        
        Chat.firestoreChatMessagesVC = self
        
        tableViewScrollToBottom()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeKeyboardObservers()
        removeViewTapGestureRecognizer()
        
        Chat.firestoreChatMessagesVC = nil
    }
    
    deinit {
        
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // kasih limit max character-nya
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let text = chatTextField.text, text != ""
        else {
            print("text not found")
            return
        }
        
        let timestamp = TimestampManager.shared.getCurrentTimestamp()
        let type = "text"
        
        chatTextField.text = ""
        dismissKeyboard()
        
        guard let roomID = chatRoom?.roomID else {
            print("roomID not found")
            return
        }
        
        sendChatMessage(userUID: userUID, roomID: roomID, timestamp: timestamp, type: type, content: text)
    }
    
}

// firestore
extension FirestoreChatMessagesViewController {
    
    // fetch data-nya di firestorechatviewcontroller
    func addChatMessagesListener() {
//        FirestoreManager.shared.addChatMessagesListener(roomID: chatRoomID, firestoreChatMessagesViewController: self)
    }
    
    // remove listener-nya di firestorevhatviewcontroller
    func removeChatMessagesListener() {
//        FirestoreManager.shared.removeChatMessagesListener()
    }
    
    func sendChatMessage(userUID: String, roomID: String, timestamp: String, type: String, content: String) {
        FirestoreManager.shared.sendChatMessage(userUID: userUID, room: roomID, timestamp: timestamp, type: type, content: content)
        
        FirestoreManager.shared.updateChatRoomLastMessage(userUID: userUID, roomID: roomID, timestamp: timestamp, lastMessage: content)
        
        FirestoreManager.shared.sendPushNotification(userUID: userUID, roomID: roomID, body: content)
        
        // alwan current task
        // alwan test start
//        let chatMessage = ChatMessage(messageID: "test_message", roomID: roomID, senderID: userUID, timestamp: timestamp, type: type, readBy: [userUID], content: content, status: "Pending")
//
////        FirestoreManager.shared.saveChatMessageToCoreData(chatMessage: chatMessage)
//        print("sendChatMessage - chatMessage: \(chatMessage)")
//        CoreDataManager.shared.saveChatMessageToCoreData(chatMessage: chatMessage)
        // alwan test end
    }
    
//    func initialRead() {
//        if isRead == false {
//            FirestoreManager.shared.updateChatRoomRead(userUID: userUID)
//        }
//    }
    
    func readMessages() {
        DispatchQueue.main.async {
            // kirim read ke chat messages
            guard let chatRoom = self.chatRoom else {
                print("chatRoom not found")
                return
            }
            
            print("readMessages - chatRoom: \(chatRoom)")
            
            guard let messages = chatRoom.messages else {
                print("messages not found")
                return
            }
            
            var index = 0
            for message in messages {
                var isRead = false
                for reader in message.readBy {
                    if reader == self.userUID {
                        isRead = true
                    }
                }
                
                if isRead == false {
                    FirestoreManager.shared.updateChatMessageRead(userUID: self.userUID, messageID: message.messageID)
                    
                    if index == messages.count - 1 {
                        // kirim read ke chat room
                        FirestoreManager.shared.updateChatRoomRead(userUID: self.userUID, roomID: chatRoom.roomID)
                    }
                }
                
                index += 1
            }
        }
    }
    
}

// observer & listener
extension FirestoreChatMessagesViewController {
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addViewTapGestureRecognizer() {
        if let viewTap = viewTap {
            view.removeGestureRecognizer(viewTap)
        }
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        
        view.addGestureRecognizer(viewTap)
    }
    
    func removeViewTapGestureRecognizer() {
        if let viewTap = viewTap {
            view.removeGestureRecognizer(viewTap)
        }
    }
    
}

// text field keyboard editing
extension FirestoreChatMessagesViewController: UITextFieldDelegate {
    
    @objc func viewTapped() {
        dismissKeyboard()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            print("keyboardSize not found")
            return
        }
        
        if chatViewBottomConstraint.constant == 0 {
            chatViewBottomConstraint.constant += keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide() {
        if chatViewBottomConstraint.constant != 0 {
            chatViewBottomConstraint.constant = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }
    
}

// table view
extension FirestoreChatMessagesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRoom?.messages?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatMessagesTableView.dequeueReusableCell(withIdentifier: "cell") as! FirestoreChatMessagesTableViewCell
        
        let senderUID = chatRoom?.messages?[indexPath.row].senderID ?? ""//chatMessages[indexPath.row].senderID
        
        // alwan current task start
        // alwan comment start
//        let text = chatRoom?.messages?[indexPath.row].text ?? ""//chatMessages[indexPath.row].text ?? ""
        // alwan comment end
        
        // alwan test start
        let type = chatRoom?.messages?[indexPath.row].type ?? "empty"
        
        var content = ""
        if type == "text" {
            content = chatRoom?.messages?[indexPath.row].content ?? ""
        }
        else if type == "image" {
            content = "*image type*"
        }
        else if type == "video" {
            content = "*video type*"
        }
        else if type == "empty" {
            print("type is empty")
        }
        else {
            print("unknown type")
        }
        // alwan test end
        // alwan current task end
        
        let timestamp = chatRoom?.messages?[indexPath.row].timestamp ?? ""//chatMessages[indexPath.row].timestamp
        
        let dateString: String = TimestampManager.shared.convertTimestampToDateString(timestamp: timestamp) ?? ""
        
        let isGroup = chatRoom?.isGroup ?? false
        
        let chatName = chatRoom?.chatName ?? ""
        
        let participantsNames = chatRoom?.participantsNames ?? [:]
        
        // alwan current task
        // alwan comment start
//        cell.setupChatMessage(userUID: userUID, senderUID: senderUID, participantsNames: participantsNames, text: text, dateString: dateString, isGroup: isGroup, chatName: chatName)
        // alwan comment end
        
        // alwan current task
        // alwan test start
        
        cell.setupChatMessage(userUID: userUID, senderUID: senderUID, participantsNames: participantsNames, content: content, dateString: dateString, isGroup: isGroup, chatName: chatName)
        // alwan test end
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatMessagesTableView.deselectRow(at: indexPath, animated: false)
    }
    
    // alwan current task
    // abis di scroll ke paling bawah, ada function yang reload table view-nya lagi jadi scroll-nya ke reset
    func tableViewScrollToBottom() {
        DispatchQueue.main.async {
            guard let messagesCount = self.chatRoom?.messages?.count else {
                print("messagesCount not found")
                return
            }
            
            print("tableViewScroll To Bottom - messagesCount = \(messagesCount)")
            
            if messagesCount > 0 {
                let indexPath = IndexPath(row: messagesCount - 1, section: 0)
                self.chatMessagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                print("scrollToRow: \(indexPath)")
            }
        }
    }
    
//    func reload(tableView: UITableView) {
//
//        let contentOffset = chatMessagesTableView.contentOffset
//        chatMessagesTableView.reloadData()
//        chatMessagesTableView.layoutIfNeeded()
//        chatMessagesTableView.setContentOffset(contentOffset, animated: false)
//
//    }
    
}
