//
//  ChatMessagesVC.swift
//  Firebase Chat
//
//  Created by Admin on 22/2/22.
//

import UIKit

class ChatMessagesVC: UIViewController {

    public var chatRoomsVC: ChatRoomsVC? = nil
    public var userID: String? = nil
    public var chatRoom: ChatRoom? = nil
    private var viewTap: UITapGestureRecognizer? = nil
    private var willEnterForegroundObserver: NSObjectProtocol?
    
    @IBOutlet weak var chatMessagesTableView: UITableView!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var chatViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        setupTextView()
        tableViewScrollToBottom(animated: false)
        readMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addViewTapGestureRecognizer()
        addKeyboardObservers()
        addWillEnterForegroundObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeViewTapGestureRecognizer()
        removeKeyboardObservers()
        removeWillEnterForegroundObserver()
        removeChatMessagesVC()
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        sendChatMessage()
    }
    
}

extension ChatMessagesVC {
    
    private func setupView() {
        title = chatRoom?.chatName ?? ""
    }
    
    private func setupTableView() {
        chatMessagesTableView.delegate = self
        chatMessagesTableView.dataSource = self
    }
    
    private func setupTextView() {
        chatTextView.delegate = self
        chatTextView.layer.borderWidth = 1
        chatTextView.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: keyboardSize not found")
            return
        }
        
        if chatViewBottomConstraint.constant == 0 {
            var bottomSafeAreaHeight: CGFloat = 0
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.windows[0]
                let safeFrame = window.safeAreaLayoutGuide.layoutFrame
                bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
            }
            
            chatViewBottomConstraint.constant += keyboardSize.height - bottomSafeAreaHeight
        }
    }
    
    @objc private func keyboardWillHide() {
        if chatViewBottomConstraint.constant != 0 {
            chatViewBottomConstraint.constant = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func addViewTapGestureRecognizer() {
        removeViewTapGestureRecognizer()
        
        viewTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        
        if let viewTap = viewTap {
            viewTap.cancelsTouchesInView = false
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
    
    private func addWillEnterForegroundObserver() {
        willEnterForegroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            // alwan comment: kalau ga di reload, constraint-nya ada yang berubah
            chatMessagesTableView.reloadData()
            tableViewScrollToBottom(animated: false)
            
        }
    }
    
    private func removeWillEnterForegroundObserver() {
        if let willEnterForegroundObserver = willEnterForegroundObserver {
            NotificationCenter.default.removeObserver(willEnterForegroundObserver)
        }
    }
    
    public func tableViewScrollToBottom(animated: Bool) {
        DispatchQueue.main.async {
            guard let messagesCount = self.chatRoom?.messages?.count else {
                print("File: \(#file) - Function: \(#function) - Line: \(#line) - messagesCount not found")
                return
            }
            
            if messagesCount > 0 {
                let indexPath = IndexPath(row: messagesCount - 1, section: 0)
                self.chatMessagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
    
    private func sendChatMessage() {
        guard let userID = userID else {
            AlertManager.shared.presentErrorAlert(file: #file, function: #function, line: #line, title: "User Error", error: "userID not found", viewController: self)
            return
        }
        
        guard let roomID = chatRoom?.roomID else {
            AlertManager.shared.presentErrorAlert(file: #file, function: #function, line: #line, title: "User Error", error: "roomID not found", viewController: self)
            return
        }
        
        guard let content = chatTextView.text, content != "" else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - content is empty")
            return
        }
        
        var messageID = String()
        var isUnique = false
        while isUnique == false {
            let uuid = UUID().uuidString
            messageID = "\(userID)_\(uuid)"
            
            isUnique = CoreDataManager.shared.isValidChatMessageID(messageID: messageID)
        }
        
        let timestamp = TimestampManager.shared.getCurrentTimestamp()
        
        chatTextView.text = ""
        view.endEditing(true)
        
        let chatMessage = ChatMessage(messageID: messageID, roomID: roomID, content: content, type: "text", timestamp: timestamp, date: nil, time: nil, sender: userID, readBy: [userID], status: "Sending...")
        
        CoreDataManager.shared.updateChatMessageToCoreData(chatMessage: chatMessage)
        
        if chatRoom?.messages == nil {
            chatRoom?.messages = [chatMessage]
        }
        else {
            chatRoom?.messages?.append(chatMessage)
        }
        
        chatMessagesTableView.reloadData()
        tableViewScrollToBottom(animated: true)
        
        FirestoreManager.shared.sendChatMessage(userID: userID, chatMessage: chatMessage)
        
        print("chatRoom: \(chatRoom)")
        print("participantNames: \(chatRoom?.participantNames)")
        print("userID: \(userID)")
        
        let title = chatRoom?.participantNames[userID] ?? ""
        let body = content
        
        guard let participants = chatRoom?.participants else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - participants not found")
            return
        }
        
        for participant in participants {
            if participant != userID {
                guard let receiverFCMToken = chatRoom?.participantFCMTokens[participant] else {
                    AlertManager.shared
                        .presentErrorAlert(file: #file, function: #function, line: #line, title: "Push Notification Error", error: "receiverFCMToken not found", viewController: self)
                    continue
                }
                
                FCMManager.shared.sendPushNotification(receiverFCMToken: receiverFCMToken, title: title, body: body)
            }
        }
    }
    
    public func readMessages() {
        DispatchQueue.main.async {
            guard let messages = self.chatRoom?.messages else {
                print("File: \(#file) - Function; \(#function) - Line: \(#line) - messages not found")
                return
            }
            
            guard let userID = self.userID else {
                print("File: \(#file) - Function; \(#function) - Line: \(#line) - Error: userID not found")
                return
            }
            
            for index in messages.indices {
                var isRead = false
                
                guard let readers = messages[index].readBy else {
                    print("File: \(#file) - Function; \(#function) - Line: \(#line) - readers not found")
                    continue
                }
                
                for reader in readers {
                    if reader == self.userID {
                        isRead = true
                        break
                    }
                }
                
                if isRead == false {
                    FirestoreManager.shared.updateChatMessageRead(userID: userID, messageID: messages[index].messageID)
                }
            }
        }
    }
    
    private func removeChatMessagesVC() {
        chatRoomsVC?.chatMessagesVC = nil
    }
    
}

extension ChatMessagesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatRoom?.messages?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatMessagesTableView.dequeueReusableCell(withIdentifier: "cell") as! ChatMessagesTableViewCell
        
        cell.selectionStyle = .none
        
        let senderID = chatRoom?.messages?[indexPath.row].sender ?? ""
        
        var userIsSender = false
        
        var senderName = ""
        
        if senderID == userID {
            userIsSender = true
            senderName = "You"
        }
        else {
            senderName = chatRoom?.participantNames[senderID] ?? "Unknown User"
        }
        
        let type = chatRoom?.messages?[indexPath.row].type ?? ""
        
        var message = ""
        if type == "text" {
            message = chatRoom?.messages?[indexPath.row].content ?? ""
        }
        else if type == "image" {
            message = "image"
        }
        else if type == "video" {
            message = "video"
        }
        else if type == "" {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: type is empty for message ID: \(chatRoom?.messages?[indexPath.row].messageID)")
        }
        else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: Unknown type for message ID: \(chatRoom?.messages?[indexPath.row].messageID)")
        }
        
        var date = ""
        if let dateTemp = chatRoom?.messages?[indexPath.row].date {
            date = dateTemp
        }
        
        var isDateSame = false
        if indexPath.row > 0 && date != "" {
            if var previousDate = chatRoom?.messages?[indexPath.row - 1].date {
                if previousDate == date {
                    isDateSame = true
                }
            }
        }
        
        let currentTimestamp = TimestampManager.shared.getCurrentTimestamp()
        let dateString = TimestampManager.shared.convertTimestampToDateString(timestamp: currentTimestamp) ?? ""
        var separatorIndex: Int?
        
        if !dateString.indices.isEmpty {
            for dateStringIndex in dateString.indices {
                if dateString[dateStringIndex] == "_" {
                    separatorIndex = dateString.distance(from: dateString.startIndex, to: dateStringIndex)
                }
            }
        }
        
        var currentDate: String? = nil
        
        if let separatorIndex = separatorIndex {
            let prefixLength = separatorIndex
            currentDate = String(dateString.prefix(prefixLength))
        }
        
        if date == currentDate {
            date = "Today"
        }
        
        var time = ""
        if let timeTemp = chatRoom?.messages?[indexPath.row].time {
            time = timeTemp
        }
        
        let status = chatRoom?.messages?[indexPath.row].status ?? ""
        
        cell.setupChatMessage(userIsSender: userIsSender, senderName: senderName, message: message, date: date, time: time, isDateSame: isDateSame, status: status)
        
        return cell
    }
    
}

extension ChatMessagesVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count + text.count <= 500 {
            return true
        }
        else {
            return false
        }
    }
    
}
